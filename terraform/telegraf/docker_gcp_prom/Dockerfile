# telegraf bug: https://github.com/influxdata/telegraf/issues/16157
#   v130.0.0+ has a bug where things don't work right
#
# log files have errors like:
#    2024-11-06T18:15:00Z D! [parsers.prometheus::file] Unknown format ""... Trying to continue...
#
# good:
#   1.18.3, 1.20.2, 1.26.3, 1.29.5
#
# bad:
#    1.30.0, 1.30.3, 1.31.3, 1.32.2
#
# 1.29.5 is the latest version that works
# FROM telegraf:1.18.3
FROM telegraf:1.29.5

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
