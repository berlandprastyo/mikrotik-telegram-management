# make scheduler run every 8s
/system scheduler add name=telegram-management interval=8s on-event={
:global offset

# send message after reboot
:if ([:len [/file find name="reboot-routeros.txt"]] > 0) do={
:local encode [:convert "Reboot done!" to=url]
/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/sendMessage?chat_id=" . $telegramChatid . "&text=" . $encode) keep-result=n
/file remove [find name="reboot-routeros.txt"]
}

# parse json from API telegram

:local fetch [/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/getUpdates?offset=" .$offset) as-value output=user];
:local json [:deserialize from=json value=($fetch -> "data")];


:foreach update in ($json->"result") do={
:local message ""
:local text ($update -> "message" -> "text")

# handle /interface command

:if ($text = "/interface") do={
:set $message ("=======STATUS INTERFACE=======\n")
:foreach i in=[/interface find] do={
:local name [/interface get $i name]
:local status [/interface get $i running]
:local statusText "Link Down"
:if ($status = true) do={
        :set statusText "Link Up"
}
:set $message ($message . "INTERFACE : $name\n" . \
                        "STATUS INTERFACE : $statusText\n\n")
}
:local date [/system clock get date]
:local time [/system clock get time]
:local timezone [/system clock get time-zone-name]
:set $message ($message . "DATE : $date\nTIME : $time $timezone")
}

# handle /status command

:if ($text = "/status") do={
:local uptime [/system resource get uptime]
:local version [/system resource get version]
:local architecture [/system resource get architecture-name]
:local cpuStatus
:local memStatus
:local cpu [/system resource get cpu-load]
:local freeMem ([/system resource get free-memory] / 1048576)
:local totalMem ([/system resource get total-memory] / 1048576)
:local usedMem ($totalMem - $freeMem)
:local percentMem ($usedMem * 100 / $totalMem)
:local date [/system clock get date]
:local time [/system clock get time]
:local timezone [/system clock get time-zone-name]
:if ($cpu >= 80) do={
:set cpuStatus "HIGH"
} else={
:set cpuStatus "NORMAL"
}
:if ($percentMem >= 80) do={
:set memStatus "HIGH"
} else={
:set memStatus "NORMAL"
}
:set $message ("RESOURCE STATUS\n=========================\n" . \
		"UPTIME                    : $uptime\n" . \
		"VERSION     		    : $version $architecture\n" . \
                "CPU USAGE            : $cpu" . "%\n" . \
                "CPU STATUS           : $cpuStatus\n" . \
                "TOTAL MEMORY    : $totalMem" . "MB\n" . \
		"STATUS MEMORY  : $memStatus\n" . \
                "MEMORY USAGE   : $usedMem" . "MB\n" . \
                "DATE                        : $date\n" . \
                "TIME                        : $time $timezone")


}

# handle /reboot command

:local reboot false
:if ($text = "/reboot") do={
/file print file reboot-routeros.txt
:set $reboot true
:set $message "Router will reboot..."
}

# handle /ping command

:if ([:pick $text 0 5] = "/ping") do={
:local target [:pick $text 6 [:len $text]]
:local successPing 0
:local pingStatus
:local times 0
:local avgtimesInt
:local avgtimesFlt
:foreach i in ([/ping $target count=4 as-value]) do={
:if ([:typeof ($i -> "time")] != "nothing") do={
:local mikrosekon [:tonum [:pick ($i->"time") 9 [:len ($i->"time")]]] 
:set $times ($times + $mikrosekon)
:set $successPing ($successPing + 1)
}
}
:if ($successPing > 0) do={
:local avgtimes ($times / $successPing)
:set avgtimesInt ($avgtimes / 1000)
:set avgtimesFlt ($avgtimes % 1000)
:if ($avgtimesFlt < 10) do={
:set $avgtimesFlt ("00" . $avgtimesFlt)
} else={
	:if ($avgtimesFlt < 100) do={
	:set $avgtimesFlt ("0" . $avgtimesFlt)
}
}
:set $pingStatus "REACHABLE"
} else={
:set avgtimesInt 0
:set avgtimesFlt 0
:set $pingStatus "UNREACHABLE"
}
:local pkglost (4 - $successPing)

:set $message ("PING STATUS\n===================\n" . \
		"TARGET : $target\n" . \
		"PACKETS SENT : 4\n" . \
		"RECEIVED : $successPing\n" . \
		"PACKETS LOST : $pkglost\n" . \
		"STATUS : $pingStatus\n" . \
		"AVG TIME    : $avgtimesInt" . "." . "$avgtimesFlt ms")

}

# send message

:if ($message != "") do={
:local encode [:convert $message to=url]
/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/sendMessage?chat_id=" . $telegramChatid . "&text=" . $encode) keep-result=no
}

:set $offset ($update->"update_id" + 1)

# reboot command

:if ($reboot = true) do={
/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/getUpdates?offset=" .$offset) as-value output=user
/system reboot
}


}
}
