#!/usr/bin/env python3
# pylint: disable=cell-var-from-loop, missing-function-docstring, bare-except, invalid-name, too-many-statements, broad-except, logging-format-interpolation
"""
Automate SimpleMDM enrollment

${0} hostname1 [hostname2...hostnameN]
Example: ${0} macmini-m1-1.test.releng.mslv.mozilla.com macmini-m1-2.test.releng.mslv.mozilla.com

Expects direct access to dns,ssh,vnc for hostnames.
Expects user Administrator and asks for password.
Requires configuration (fabric .env file) with:
ProfileUUID,profile_sha256,simplemdm_enroll_url
Example fabric .env file to set these:
```
admin_user="Administrator"
admin_password="s3cretp@sss"
ProfileUUID="A03135CA-10BC-49DC-8E07-34454C52615D"
profile_sha256="a24f52edcc8b3211dd64315cdaa41e37241d33bfc72835f3be9e8b4e72b13107"
simplemdm_enroll_url="https://a.simplemdm.com/enroll/?c=12345678"
```

Connects with ssh and enables legacy VNC (sets password).
Connects with VNC and approves+installs pending policy.

If there are problems you can check the following screenshots for a host:
Screenshot of screen after login named {hostname}_logged_in_screen.png.
(If other applications are running, they may break the image checks)
Screenshot if completed named {hostname}_confirmed.png.
"""
import logging
import sys
import time
import os.path
import argparse
from getpass import getpass

from fabric import Connection, Config
import cv2 as cv
from decouple import config, UndefinedValueError

from vncdotool import api


logging.basicConfig(level=logging.WARN)

try:
    ProfileUUID = config('ProfileUUID')
    profile_sha256 = config('profile_sha256')
    simplemdm_enroll_url = config('simplemdm_enroll_url')
except UndefinedValueError as e:
    logging.error(e)
    sys.exit(1)

admin_user = config("admin_user", default="Administrator")
try:
    admin_password = config('admin_password')
except UndefinedValueError:
    admin_password = getpass("{} password:".format(admin_user))

parser = argparse.ArgumentParser(description="List of hosts.")
hostnames = [
    "macmini-m1-2.test.releng.mslv.mozilla.com",
]
parser.add_argument("hostnames", nargs="*", help="hostnames to apply to")
args = parser.parse_args()

if len(args.hostnames) > 0:
    hostnames = args.hostnames
print(args.hostnames)

try:
    with open("vnc_password", "r", encoding="utf-8") as f:
        vnc_password = f.readline()
except FileNotFoundError:
    import string

    try:
        from secrets import choice
    except ImportError:
        from random import choice
    vnc_password = "".join(
        (
            choice(string.ascii_letters + string.digits + string.punctuation)
            for i in range(32)
        )
    )
print("vnc_password:{}".format(vnc_password))


class ImageNotFound(RuntimeError):
    """subimage not matched"""

def locate_image(screen, image):
    """
    Find sub-image in screen.
    Returns found (x,y) location.
    Throws exception if not found.
    """
    img = cv.imread(screen, 0)
    template = cv.imread(image, 0)
    res = cv.matchTemplate(img, template, cv.TM_CCOEFF_NORMED)
    min_val, max_val, min_loc, top_left = cv.minMaxLoc(res)
    print(min_val, max_val, min_loc)

    if top_left is None:
        raise ImageNotFound("No sub-image {} found in {}.".format(image,screen))
    print(top_left, screen, image)

    return (top_left[0], top_left[1], max_val)


