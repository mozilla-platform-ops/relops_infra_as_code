# Use the latest Ubuntu LTS as the base image
# FROM ubuntu:22.04
FROM telegraf:1.32.2

# Install essential packages and dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        dirmngr \
        wget \
        iputils-ping \
        snmp \
        procps \
        lm-sensors && \
    rm -rf /var/lib/apt/lists/*

# Import GPG keys to verify Telegraf package
# RUN gpg --keyserver keys.openpgp.org --recv-keys 9D539D90D3328DC7D6C8D3B9D8FF8E1F7DF8B07E || \
#     gpg --keyserver keyserver.ubuntu.com --recv-keys 9D539D90D3328DC7D6C8D3B9D8FF8E1F7DF8B07E

# # Set Telegraf version and architecture for download
# ENV TELEGRAF_VERSION=1.32.1
# RUN dpkgArch="$(dpkg --print-architecture)" && \
#     case "${dpkgArch##*-}" in \
#         amd64) ARCH='amd64' ;; \
#         arm64) ARCH='arm64' ;; \
#         *) echo "Unsupported architecture: ${dpkgArch}"; exit 1 ;; \
#     esac && \
#     wget https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz && \
#     wget https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz.asc && \
#     gpg --batch --verify telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz.asc telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz && \
#     tar -xzf telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz -C /usr/local/bin --strip-components=2 telegraf*/usr/bin/telegraf && \
#     rm -f telegraf-${TELEGRAF_VERSION}_linux_${ARCH}.tar.gz*

# Expose necessary ports for Telegraf
EXPOSE 8092/udp 8094 8125/udp

# Copy the entrypoint script and configuration directory
COPY entrypoint.sh /entrypoint.sh
COPY ./etc /etc/telegraf

# Set entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf"]