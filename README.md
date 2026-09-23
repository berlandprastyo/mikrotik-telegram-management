# MikroTik Telegram Management

A MikroTik RouterOS script that allows you to check and manage the router through a Telegram bot.

## Features

* Check the status of all MikroTik interfaces using the `/interface` command
* Check router resource using the `/status` command
* Display CPU and memory status as `NORMAL` or `HIGH`
* Use an 80% threshold for CPU and memory usage
* Display the current date and time
* Restart the router using the `/reboot` command
* Send a notification before and after the router reboots
* Send and receive messages through the Telegram Bot API

## Telegram Commands

### `/interface`

Manually checks the current status of all available router interfaces.

Example:

```text
=======STATUS INTERFACE=======

INTERFACE : ether1
STATUS INTERFACE : Link Up

INTERFACE : ether2
STATUS INTERFACE : Link Up

INTERFACE : ether3
STATUS INTERFACE : Link Up

INTERFACE : ether4
STATUS INTERFACE : Link Up

INTERFACE : lo
STATUS INTERFACE : Link Up

DATE : 2026-09-23
TIME : 11:01:32 Asia/Jakarta
```

### `/status`

Manually checks the current CPU and memory usage of the router.

Example:

```text
RESOURCE STATUS
=========================
CPU USAGE           : 5%
CPU STATUS          : NORMAL
TOTAL MEMORY        : 256MB
STATUS MEMORY      : NORMAL
MEMORY USAGE       : 202MB
DATE                : 2026-09-23
TIME                : 11:01:25 Asia/Jakarta
```

### `/reboot`

Restarts the MikroTik router using the `/reboot` command.

Before the reboot, the bot sends a notification:

```text
Router will reboot...
```

After reboot, the bot sends a notification:

```text
Reboot done!
```

The reboot process may take around 1 minute, depending on the router and system startup time.

## Resource Threshold

CPU and memory usage use an 80% threshold:

```text
Usage < 80%   NORMAL
Usage >= 80%  HIGH
```

## Requirements

* MikroTik RouterOS
* Telegram Bot
* Telegram Bot Token
* Telegram Chat ID
* Internet connectivity on the MikroTik router

## Installation

### 1. Configure Telegram

Edit `config.rsc` and add your Telegram Bot Token and Chat ID:

```routeros
:global telegramToken "YOUR_BOT_TOKEN"
:global telegramChatid "YOUR_CHAT_ID"
```

### 2. Import the Configuration

```routeros
/import config.rsc
```

### 3. Import the Telegram Bot Script

```routeros
/import mikrotik-telegram-management.rsc
```

## Security

**Do not publish your real Telegram Bot Token or Chat ID in a public repository.**

Use placeholder values in `config.rsc` before uploading the project to GitHub:

```routeros
:global telegramToken "YOUR_BOT_TOKEN"
:global telegramChatid "YOUR_CHAT_ID"
```

Keep your actual Telegram configuration private.

## Project Structure

```text
mikrotik-telegram-management/
├── config.rsc
├── mikrotik-telegram-management.rsc
└── README.md
```
