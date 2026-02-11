# Termux-Compatible Testing Environment
# Simulates Android/Termux constraints for SACS testing

FROM ubuntu:22.04

# Simulate Termux environment
ENV HOME=/data/data/com.termux/files/home
ENV PREFIX=/data/data/com.termux/files/usr
ENV PATH=$PREFIX/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install base tools (simulate Termux packages)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    procps \
    psmisc \
    bash \
    curl \
    git \
    unzip \
    strace \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages (simulate Termux Python)
RUN pip3 install --break-system-packages \
    psutil \
    requests \
    urllib3 \
    cryptography

# Create Termux directory structure
RUN mkdir -p $HOME/.sacs/{logs,state,ci,backup} \
    && mkdir -p $HOME/.sacs_backup \
    && mkdir -p $HOME/storage/downloads

# Set working directory
WORKDIR $HOME

# Copy SACS system
COPY SACS-v6.3-ULTIMATE/edge/ $HOME/SACS-Deployment/

# Copy attack framework
COPY attacks/ /opt/attacks/
COPY cves/ /opt/cves/

# Make everything executable
RUN chmod +x $HOME/SACS-Deployment/*.{py,sh} 2>/dev/null || true \
    && chmod +x /opt/attacks/*.py 2>/dev/null || true \
    && chmod +x /opt/cves/*.sh 2>/dev/null || true

# Entry point runs SACS and attack framework
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
