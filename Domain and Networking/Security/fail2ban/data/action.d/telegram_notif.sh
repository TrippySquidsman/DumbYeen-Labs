#!/bin/bash
# Version 2.0
# Send Fail2ban notifications using a Telegram Bot

while getopts "a:b:u:e:c:t:r:" opt; do
    case "$opt" in
        a)
            action=$OPTARG
        ;;
        b)
            ban=y
            ip_add_ban=$OPTARG
        ;;
        u)
            unban=y
            ip_add_unban=$OPTARG
        ;;
        e)
            email=$OPTARG
        ;;
	    c)
	        chat=$OPTARG
        ;;
        t)
	        token=$OPTARG

        r)
            reason=$OPTARG
        ;;
        ?)
            echo "Invalid option: -$OPTARG"
            exit 1
        ;;
    esac
done

# Telegram BOT Token 
telegramBotToken='$token'
# Telegram Chat ID
telegramChatID='$chat'

function talkToBot() {
    message="$1"
    curl -s -X POST "https://api.telegram.org/bot${telegramBotToken}/sendMessage" \
        -d "text=${message}" -d "chat_id=${telegramChatID}" > /dev/null 2>&1
}

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
