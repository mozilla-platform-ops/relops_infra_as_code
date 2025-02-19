FROM telegraf:1.33.2

# Install essential packages and dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    python3.11 \
    python3.11-venv \
    python3-pip \
    vim \
    && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
# Enable venv
ENV PATH="/opt/venv/bin:$PATH"
# Install pipenv
RUN python3 -m pip install --upgrade pip
RUN pip install pipenv
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
# COPY telegraf /usr/bin/telegraf

# Expose necessary ports for Telegraf
EXPOSE 8092/udp 8094 8125/udp
# Expose for Prometheus
EXPOSE 8000
EXPOSE 9273

# Copy the entrypoint script and configuration directory
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY ./etc /etc/telegraf
RUN chmod +x /etc/telegraf/startup.sh

RUN cd /etc; \
    git clone --depth 1 https://github.com/mozilla-platform-ops/android-tools.git; \
    cd android-tools/worker_health; \
    pipenv install --system --deploy --ignore-pipfile

# Set default command
CMD ["/bin/bash", "/etc/telegraf/startup.sh"]
