if [[ "${USER}" != "root" ]]; then
        os_desc=$(grep -i pretty /etc/*release | tr -d "'\"")
        printf "Welcome to %s (%s %s %s)\n" "${os_desc#*=}" "$(uname -o)" "$(uname -r)" "$(uname -m)"


        echo "                    ___.                  "
        echo "  ___________   ____\_ |__  __ __  ______ "
        echo "_/ __ \_  __ \_/ __ \| __ \|  |  \/  ___/ "
        echo "\  ___/|  | \/\  ___/| \_\ \  |  /\___ \  "
        echo " \___  >__|    \___  >___  /____//____  > "
        echo "     \/            \/    \/           \/  "
        echo

        # Calulate CPU usage and core count
        cpu_usage=$(awk '{print $2}' /proc/loadavg)
        cpu_count=$(nproc --all)

        # Check if current usage isn't to high, else don't display the motd
        if [[ ${cpu_usage%.*} -ge ${cpu_count} ]];
        then
          printf "motd disabled because current usage is %s\n" "$cpu_usage"
        else
          date=$(date)

          # We use df to display the filesystems and use awk to get the usage and path and reverse sort so the top line is the fullest
          highest_usage_full=$(df | awk 'NR>1 {print $5 " " $6 | "sort -nr -k1"}' | head -n1)
          name_highest_usage=$(echo $highest_usage_full | awk '{print $2}')
          percentage_highest_usage=$(echo $highest_usage_full | awk '{print $1}')

          # Use awk to get and calculate the percentage usage against the total amount of memory
          memory_usage=$(awk '/MemT/{t=$2} /MemA/{printf "%.f%%", (1-$2/t)*100}' /proc/meminfo)
          users=$(users | wc -w)

          # Try to display the amount of uptime in minutes, if over 59 minutes show amount of hours, and after 23 hours show amount of days. However it now shows the 5 minutes as 5 hours...
          uptime=$(uptime | sed -E 's/^[^,]*up *//; s/, *[[:digit:]]* users.*//; s/min/minutes/; s/([[:digit:]]+):0?([[:digit:]]+)/\1 hours, \2 minutes/'| awk '{print $1,$2}' | tr -d ,)
          processes=$(ps -e --no-headers | wc -l)
          ip=$(ip -4 a show scope global | awk '/inet/ {print $2; exit}')
          ipv6=$(ip -6 a show scope global | awk '/inet/ {print $2; exit}')
          #packages=$(rpm -qa | wc -l)
          packages="idk"

          #updates=$(head -n1 /etc/update-motd.d/pkg.stats)
          #secupdates=$(tail -n1 /etc/update-motd.d/pkg.stats)

          # We calulcate everything beforehand, so that this part is consistently and easy to follow
          echo "System information as of: $date"
          echo
          printf "System Load:\t%s/%s\tSystem Uptime:\t%s\n" "$cpu_usage" "$cpu_count" "$uptime"
          printf "Memory Usage:\t%s\tIP Address:\t%s\n" "$memory_usage" "$ip"
          if [[ $ipv6 == "" ]]
          then
            printf "Usage On /:\t%s\tIPv6 Addres:\tNo ipv6 address found\n" "$root_usage"
          else
            printf "Use %s:\t%s\tIPv6 Addres:\t%s\n" "$name_highest_usage" "$percentage_highest_usage" "$ipv6"
          fi
          printf "Local Users:\t%s\tProcesses:\t%s\n" "$users" "$processes"
          printf "Packages rpm:\t%s\tSession fortune:\ \n\n" "$packages"

          /usr/bin/fortune
        fi

        # Check if there are updates
        echo
        echo "Last time updates were ran: $(dnf history list | grep -m 1 -i upgrade | awk '{print $4}')"

        # Check if a reboot is needed
        #needs-restarting -r
        echo
fi
