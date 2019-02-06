#!/usr/bin/env bash
# rosenv.sh
# Bash addon script to change ROS environments quickly
# Created ~tw 2018-09-24
# Reworked ~tw 2019-01-29
# csv path, flow ~tw 2019-02-01


#
# get the ip address
# param $1: specific interface name | search localIp
#
_re_getIp () {
  local localIp=$(if [ -n "$ROSENV_SUBNET" ]; then echo "$ROSENV_SUBNET"; else echo "192."; fi)

  if [ -z $1 ]; then
    hostname -I | tr ' ' '\n' | grep "$localIp" | head -n 1
  else
    ip addr show $1 | sed -rn 's/.*inet ([0-9\.]+)\/.*/\1/p'
  fi

  return 0
}
getIP () { _re_getIp "$@"; } && export -f getIP
#alias getIP='_re_getIp' THIS DOES NOT WORK IN NON-INTERACTIVE SHELLS


#
# set specific ROS env variables persisten across shells
# param $1: search str in .csv
#
_re_setEnv () {
  local _name='rosenv'
  local caller="${FUNCNAME[1]}"
  local sep=','
  local dir=$(if [ -n "$ROSENV_DIR" ]; then echo "$ROSENV_DIR"; else echo "$(dirname "${BASH_SOURCE[0]}")"; fi)
  local file="$_name.csv"
  local save=".$_name"
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

  # sanity check or setup
  if [ ! -r "$envs" ]; then
    echo -e "Setting up $_name ..."
    mkdir -p "$dir" &&\
    echo 'local,127.0.0.1,http://127.0.0.1:11311' > "$envs" &&\
    chmod 644 "$envs" &&\
    echo 'local' > "$last" &&\
    echo -e "$C Hello from $I $_name $Z\n'$envs' file created.\n$how" ||\
    echo -e "$E$_name setup failed.$Z"
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
    echo -e "${E}ROS environment '$1' not found.$Z"
    cat << EOL
Usage: $caller ENV_NAME
Try '$caller local' for the local environment.

Currently available ROS environments:
-------------------------------------
$(<"$envs")
-------------------------------------
$how
EOL
    return 20
  fi

  # split string into array
  # How do I split a string on a delimiter in Bash? https://stackoverflow.com/a/5257398
  IFS=$sep arrIN=($IN)
  if [ -z "${arrIN[2]}" ]; then
    echo -e "${E}Invalid environment .csv line at '$1'.$Z"
    return 30
  fi

  # save chosen env
  echo $1 > $last

  # set ROS
  # Evaluating variables in a string https://stackoverflow.com/a/18219315
  export ROS_IP="$(eval echo "${arrIN[1]}")"
  export ROS_MASTER_URI="$(eval echo "${arrIN[2]}")"
  # https://wiki.ros.org/ROS/EnvironmentVariables#ROS_IP.2BAC8-ROS_HOSTNAME
  # "ROS_IP and ROS_HOSTNAME are optional environment variable [...] mutually exclusive, if both are set ROS_HOSTNAME will take precedence."
  export ROS_HOSTNAME="$ROS_IP"

  # flash message
  echo -e "$C $caller $I $1 $Y ROS_IP/ROS_HOSTNAME $I $ROS_IP $Y ROS_MASTER_URI $I $ROS_MASTER_URI $Y $(rosversion -d) $Z"

  return 0
}

# https://stackoverflow.com/questions/41532874/use-bash-alias-name-in-a-function-that-was-called-using-that-alias
# crude workaround
rosenv () { _re_setEnv "$@"; } && export -f rosenv

# one-time fire
_re_isSet=0 && rosenv
