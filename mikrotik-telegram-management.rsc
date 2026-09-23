/system scheduler add name=telegram-bot interval=8s on-event={
:global offset
:local fetch [/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/getUpdates?offset=" .$offset) as-value output=user];
:local json [:deserialize from=json value=($fetch -> "data")];
:foreach update in ($json->"result") do={
:local message ""
:local text ($update -> "message" -> "text")
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
:if ($text = "/status") do={
:local cpuStatus
:local memStatus
:local cpu [/system resource get cpu-load]
:local freeMem [/system resource get free-memory]
:local totalMem [/system resource get total-memory]
:local totalMemMB ($totalMem / 1048576)
:local usedMem (($totalMem - $freeMem) / 1048576)

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
                "CPU USAGE           : $cpu" . "%\n" . \
                "CPU STATUS           : $cpuStatus\n" . \
                "TOTAL MEMORY    : $totalMemMB" . "MB\n" . \
		"STATUS MEMORY  : $memStatus\n" . \
                "MEMORY USAGE   : $usedMem" . "MB\n" . \
                "DATE                        : $date\n" . \
                "TIME                        : $time $timezone")


}
:if ($message != "") do={

:local encode [:convert $message to=url]
/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/sendMessage?chat_id=" . $telegramChatid . "&text=" . $encode) keep-result=no

}

:set $offset ($update->"update_id" + 1)

}
}
