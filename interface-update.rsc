/system scheduler add name=interface-update interval=10s on-event={
:global offset
:local fetch [/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/getUpdates?offset=" .$offset) as-value output=user];
:local json [:deserialize from=json value=($fetch -> "data")];
:foreach update in ($json->"result") do={
:local text ($update -> "message" -> "text")
:if ($text = "/interface") do={

:local message ("STATUS INTERFACE\n=======================\n")
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
:local encode [:convert $message to=url]
/tool fetch url=("https://api.telegram.org/bot" . $telegramToken . "/sendMessage?chat_id=" . $telegramChatid . "&text=" . $encode) keep-result=no
}
:set $offset ($update->"update_id" + 1)

}
}