for target in hostnames:
    print(target)

    c = Connection(
        host=target,
        user=admin_user,
        config=Config(overrides={"sudo": {"password": admin_password}}),
        connect_kwargs={
            "password": admin_password,
            "look_for_keys": False,
            "allow_agent": False,
        },
        # gateway=jumphost,
    )

    def ensure_dns():
        try:
            c.run("networksetup -getdnsservers Ethernet")
        except:
            c.sudo(
                "networksetup -setdnsservers Ethernet 1.1.1.1;\
                networksetup -getdnsservers Ethernet",
                warn=True,
            )

    def ensure_rosetta():
        # for p in ['/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist',
        plist = "/System/Library/LaunchDaemons/com.apple.oahd.plist"
        try:
            c.sudo("/usr/bin/stat {}".format(plist))
        except:
            c.sudo(
                "softwareupdate --install-rosetta --agree-to-license",
                warn=True,
                timeout=600,
            )

    def ensure_puppet_agent():
        try:
            c.run("/opt/puppetlabs/bin/puppet --version")
        except:
            c.sudo(
                """
                curl -q -L -o /tmp/puppet-agent-latest.dmg \
                        http://downloads.puppet.com/mac/puppet7/11/x86_64/puppet-agent-latest.dmg
                hdiutil mount /tmp/puppet-agent-latest.dmg
                installer -target / -pkg /Volumes/puppet-agent-*.osx11/puppet-agent-*-installer.pkg
            """,
                warn=True,
                timeout=120,
            )

    def is_enrolled():
        r = c.sudo(
            "profiles list -output stdout-xml | grep -A1 ProfileUUID",
            warn=True,
            hide=True,
        )
        return ProfileUUID in r.stdout

    def stop_screensaver():
        r = c.sudo("killall ScreenSaverEngine", warn=True)
        if not "No matching processes" in r.stdout:
            c.sudo(
                "defaults write /Library/Preferences/com.apple.loginwindow \
                        autoLoginUserScreenLocked 0",
                warn=True,
            )

    def enable_legacy_vnc():
        """
        https://github.com/dakotaKat/fastmac-VNCgui/blob/master/configure.sh
        http://hints.macworld.com/article.php?story=20071103011608872
        """
        c.sudo(
            """\
            /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart\
                -activate -configure -access -on\
                -clientopts -setvnclegacy -vnclegacy yes\
                -clientopts -setvncpw -vncpw \"{vnc_password}\"\
                -restart -agent -privs -all\
        """.format(
                vnc_password=vnc_password
            ),
            warn=True,
        )

    def disable_legacy_vnc():
        c.sudo(
            """\
            /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart\
                -clientopts -setvnclegacy -vnclegacy no\
                -restart -agent -privs -all\
        """,
            warn=True,
        )

    def reset_prefs_position():
        r = c.run(
            'defaults read ~/Library/Preferences/com.apple.systempreferences.plist \
            | grep NSWindow \
            | cut -d\\" -f4',
            warn=True,
        )
        window_pos = r.stdout
        print(window_pos)
        if window_pos != "630 416 668 516 0 0 1920 1055 ":
            if window_pos != "630 484 668 448 0 0 1920 1055 ":
                if c.run(
                    'defaults write ~/Library/Preferences/com.apple.systempreferences \
                        "NSWindow Frame Main Window Frame SystemPreferencesApp 8.0" \
                        "630 484 668 448 0 0 1920 1055 "',
                    warn=True,
                ).failed:
                    os.remove(
                        "/Users/Administrator/Library/Preferences/com.apple.systempreferences.plist"
                    )

    def get_enroll_profile():
        return c.run(
            """\
            shasum -a256 -c <<<"{profile_sha256}  /Users/administrator/enroll.mobileconfig" \
              || ( curl -q -v -L "https://a.simplemdm.com$(curl -q -L '{simplemdm_enroll_url}'\
                    |grep -o 'href=./device/enrollment/profiles[^\\"]*' | cut -d\\" -f2)" \
                > ~/enroll.mobileconfig \
                && shasum -a256 ~/enroll.mobileconfig )
            chmod -R 644 ~/enroll.mobileconfig
        """.format(
                profile_sha256=profile_sha256, simplemdm_enroll_url=simplemdm_enroll_url
            ),
            warn=True,
        ).ok

    def open_profile():
        return c.run(
            """\
            open ~/enroll.mobileconfig
            sleep 1
            open /System/Library/PreferencePanes/Profiles.prefPane/
        """,
            warn=True,
        ).ok

    def vnc_setup_profile():
        logging.basicConfig(level=logging.DEBUG)
        client = api.connect(target, password=vnc_password, legacy=True)
        client.timeout = 60  # global timeout for connection response

        capture_prefix = target
        try:

            def expectRegion(expected, retries=5, threshold=0.5):
                max_val = 0
                while retries > 0:
                    screen_filename = "capture.{}.png".format(
                        time.strftime("%Y-%m-%d_%H:%M:%S", time.gmtime())
                    )
                    # apple vnc buffer capture times-out sometimes without activity
                    # if we move the mouse, we are move likely to trigger the update
                    client.mouseMove(1210, 250)
                    client.mouseMove(1220, 150)
                    client.pause(1)
                    client.captureScreen(screen_filename)
                    try:
                        (x, y, max_val) = locate_image(screen_filename, expected)
                        print(x, y, max_val)
                        if max_val > threshold:
                            return (x, y)
                    except Exception as e:
                        print(e)
                    retries = retries - 1
                    time.sleep(1)
                    logging.warning("retry={} No region match for {} (max_val[{}] ! > {}".format(
                        retries, expected, max_val, threshold))
                raise ImageNotFound(
                    "No region match for {} (max_val[{}] ! > {}".format(
                        expected, max_val, threshold
                    )
                )

            try:
                (x, y) = expectRegion("login_bubbles_not_prompt.png", retries=1, threshold=0.9)
                logging.warning('wrong login prompt (bubbles)')
                client.keyPress("right")
                client.keyPress("enter")
                (x, y) = expectRegion("login_bubbles_not_prompt.png", retries=1, threshold=0.9)
                logging.warning('wrong login prompt after enter')
                client.mouseMove(476, 450)
                client.mouseClick(1)
                (x, y) = expectRegion("login_bubbles_not_prompt.png", retries=1, threshold=0.9)
                logging.warning('wrong login prompt after click!?')
                raise Warning('wrong login prompt!?')
            except ImageNotFound:
                print("login prompt not bubbles")

            (x, y) = expectRegion("login.png")
            client.type(admin_password)
            (x, y) = expectRegion("login_typed_dots.png")
            client.keyPress("enter")

            (x, y) = expectRegion("menubar_apple.png")
            retries = 4
            while x != 1 and y != 2:
                logging.warning("no menubar? "
                    "move the mouse and kill the screensaver [retry=%s]", retries)
                client.mouseMove(1210, 250)
                client.mouseMove(1220, 150)
                client.mouseClick(1)
                stop_screensaver()
                (x, y) = expectRegion("menubar_apple.png")
                retries = retries - 1
                if retries < 1:
                    break

            client.captureScreen("{}_logged_in_screen.png".format(capture_prefix))

            def close_apps():
                for app in [
                    "Firefox",
                    "Nightly",
                    "Beta",
                    "Mail",
                    "Photos",
                    "System Preferences",
                    "Terminal",
                    "Safari",
                ]:
                    # security restrictions allow direct application 'quit' action
                    # https://scriptingosx.com/2020/09/avoiding-applescript-security-and-privacy-requests/
                    c.run(
                        "osascript -e 'tell application \"{}\" to quit'".format(app),
                        warn=True,
                        timeout=15,
                    )

            close_apps()

            profile_setup = open_profile()
            logging.debug("profile_setup:{}".format(profile_setup))

            try:
                # If the profiles panel is blank,
                # reset+reopen it.
                (x, y) = expectRegion("profiles_blank.png", retries=1, threshold=0.8)
                logging.debug("blank profiles window")
                close_apps()
                c.sudo('killall "System Preferences"', warn=True)
                reset_prefs_position()
                profile_setup = open_profile()
                logging.debug("profile_setup:{}".format(profile_setup))
            except ImageNotFound:
                logging.debug("Confirmed profile panel not blank.")

            try:
                (x, y) = expectRegion("managed.png", retries=1)
                logging.warning("already enrolled in MDM")
                raise Exception("already enrolled in MDM")
            except ImageNotFound:
                logging.info("Confirmed not already enrolled in MDM.")

            (x, y) = expectRegion("install_button_full.png")
            # TODO: if not found, kill and re-open?
            client.mouseMove(x + 20, y + 10)
            client.mouseClick(1)

            (x, y) = expectRegion("install_button_confirm.png")
            # TODO: if not found, kill and re-open?
            client.mouseMove(x + 5, y + 5)
            client.mouseClick(1)

            (x, y) = expectRegion("install_pw_title.png")
            # TODO: if not found, kill and re-open?
            client.type(admin_password)

            (x, y) = expectRegion("install_enroll_button.png")
            client.mouseMove(x + 20, y + 5)
            client.mouseClick(1)

            client.pause(5)

            (x, y) = expectRegion("managed.png")
            # TODO: if not found, fail?
            client.captureScreen("{}_confirmed.png".format(capture_prefix))

            (x, y) = expectRegion("close_button.png")
            client.mouseMove(x + 25, y + 25)
            client.mouseClick(1)
            client.pause(1)
            client.disconnect()
            return True
        except Exception as e:
            print(e)
            client.disconnect()
            return False

    def prep():
        ensure_dns()
        ensure_rosetta()
        ensure_puppet_agent()

        stop_screensaver()

        print("Load MDM profile")
        # Remove the profile if opened but not installed before.
        try:
            c.run("profiles -R -p ddb4c3b5-8357-4b2c-8b23-4e75dfdf78a1 2>/dev/null")
        except:
            c.sudo(
                "profiles -R -p ddb4c3b5-8357-4b2c-8b23-4e75dfdf78a1 2>/dev/null", warn=True
            )
        get_enroll_profile()

    if is_enrolled():
        print("Already enrolled in MDM")
        continue

    prep()
    enable_legacy_vnc()
    stop_screensaver()

    if not vnc_setup_profile():
        print("Retry profile setup in vnc.")
        vnc_setup_profile()

    disable_legacy_vnc()

    print("finished {}".format(target))
