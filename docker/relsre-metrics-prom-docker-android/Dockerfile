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

# Create a virtual environment
RUN python3 -m venv /opt/venv
# Enable venv
ENV PATH="/opt/venv/bin:$PATH"
# Install pipenv
RUN python3 -m pip install --upgrade pip
RUN pip install pipenv

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

RUN chown -R 10001:10001 /opt/venv /etc/android-tools

# Set default command
CMD ["/bin/bash", "/etc/telegraf/startup.sh"]
