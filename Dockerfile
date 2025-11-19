FROM alpine:latest
RUN apk add fetchmail bash dumb-init miniserve \
    && rm -rf /var/cache/apk \
    && adduser --system prometheus-simple-imap \
    && echo "7 * * * * /usr/local/bin/update-metrics.sh" > /var/spool/cron/crontabs/prometheus-simple-imap

COPY update-metrics.sh /usr/local/bin/update-metrics.sh
COPY entrypoint.sh /entrypoint

USER prometheus-simple-imap
ENTRYPOINT [ "dumb-init", "--" ]
CMD [ "/entrypoint" ]
