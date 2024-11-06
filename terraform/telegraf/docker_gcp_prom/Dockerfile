# 1.32.2 has a bug where metrics aren't ingested
# log files have errors like:
#    2024-11-06T18:15:00Z D! [parsers.prometheus::file] Unknown format ""... Trying to continue...
# FROM telegraf:1.32.2
#
# use older version that seems to work
# TODO: do bisect and find latest version that works
FROM telegraf:1.18.3

# Install essential packages and dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        gnupg \
        iputils-ping \
        jq \
        lm-sensors \
        procps \
        snmp \
        vim \
        wget \
            && \
    rm -rf /var/lib/apt/lists/*

# Expose necessary ports for Telegraf
EXPOSE 8092/udp 8094 8125/udp
# Expose for Prometheus
EXPOSE 9273

# Copy the entrypoint script and configuration directory
COPY entrypoint.sh /entrypoint.sh
COPY ./etc /etc/telegraf

# Set default command
CMD ["/bin/bash", "/etc/telegraf/startup.sh"]
