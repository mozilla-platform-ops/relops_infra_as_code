from fabric import Connection
from invoke import UnexpectedExit
from rich import print
from rich.console import Console
from rich.prompt import Prompt
from rich.table import Table
from rich import box
import getpass
import sys
import yaml

console = Console()
discovered_vms = []  # List of (ip, mac, hostname, worker_pool, discovered_from)


def display_title():
    console.print("\n[bold cyan]🛰️ VM Orchestrator CLI[/bold cyan]", justify="center")
    console.print("[green]Welcome to the VM discovery and orchestration tool![/green]\n", justify="center")


def get_user_input():
    username = Prompt.ask("Enter the SSH username", default="admin")
    password = getpass.getpass("Enter the SSH password (hidden): ") or "admin"
    hosts_input = Prompt.ask(
        "\nEnter the underlying macOS hosts (comma-separated)",
        default="macmini-m4-1.local,macmini-m4-2.local,macmini-m4-3.local,macmini-m4-4.local"
    )
    hosts = [h.strip() for h in hosts_input.split(",")]
    return username, password, hosts


def show_summary(username, password, hosts):
    table = Table(title="📡 Configuration Summary", show_lines=True)
    table.add_column("Setting", style="cyan", no_wrap=True)
    table.add_column("Value", style="magenta")
    table.add_row("SSH Username", username)
    table.add_row("SSH Password", "*" * len(password))
    table.add_row("Underlying Hosts", "\n".join(hosts))
    console.print(table)


def discover_vms(username, password, hosts):
    global discovered_vms
    discovered_vms = []

    for host in hosts:
        console.rule(f"[bold blue]🔍 Discovering VMs on {host}")
        try:
            conn = Connection(
                host=host,
                user=username,
                connect_kwargs={
                    "password": password,
                    "look_for_keys": False,
                    "allow_agent": False
                }
            )

            result = conn.run("arp -a | grep bridge100", hide=True, warn=True)

            vm_table = Table(title=f"🧠 Detected VMs on {host}", show_header=True, header_style="bold green", box=box.SQUARE)
            vm_table.add_column("#", justify="right")
            vm_table.add_column("IP Address", style="cyan")
            vm_table.add_column("MAC Address", style="magenta")
            vm_table.add_column("Hostname", style="yellow")
            vm_table.add_column("Worker Pool", style="bright_blue")

            index = 1
            if result.ok and result.stdout.strip():
                for line in result.stdout.strip().splitlines():
                    parts = line.split()
                    if len(parts) >= 4:
                        ip = parts[1].strip("()")
                        mac = parts[3]

                        if ip in ("192.168.64.1", "224.0.0.251"):
                            continue

                        try:
                            vm_conn = Connection(
                                host=ip,
                                user=username,
                                connect_kwargs={
                                    "password": password,
                                    "look_for_keys": False,
                                    "allow_agent": False
                                },
                                gateway=conn
                            )
                            hostname = vm_conn.run("hostname", hide=True).stdout.strip()

                            try:
                                # Try to read worker-runner-config.yaml using sudo (with pty to allow sudo password prompt)
                                worker_config_result = vm_conn.run("sudo cat /opt/worker/worker-runner-config.yaml", hide=True, pty=True)
                                worker_config = worker_config_result.stdout
                                parsed_yaml = yaml.safe_load(worker_config)
                                worker_pool_id = parsed_yaml.get("provider", {}).get("workerPoolID", "Unknown")
                                pool_name = worker_pool_id.split("/")[-1]
                            except Exception as e:
                                pool_name = "[red]Unknown[/red]"
                                print(f"[dim]    ❌ Could not read worker config on {ip}: {e}[/dim]")

                        except Exception as e:
                            hostname = "[red]Unknown[/red]"
                            pool_name = "[red]Unknown[/red]"
                            print(f"[dim]    ❌ Could not SSH into VM {ip}: {e}[/dim]")

                        discovered_vms.append((ip, mac, hostname, pool_name, host))
                        vm_table.add_row(str(index), ip, mac, hostname, pool_name)
                        index += 1

                console.print(vm_table)
            else:
                console.print(f"[yellow]⚠️ No VMs found on bridge100 interface on {host}[/yellow]")

        except Exception as e:
            console.print(f"[red]❌ Failed to connect to {host}: {e}[/red]")


def interactive_menu(username):
    if not discovered_vms:
        console.print("[red]❌ No VMs were discovered.[/red]")
        return

    table = Table(title="📟 VM Selection Menu", show_lines=True)
    table.add_column("Option", style="bold cyan")
    table.add_column("Hostname", style="yellow")
    table.add_column("IP Address", style="magenta")
    table.add_column("MAC", style="white")
    table.add_column("Worker Pool", style="bright_blue")
    table.add_column("Discovered From", style="blue")

    for i, (ip, mac, hostname, pool, host) in enumerate(discovered_vms, start=1):
        table.add_row(str(i), hostname, ip, mac, pool, host)

    console.print(table)

    try:
        choice = int(Prompt.ask("Select a VM to SSH into (number) or 0 to quit", default="0"))
        if choice == 0:
            console.print("[cyan]👋 Exiting.[/cyan]")
            sys.exit(0)

        selected_vm = discovered_vms[choice - 1]
        ip = selected_vm[0]
        console.print(f"[green]Connecting to {ip} as {username}...[/green]")
        host = selected_vm[4]
        import subprocess
        subprocess.run(["ssh", "-J", f"{username}@{host}", f"{username}@{ip}"])

    except (ValueError, IndexError):
        console.print("[red]Invalid selection.[/red]")
    except KeyboardInterrupt:
        console.print("\n[red]Aborted by user.[/red]")


def main():
    display_title()
    username, password, hosts = get_user_input()
    show_summary(username, password, hosts)

    if Prompt.ask("\n[bold green]Proceed with VM discovery?[/bold green] (y/n)", default="y") == "y":
        discover_vms(username, password, hosts)
        interactive_menu(username)
    else:
        console.print("[red]Aborted by user.[/red]")


if __name__ == "__main__":
    main()