#!/bin/bash
# Version 1.1
# Send Fail2ban notifications using a Telegram Bot

IP="$1"

# Telegram BOT Token 
telegramBotToken='............'
# Telegram Chat ID
telegramChatID='............'

function talkToBot() {
    message="$1"
    curl -s -X POST "https://api.telegram.org/bot${telegramBotToken}/sendMessage" \
        -d "text=${message}" -d "chat_id=${telegramChatID}" > /dev/null 2>&1
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 -a (start || stop) || -b IP || -u IP || -r REASON"
    exit 1;
fi

while getopts "a:b:u:r:" opt; do
    case "$opt" in
        a)
            action=$OPTARG
        ;;
        b)
            ban=y
            ip_add_ban=$OPTARG
        ;;
        e)
            email=$OPTARG
        ;;
        u)
            unban=y
            ip_add_unban=$OPTARG
        ;;
        r)
            reason=$OPTARG
        ;;
        ?)
            echo "Invalid option: -$OPTARG"
            exit 1
        ;;
    esac
done

if [[ -n ${action} ]]; then
    case "${action}" in
        start)
            talkToBot "Fail2ban just started."
        ;;
        stop)
            talkToBot "Fail2ban just stopped."
        ;;
        *)
            echo "Incorrect action option."
            exit 1;
        ;;
    esac

elif [[ ${ban} == "y" ]]; then
    notification_message=$(python3 generate_ban_notification.py "${ip_add_ban}" "${email}" "${reason}")
    talkToBot "$notification_message"
    exit 0;
elif [[ ${unban} == "y" ]]; then
    talkToBot "The IP: ${ip_add_unban} has been unbanned."
    exit 0;
elif [[ -n ${reason} ]]; then
    talkToBot "${reason}"
    exit 0;
else
    echo "No valid action specified."
fi
