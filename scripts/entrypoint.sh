#!/bin/bash

. /app/includes.sh

# rclone command
if [[ "$1" == "rclone" ]]; then
    $*

    exit 0
fi

# mailx test
if [[ "$1" == "mail" ]]; then
    export_env_file
    init_env_mail

    MAIL_SMTP_ENABLE="TRUE"
    MAIL_DEBUG="TRUE"

    if [[ -n "$2" ]]; then
        MAIL_TO="$2"
    fi

    send_mail "vaultwarden Backup Test" "Your SMTP looks configured correctly."

    exit 0
fi

if [[ "$1" == "discord" ]]; then
    export_env_file

    send_discord_test

    exit 0
fi

# restore
if [[ "$1" == "restore" ]]; then
    . /app/restore.sh

    shift
    restore $*

    exit 0
fi

function configure_timezone() {
    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" "${LOCALTIME_FILE}"
}

function configure_cron() {
    local FIND_CRON_COUNT="$(grep -c 'backup.sh' "${CRON_CONFIG_FILE}" 2> /dev/null)"
    if [[ "${FIND_CRON_COUNT}" -eq 0 ]]; then
        echo "${CRON} bash /app/backup.sh" >> "${CRON_CONFIG_FILE}"
    fi
}

init_env
check_rclone_connection
configure_timezone
configure_cron

# foreground run crond
supercronic -passthrough-logs -quiet "${CRON_CONFIG_FILE}"
