# Currently just looking for VMs that are older than 1 day
# Commented out code is for future use if we want to expand the scope.

$subscriptionID = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
$uamiID ="6ccfd5c0-507b-45e5-b5c3-ba17bb67c762"
Connect-AzAccount -Identity -AccountId $uamiID
Set-AzContext -Subscription $subscriptionID

$current = (get-date -format g)
$vms = (get-azvm)
$issued_vms = New-Object System.Collections.ArrayList
$new_vms = New-Object System.Collections.ArrayList
$how_many = [int]0
$all_minutes = [int]0
$num_shut = [int]0
$failed = New-Object System.Collections.ArrayList
$no_agent = New-Object System.Collections.ArrayList
$shutdown = New-Object System.Collections.ArrayList

$current = ((Get-Date).ToUniversalTime())

foreach ($vm in $vms) {
	# write-host checking  $vm.name
	$status = (get-azvm -resourcegroup $vm.ResourceGroupName -name $vm.Name -status -ErrorAction:SilentlyContinue)

	if (!($status -like $null)) {
		if ($status.Statuses.count -gt 0) {
			$display_status = $status.Statuses[1].DisplayStatus
		} else {
			$display_status = $null
		}
	} else {
		$display_status = $null
	}

	if ($status -eq $null) {
		# Assuming VMs that are missing fields is being created at time of audit
		$new_vms.Add($vm.name) | Out-Null
	} elseif ( $display_status -like "VM running") {
		$how_many = $how_many + 1
		$provisioned_time = $status.Disks[0].Statuses[0].Time
		if ($status.VMAgent.Statuses.count -gt 0) {
			$agent_status = $status.VMAgent.Statuses[0].DisplayStatus
		} else {
			$agent_status = $null
		}
		$up_time = (New-TimeSpan -Start $provisioned_time -end $current -ErrorAction:SilentlyContinue)
		$hrs = $up_time.hours
		$dys = $up_time.days
		$days = [int]$dys
		$hours = [int]$hrs
		$all_minutes = [int]$all_minutes + [int]$up_time.TotalMinutes
		$tags = (Get-AzResource -ResourceGroupName $vm.ResourceGroupName -Name $vm.name).Tags
        if ($tags) {
		    $worker_pool = $tags['worker-pool-id']
        } else {
            $worker_pool = "unkown pool"
        }

		if ($agent_status -eq $null) {
			# most likely new vm/ do nothing
		} elseif (!( $agent_status -like "Ready")) {
			# If the agent is not running most likely the VM has issues.
			$no_agent.Add($vm.name) | Out-Null
			write-output  ('{0} vm agent is not running.' -f $vm.name)
			# Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -force
			$shutdown.Add($vm.name)| Out-Null
		}
		if (([int]$hours -ge 6) -or ([int]$days -ge 1)) {
			$issued_vms.Add($vm.name) | Out-Null
			if (([int]$days -ge 1) -and ($vm.ResourceGroupName -like "RG-TASKCLUSTER-WORKER-MANAGER-PRODUCTION")) {
				# Longer than a day assuming it is off the rails
				write-output ('{0} up days {1}. up hours {2}. Worker pool: {3} ' -f $vm.name, $up_time.days, $up_time.hours, $worker_pool )
				write-output ('shutting down {0} . It has been up for {1} days.' -f $vm.Name, $days)
				$num_shut = $num_shut + 1
				Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -force
				$shutdown.Add($vm.name)| Out-Null
			}  #else {
				#write-output ('{0} up days {1} up hours {2} and the agent is {3} ' -f $vm.name, $up_time.days, $up_time.hours, $agent_status)
				# if it is up for hours after failed provisioning it is worth checking into it
				#if ($status.Statuses[0].DisplayStatus -like "Provisioning failed") {
				#	$failed.Add($vm.name) | Out-Null
				#	write-host $vm.name Provisioning failed
				#	write-host Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -force
				#	$shutdown.Add($vm.name)| Out-Null
				#}
			#}
		}
	} else {
			# write-host $vm.name is OK
	}
}


write-output ('Total VMs shutdown: {0}' -f $num_shut)
write-output ('Total Running VMs: {0}' -f $how_many)
$avetime = [int]$all_minutes/[int]$how_many
$hrs = [int]$avetime/60
write-output  ('Average time up  {0} minutes ...  {1} hours' -f $avetime, $hrs)
