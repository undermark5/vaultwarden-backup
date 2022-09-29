# for linux/amd64 platform
FROM rclone/rclone:1.59.2 AS image-linux-amd64

ENV XDG_CONFIG_HOME="/config"


# main
FROM image-linux-amd64

LABEL "repository"="https://github.com/undermark5/vaultwarden-backup" \
  "homepage"="https://github.com/undermark5/vaultwarden-backup" \
  "maintainer"="undermark5 <git@undermark5.com>"

ARG USER_NAME="backuptool"
ARG USER_ID="1100"

ENV LOCALTIME_FILE="/tmp/localtime"

COPY scripts/*.sh /app/
COPY discord.sh/discord.sh /app/

RUN chmod +x /app/*.sh \
  && mkdir -m 777 /bitwarden \
  && apk add --no-cache curl jq bash heirloom-mailx p7zip sqlite supercronic tzdata \
  && ln -sf "${LOCALTIME_FILE}" /etc/localtime \
  && addgroup -g "${USER_ID}" "${USER_NAME}" \
  && adduser -u "${USER_ID}" -Ds /bin/sh -G "${USER_NAME}" "${USER_NAME}"

ENTRYPOINT ["/app/entrypoint.sh"]
