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

#
# RUN echo "set mouse=" >> /etc/vim/vimrc && \
#     echo "set ttymouse=" >> /etc/vim/vimrc

# use CI build temporarily
# TODO: if we keep doing this, this is arm only currently
# urls for both:
# https://output.circle-artifacts.com/output/job/27375354-b842-478d-860b-45ec19b8105e/artifacts/0/build/dist/telegraf_1.33.0~3339b55c-0_arm64.deb
# https://output.circle-artifacts.com/output/job/058a41c7-7d78-401f-9886-cc02f7f34a2d/artifacts/0/build/dist/telegraf_1.33.0~3339b55c-0_amd64.deb
#
# COPY telegraf_1.33.0~3339b55c-0_arm64.deb /tmp/telegraf.deb
# RUN dpkg -i /tmp/telegraf.deb && rm /tmp/telegraf.deb

#
# use locally built binary
COPY telegraf /usr/bin/telegraf

# Expose necessary ports for Telegraf
EXPOSE 8092/udp 8094 8125/udp
# Expose for Prometheus
EXPOSE 9273

# Copy the entrypoint script and configuration directory
COPY entrypoint.sh /entrypoint.sh
COPY ./etc /etc/telegraf

# Set default command
CMD ["/bin/bash", "/etc/telegraf/startup.sh"]
