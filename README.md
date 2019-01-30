# rosenv
Bash addon script to change ROS environments quickly and persistent across shells

---
## How to use:
1. source script *rosenv.sh* in your .bashrc `source PATH/TO/rosenv.sh`
1. open new shell/terminal
1. setup will run, greeting shows
1. Usage: `rosenv|re ENV_NAME`
+ to change default install dir: export ROSENV_DIR=/some/path (default: ~/rosenv)
+ to use a different subnet ip: export ROSENV_SUBNET=10.0 (default: 192.)

# Usage
```
Usage: rosenv ENV_NAME
Try 'rosenv local' for the local environment.

Currently available ROS environments:
-------------------------------------
local,127.0.0.1,http://127.0.0.1:11311
-------------------------------------

Add more environments in '/home/vater/rosenv/rosenv.cvs', one per line, in the form:

  env name,ROS_IP/ROS_HOSTNAME,ROS_MASTER_URI[,comment]

You can use function 'getIP' to get the first local subnet ip (192. ..), if any
or 'getIP INTERFACE_NAME' to get that interface-specific ip.
Hint: Use the hostname of the ROS_MASTER_URI machine for greater flexibility.

Exemplary 'rosenv.cvs' content:

  local,127.0.0.1,http://127.0.0.1:11311
  turtle,$(getIP),http://super-mega-bot.local:11311,connected to subnet
  skynet,$(getIP wlp2s0),http://666.0.815.007:88888,via wifi
  hal,dave-pc,http://2.0.0.1:9000
```

# Hacks
Add a line like `,127.0.0.1,http://127.0.0.1:11311` (notice no env name!) and just type `rosenv` (without arg) for switching to this one.

# Tested on
Ubuntu 16.04.5 LTS  
GNU bash, version 4.3.48(1)-release (x86_64-pc-linux-gnu)

---
(c) 2018 tw
