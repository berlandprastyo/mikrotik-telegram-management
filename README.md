# MikroTik Interface Monitor

A simple MikroTik RouterOS script that monitors the `running` status of all interfaces and sends a Telegram notification whenever an interface changes state.

## Features

* Monitors all MikroTik interfaces
# MikroTik Interface Status

A simple MikroTik RouterOS script that allows you to check the status of all router interfaces through a Telegram bot using the `/interface` command.

## Features

* Check all MikroTik interfaces through Telegram
* Show interface status as `Link Up` or `Link Down`
* Display the current date and time
* Use Telegram Bot API to receive and send messages
* Automatically initialize Telegram configuration after the router boots

## Files

```text
.
├── config.rsc
├── interface-update.rsc
└── README.md
```

## Telegram Command

Send the following command to the configured Telegram bot:

```text
/interface
```

The router will check all available interfaces and send a message similar to:

```text
STATUS INTERFACE
=======================
INTERFACE : ether1
STATUS INTERFACE : Link Up

INTERFACE : ether2
STATUS INTERFACE : Link Down

INTERFACE : ether3
STATUS INTERFACE : Link Up

DATE : 2026-09-22
TIME : 12:56:50 Asia/Jakarta
```

## Installation

### 1. Configure Telegram

Edit `config.rsc` and replace the placeholder values with your Telegram bot token and chat ID.

```routeros
:global telegramToken "YOUR_BOT_TOKEN"
:global telegramChatid "YOUR_CHAT_ID"
```

### 2. Import the configuration

Import `config.rsc` first:

```routeros
/import config.rsc
```

This creates the startup scheduler that initializes the required global variables when the router boots.

### 3. Import the interface script

After the configuration has been imported, import `interface-update.rsc`:

```routeros
/import interface-update.rsc
```
* Detects `Link Up` and `Link Down` status changes
* Checks interface status every 30 seconds
* Sends Telegram notifications only when a status changes
* Automatically creates a scheduler
* Uses a separate configuration file for the Telegram Bot Token and Chat ID

## How It Works

The script checks the `running` status of every interface every 30 seconds.

It does **not** send a notification every 30 seconds. A notification is only sent when an interface changes its status.

For example:

```text
Interface ether4
Link Down → Link Up
```

will trigger a Telegram notification.

## Installation

The project consists of two files:

```text
.
├── config.rsc
└── mikrotik-interface-monitor.rsc
```

### 1. Configure Telegram

Edit `config.rsc`:

```routeros
:global telegramToken "Your Telegram Bot Token"
:global telegramChatid "Your Telegram Chat ID"
```

### 2. Create a Telegram Bot

1. Open Telegram and search for `@BotFather`.
2. Send `/newbot`.
3. Follow the instructions to create a bot.
4. Copy the Bot Token provided by BotFather.

### 3. Get Your Chat ID

You can use `@RawDataBot` to get your Telegram Chat ID.

1. Open `@RawDataBot`.
2. Send `/start`.
3. Find the `chat` section in the response.
4. Copy the value of `id`.

Example:

```text
"chat": {
    "id": 123456789,
    ...
}
```

### 4. Import the Files

Import the files **in this order**:

```routeros
/import config.rsc
/import mikrotik-interface-monitor.rsc
```

`config.rsc` must be imported first because the monitoring script uses the Telegram variables defined in it.

The monitoring script will automatically create a scheduler that runs every 30 seconds.

## Telegram Notification

When an interface changes status, the script sends a message like:

```text
INTERFACE STATUS
==============================
Interface    : ether4
Status       : Link Up
Date         : 2026-09-11
Time         : 17:28:36 Asia/Jakarta
```

For example, when `ether4` changes from `Link Up` to `Link Down`:

```text
INTERFACE STATUS
==============================
Interface    : ether4
Status       : Link Down
Date         : 2026-09-11
Time         : 17:35:12 Asia/Jakarta
```

## Scheduler

The script creates a scheduler with a 30-second interval:

```routeros
/system scheduler add name=interface-monitor interval=30s
```

The scheduler runs the monitoring logic periodically and only sends a Telegram notification when an interface status changes.

## Requirements

* MikroTik RouterOS
* Telegram Bot
* Telegram Bot Token
* Telegram Chat ID
* Internet connectivity on the MikroTik router

## Security

**Do not publish your real Telegram Bot Token or Chat ID in a public repository.**

Use placeholder values in `config.rsc` before uploading the project to GitHub:

```routeros
:global telegramToken "Your Telegram Bot Token"
:global telegramChatid "Your Telegram Chat ID"
```

Keep your actual configuration private.

## Project Structure

```text
mikrotik-interface-monitor/
├── config.rsc
├── mikrotik-interface-monitor.rsc
└── README.md
```
