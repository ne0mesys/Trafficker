# 📡 Trafficker.sh by ne0mesys
***This script has been created by ne0mesys and serves as an automation tool to steal HTTP credentials that travel through our network, hope you guys like it ;)***

## Welcome

This tool is a Bash-Based network analysis and spoofing tool designed for ethical hacking and penetration testing purposes. It performs **ARP Spoofing** and **Packet Sniffing** on a local network 
to intercept HTTP credentials such as usernames and passwords sent in plain text. This tool serves as an automation tool for pentesters, as it uses **arpspoof** and **tcpdump** as main help for the script.
This tool is well-known as a **MITM (Man-In-The-Middle) Attack**.


Please! Read the **Requirements** section, in order to have all previous software downloaded.

This tool is developed strictly for educational and ethical purposes. I DO NOT take any responsibility for the misuse of this tool. 

By ne0mesys

## Requirements

### For Linux

**Tcpdump** is required in order to perform the whole **Sniffing** part. In case you don't have it installed, you can find the instructions below for Linus users:
```
sudo apt update && sudo apt upgrade
sudo apt install tcpdump
```

**Arpspoof** is required as well, due to the whole **Spoofing** part. In case you don't have it installed, you can find the instructions below:
```
sudo apt install dsniff
```

**Macchanger** is required as well, due to the whole ***MAC Changing*** part. In case you don't have it installed, you can find the instructions below:
```
sudo apt install macchanger
```

**Without these softwares the script won't work!!**

### For Arch Linux

**Tcpdump** is required in order to perform the whole **Sniffing** part. In case you don't have it installed, you can find the instructions below Arch Linux:
```
sudo pacman -S tcpdump
```

**Arpspoof** is required as well, due to the whole **Spoofing** part. In case you don't have it installed, you can find the instructions below:
```
sudo pacman -S dsniff
```

**Macchanger** is required as well, due to the whole ***MAC Changing*** part. In case you don't have it installed, you can find the instructions below:
```
sudo pacman -S macchanger
```

**Without these softwares the script won't work!!**

## Installation

### For Linux

Here's a short documentation about how to install the script for Linux users:
```
sudo apt install git
sudo git clone https://github.com/ne0mesys/Trafficker
cd Trafficker
```

### For Arch Linux

Here's a short documentation about how to install the script for Arch Linux users:
```
sudo pacman -S git
sudo git clone https://github.com/ne0mesys/Trafficker
cd Trafficker
```

## Execution

Once we are in the same folder of the software, we can proceed to enable its execution. We can do this with the following command:
```
sudo chmod +x trafficker.sh
```

The sofware includes the Sheband line ```#!/bin/bash``` which allows the user to execute it directly. We can do this using the command ```./trafficker.sh```.

However, it would be necessary to have the script **always** in the same directory we are in, in case we wanted to use it. Therefore, I highly suggest to move a copy with execution permits to the **$PATH**, so we are able to use it as the command: ```trafficker```

In order to do this, perform the next commands in the terminal:
```
sudo chmod +x trafficker.sh
sudo mv trafficker.sh /usr/local/bin/trafficker
```

**Now you are able to use it as a command in the terminal!**

**Try it with the command:** ```trafficker```

## About
This tool has been created in order to speed up the **ARP Spoofing** process, whenever a penetration tester wanted to perform a **Sniffing Attack**. Instead of typing all the commands in the terminal, and having several terminal windows, I decided to mix it all enable a one-time process that automates all the past processess.

This script rather than just allowing to have the whole ARP Spoofing process automated, allows as well to have it in a colorful output that enhances the whole process.

The use of the **parameters** is highly sctrict in this script, therefore it is important to have some previous knowledge in IP Addresses. 

The parameters fo this script are the following ones:
* -s) Shows the hosts that are up in the same local network.
* -i) Indicates the Wi-Fi interface used for the MAC Address and packets manipulation.
* -t) Indicates the target (IP Address) to which the attack the sniffing is directed.
* -o) Indicates the duration of the packets sniffing (10s/30m/3h).
*  r) Indicates the host necessary to do all the ARP Spoof process.
*  h) Shows the help panel.

## Author

* Ne0mesys

Feel free to open an Issue...
```
E-Mail at: ne0mesys.acc@gmail.com
```



