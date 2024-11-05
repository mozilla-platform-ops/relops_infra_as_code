FROM telegraf:1.32.2

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

# Copy the entrypoint script and configuration directory
COPY entrypoint.sh /entrypoint.sh
COPY ./etc /etc/telegraf

# Set entrypoint and default command
ENTRYPOINT ["/bin/bash", "/etc/telegraf/startup.sh"]
CMD ["/bin/bash"]