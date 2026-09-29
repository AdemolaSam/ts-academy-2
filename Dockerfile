FROM alpine:3.20

# bash is not in Alpine by default; procps-ng provides free and uptime -p
RUN apk add --no-cache bash procps-ng \
    && adduser -D -H appuser

WORKDIR /app
COPY app/ /app/
RUN chmod +x /app/*.sh

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --retries=1 \
    CMD ["/app/health-check.sh"]

ENTRYPOINT ["/app/diagnostic.sh"]
CMD ["help"]
