FROM alpine:3.20

RUN apk add --no-cache autossh openssh-client

COPY .ssh/ /root/.ssh/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 700 /root/.ssh \
 && find /root/.ssh -type d -exec chmod 700 {} \; \
 && if [ -f /root/.ssh/config ]; then chmod 600 /root/.ssh/config; fi \
 && if [ -f /root/.ssh/known_hosts ]; then chmod 644 /root/.ssh/known_hosts; fi \
 && find /root/.ssh -type f \( -name "id_*" ! -name "*.pub" \) -exec chmod 600 {} \; \
 && find /root/.ssh -type f -name "*.pub" -exec chmod 644 {} \; \
 && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
