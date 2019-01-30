#!/bin/bash
# rosenv.sh
# Bash addon script to change ROS environments quickly
# Created by tw 2018-09-24
# Reworked by tw 2019-01-29

# How to use:
# source this script in your .bashrc 'source PATH/TO/rosenv.sh'
# Usage: rosenv|re ENV_NAME
# to change default install dir: export ROSENV_DIR=path (default: ~/rosenv) before sourcing
# to use a different subnet ip: export ROSENV_SUBNET=10.0 (default: 192.)
# Hacks: Add a line like `,127.0.0.1,http://127.0.0.1:11311` (notice no env name!) and just type `rosenv` (without arg) for switching to this one.

# get the ip address
# param $1: specific interface name | search localIp
_re_getIp () {
  local localIp=$(if [ -n "$ROSENV_SUBNET" ]; then echo "$ROSENV_SUBNET"; else echo "192."; fi)

  if [ -z $1 ]; then
    hostname -I | tr ' ' '\n' | grep "$localIp" | head -n 1
  else
    ip addr show $1 | sed -rn 's/.*inet ([0-9\.]+)\/.*/\1/p'
  fi

  return 0
}

alias getIP='_re_getIp'


# set specific ROS env variables persisten across shells
_re_setEnv () {
  local fun=rosenv
  local sep=,
  local dir=$(if [ -n "$ROSENV_DIR" ]; then echo "$ROSENV_DIR"; else echo "$HOME/$fun"; fi)
  local file="$fun.cvs"
  local save=".$fun"
  local envs="$dir/$file"
  local last="$dir/$save"
  # colors
  local C='\033[97;104m' Z='\033[0m' I='\033[7m' Y='\033[27m' E='\033[91m'
  local how="
Add more environments in '$envs', one per line, in the form:

  env name,ROS_IP/ROS_HOSTNAME,ROS_MASTER_URI[,comment]

You can use function 'getIP' to get the first local subnet ip (192. ..), if any
or 'getIP INTERFACE_NAME' to get that interface-specific ip.
Hint: Use the hostname of the ROS_MASTER_URI machine for greater flexibility.

Exemplary '$file' content:

  local,127.0.0.1,http://127.0.0.1:11311
  turtle,\$(getIP),http://super-mega-bot.local:11311,connected to subnet
  skynet,\$(getIP wlp2s0),http://666.0.815.007:88888,via wifi
  hal,dave-pc,http://2.0.0.1:9000
"

  # sanity check
  if [ ! -r "$envs" ]; then
    mkdir -p "$dir"
    echo 'local,127.0.0.1,http://127.0.0.1:11311' > "$envs"
    echo 'local' > "$last"
    cat << EOL
Hello from $fun!
'$envs' created.
$how
EOL
  return 10
  fi

  # triggered only if this function is called the first time in a new shell
  # auto sets the last env
  if [ "$_re_isSet" -eq "0" ]; then
    # How to change a command line argument in Bash? https://stackoverflow.com/a/4827707
    set -- $(<"$last")
    _re_isSet=1
  fi

  # find env sting in envs file
  IN=$(grep "^$1," "$envs")
  if [ -z "$IN" ]; then
    cat << EOL
ROS environment '$1' not found.

Usage: $fun ENV_NAME
Try '$fun local' for the local environment.

Currently available ROS environments:
-------------------------------------
$(<$envs)
-------------------------------------
$how
EOL
  return 20
  fi

  # split string into array
  # How do I split a string on a delimiter in Bash? https://stackoverflow.com/a/5257398
  IFS=$sep arrIN=($IN)
  if [ -z "${arrIN[2]}" ]; then
    echo -e "${E}Invalid environment csv form at '$1'.$Z"
    return 30
  fi

  # save chosen env
  echo $1 > $last

  # set ROS
  # Evaluating variables in a string https://stackoverflow.com/a/18219315
  export ROS_IP=$(eval echo "${arrIN[1]}")
  export ROS_MASTER_URI="${arrIN[2]}"
  # https://wiki.ros.org/ROS/EnvironmentVariables#ROS_IP.2BAC8-ROS_HOSTNAME
  # ROS_IP and ROS_HOSTNAME are optional environment variable [...] are mutually exclusive, if both are set ROS_HOSTNAME will take precedence.
  export ROS_HOSTNAME="$ROS_IP"

  # flash message
  echo -e "$C $fun $I $1 $Y ROS_IP/ROS_HOSTNAME $I $ROS_IP $Y ROS_MASTER_URI $I $ROS_MASTER_URI $Y $(rosversion -d) $Z"

  return 0
}

_re_isSet=0
_re_setEnv
alias rosenv='_re_setEnv'
alias re='rosenv'
