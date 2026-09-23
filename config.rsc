# edit your telegram bot token and chat id
/system scheduler add name=load-telegram-config start-time=startup on-event={
:global telegramToken "Your Telegram Token Bot"
:global telegramChatid "Your Telegram Chat Id"
}
