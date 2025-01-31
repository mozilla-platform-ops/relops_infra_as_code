#!/usr/bin/env bash

set -e
# set -x

scripts=(
    "./etc/tc-web-prom.sh proj-autophone"
    "./etc/queue2_prom.sh proj-autophone"
    # "./etc/check_vcs_prom.sh"  # rate-limits... so can't run often'
    "./etc/release_cal_prom.sh"
    "./etc/google_chrome_releases_prom.sh"
    "./etc/treestatus2-prom.sh"
)

# for each of these files in the etc directory, run the script and pipe the output to ./verify_prom_file.py
for script in "${scripts[@]}"; do
    cmd="$script | ./verify_prom_file.py"
    echo "* Running '$cmd'"
    $cmd
    echo ""
done

echo "* All scripts passed"
