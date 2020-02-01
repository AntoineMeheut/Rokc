#!/bin/bash

# Functions
confirm() {
#
# syntax: confirm [<prompt>]
#
# Prompts the user to enter Yes or No and returns 0/1.
#
  local _prompt _default _response

  if [ "$1" ]; then _prompt="$1"; else _prompt="Are you sure"; fi
  _prompt="$_prompt [y/n] ?"

  # Loop forever until the user enters a valid response (Y/N or Yes/No).
  while true; do
    read -r -p "$_prompt " _response
    case "$_response" in
      [Yy][Ee][Ss]|[Yy]) # Yes or Y (case-insensitive).
        return 0
        ;;
      [Nn][Oo]|[Nn])  # No or N.
        return 1
        ;;
      *) # Anything else (including a blank) is invalid.
        ;;
    esac
  done
}

flash_pi() {
  #
  # flash_pi function will :
  # - download Hypriot image
  # - flash your 4 SD cards with hostname from n0(master) to n3
  #

  # Params for Hypriot flash
  echo "--ssid <your wifi ssid>"
  read -r ssid
  echo "--password <your wifi password>"
  read -r password
  echo "Hypriot version <something like 1.5 or 1.7.1 or higher>"
  read -r hver

  if [ -z "$ssid" ] || [ -z "$password" ]; then
     echo "Usage: $0 --hostname <name> --ssid <wifi ssid> --password <pass> --image <hypriot image>"
     exit 1
  fi

  # Load Hypriot image
  echo "Load Hypriot v1.5.0 image"
  cmd="curl -L https://github.com/hypriot/image-builder-rpi/releases/download/v$hver/hypriotos-rpi-v$hver.img.zip --output hypriotos-rpi-v$hver.img.zip"
  echo "$cmd" && $cmd

  # Assigne Hypriot image name
  image="hypriotos-rpi-v$hver.img.zip"
  echo "Will use $image"

  # Test if Hypriot image is here
  if [ ! -f "$image" ]; then
     echo "No image $image found"
     exit 1
  fi

  # The pi hostnames will be n0(master), n1, n2, n3
  echo "Will flash Hypriot image to : n0, n1, n2, and n3 pi SD Cards"
  for i in 0 1 2 3
    do
      echo "Creating pi n${i}"
      cmd="/usr/local/bin/flash --hostname n${i} --ssid "$ssid" --password "$password" $image"
      echo "$cmd" && $cmd
      if [ "$i" -lt 3 ]; then
        echo "Change SD Card, then press enter"
        read -r next
      fi
    done

  # Delete Hypriot image
  echo "Delete Hypriot v$hver image"
  cmd="rm -f hypriotos-rpi-v$hver.img.zip"
  echo "$cmd" && $cmd
}

#
# Main script : Presentation of the prerequisites and script objectives
#
echo "This script will flash 4 Raspberry from n0(master) to n3"
echo "pi hostname will be : n0, n1, n2, n3"
echo ""
echo -e "\033[31mBefore running this script remember to install the prerequisites for Hypriot flash\033[0m"
echo ""
echo "To install Hypriot flash on a MacBook"
echo "Thank's to https://github.com/hypriot"
echo "curl -LO https://github.com/hypriot/flash/releases/download/2.3.0/flash"
echo "chmod +x flash"
echo "sudo mv flash /usr/local/bin/flash"
echo ""
echo "To install the Hypriot Flash dependencies"
echo "sudo xcodebuild -license accept"
echo "xcode-select --install"
echo "brew install pv"
echo "brew install awscli"
echo -e "\033[31mBefore going further it is advisable to check these dependencies\033[0m"
if (confirm "Would you like to continue and flash the SD cards" $1) ; then
  flash_pi;
  else
    exit ;
fi