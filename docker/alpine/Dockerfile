FROM alpine:latest

ENV TZ=UTC
WORKDIR /app
RUN set -eux; \
    touch /var/log/startup.log && chmod 666 /var/log/startup.log; \
    printf "alias ll='ls -l'" > /etc/profile.d/alias.sh; \
    printf "export PS1=' \w '" > /etc/profile.d/ps1.sh; \
    awk -F : '{OFS=FS}{if ("root" == $1 && "/root" == $6) $6="/app"; print}' /etc/passwd \
        > /tmp/out && mv /tmp/out /etc/passwd; \
    addgroup -g 101 -S nginx \
        && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
RUN apk add --no-cache \
    autoconf \
    automake \
    libc-dev \
    fcgi-dev \
    rsyslog \
    tzdata \
    nginx \
    fcgi \
    make \
    gcc \
    musl-dev
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf; \
    mkdir /run/nginx; \
    printf '' > /etc/motd; \
    printf '' > /run/nginx/nginx.pid; \
    printf '' > /var/log/nginx/access.log; \
    printf '' > /var/log/nginx/error.log; \
    printf '' > /var/lib/nginx/html/favicon.ico

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD [ "rsyslogd", "-n"]
