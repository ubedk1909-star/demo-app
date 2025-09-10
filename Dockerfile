FROM alpine:3.19
COPY app/main.sh /usr/local/bin/main.sh
RUN chmod +x /usr/local/bin/main.sh
ENTRYPOINT ["/usr/local/bin/main.sh"]
