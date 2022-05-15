#!/bin/bash
# Taken from:
#	https://raw.github.com/kaihendry/Kai-s--HOME/master/.xinitrc
#
# for terminus font in Archlinux :(
# xset +fp /usr/share/fonts/local
# xset fp rehash

# eval `/usr/bin/ssh-agent`

# if test -f /usr/lib/openssh/x11-ssh-askpass # Archlinux
# then
	# SSH_ASKPASS=/usr/lib/openssh/x11-ssh-askpass ssh-add < /dev/null
# fi
# 
# if test -f /usr/lib/ssh/x11-ssh-askpass # Debian
# then
	# SSH_ASKPASS=/usr/lib/ssh/x11-ssh-askpass ssh-add < /dev/null
# fi

# 1280x720 = 720p X220
# hash fswebcam && fswebcam -q --no-banner -r 1280x720 ~/private/login-photos/$(date +%Y-%m-%dT%H).jpg &

xrdb -merge $HOME/.Xresources
# xmodmap ~/.Xmodmap
# setxkbmap -layout gb -option ctrl:nocaps

# hash chromium && chromium &
xsetroot -solid '#111' &

while true
do
	# VOL=$(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')
	VOL=$(amixer get Master | awk -F'[][]' 'END{ print $4":"$2 }')
	LOCALTIME=$(date +%a-%d-%b\ %R)
	OTHERTIME=$(TZ=Europe/London date +%Z\=%H:%M)
	IP=$(for i in `ip r`; do echo $i; done | grep -A 1 src | tail -n1) # can get confused if you use vmware
	# TEMP="$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))C"
	TEMP="$(sed 's/000$/°C/' /sys/class/thermal/thermal_zone0/temp)"
	QUAL="$(/sbin/iw dev wlp3s0 link | grep 'dBm$' | grep -Eoe '-[0-9]{2}' | awk '{print  ("W:",$1 > -50 ? 100 :($1 < -100 ? 0 : ($1+100)*2))}' | tr -d ' ')"
	DISK=$(df -Ph | grep "/dev/sda1" | awk {'print " "$4"/"$2'})
	MEM=$(free -h --kilo | awk '/^Mem:/ {print $3 "/" $6}')
	RX=$(/sbin/iw dev wlp3s0 link | grep "RX" | awk {'printf ("RX:""%d\n",$2/1000000)'})
	TX=$(/sbin/iw dev wlp3s0 link | grep "TX" | awk {'printf ("TX:""%d\n",$2/1000000)'})
	# UP=$(uptime | awk '{print $2"="$3}' | tr -d ',')
	UP=$(uptime -p | awk '{print $2":"$4":"$6}' | tr -d ',')
	CPU=$(top -bn1 | grep "Cpu(s)" | awk {'print 100-$8'})
	# (/sbin/iw dev wlp3s0 link | grep 'dBm$' | grep -Eoe '-[0-9]{2}' | awk '{print  $1"dBm" }')
	# (/sbin/iw dev wlp3s0 link | grep "RX" | awk {'print $2/1000000 " Mb" '})
	# (/sbin/iw dev wlp3s0 link | grep "TX" | awk {'print $2/1000000 " Mb" '})
	# (free -h --kilo | awk '/^Mem:/ {print $3 "/" $2}')
	# (curl v2d.wttr.in/Tyumen?format="%l:+%m+%p+%w+%t+%c+%C")
	# uptime | awk '{print $2"-"$3}'


	if acpi -a | grep off-line > /dev/null
	then
		# BAT="Bat. $(acpi -b | awk '{ print $4 " " $5 }' | tr -d ',')"
		BAT=$(acpi -b | awk '{ print "BAT:"$4 " " $5 }' | tr -d ',')
		xsetroot -name "$DISK $MEM $BAT $IP $RX $TX $QUAL $VOL $CPU $TEMP $UP $LOCALTIME"
	else
		xsetroot -name "$DISK $MEM $IP $RX $TX $QUAL $VOL $CPU $TEMP $UP $LOCALTIME"
	fi
	sleep 10s
done &
xset -b #disable bell
xset dpms 240 240 240

# exec idesk &
(sleep 1; idesk &) & #from idesk docs
dwm 
exit $?
