#!/usr/bin/env bash

function _get_network_interface_icon {
  interface=$(route -n get 0.0.0.0 | grep '^ *interface: ' | awk '{print $2}')
  ethernet_or_wifi=$(networksetup -listallhardwareports | grep -B1 "$interface" | grep '^Hardware Port: ' | awk '{print $3}')

  icon_wifi=$(tmux show-option -gqv "@internet_icon_wifi")
  icon_ethernet=$(tmux show-option -gqv "@internet_icon_ethernet")

  if [[ "$ethernet_or_wifi" = "Wi-Fi" ]]; then
    echo "$icon_wifi"
  else
    echo "$icon_ethernet"
  fi
}

function _is_osx() {
  [ "$(uname)" == "Darwin" ]
}

function update_tmux_option {
  option="$1"
  option_value="$(tmux show-option -gqv "$option")"
  icon="$(_get_network_interface_icon)"
  new_option_value="${option_value//\#\{network_type_icon\}/$icon}"
  tmux set-option -gq "$option" "$new_option_value"
}

function main {
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}

main
