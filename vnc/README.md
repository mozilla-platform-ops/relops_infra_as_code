automation of mdm enroll for remote macos machines

### ssh:
* setup rosetta, no-screensaver, vnc
* download profile
* open profile settings panel

### vnc:
* screenshots and compares with expected sub-images and buttons
* clicks on buttons and enters admin user password to approve profile


## dev/setup:
* install requirements.txt
* pull git submodule (vncdotool), and install vncdotool/requirements.txt

### expects:
* ssh(user:pass) and vnc access to the target machines
* macos targets already configured to allow remote control
