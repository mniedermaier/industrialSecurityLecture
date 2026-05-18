# Tiny Debian-based image with all CLI tools used by the labs.
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-venv \
      tcpdump tshark nmap iproute2 iputils-ping \
      curl ca-certificates less vim-tiny \
      mosquitto-clients procps \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install --break-system-packages --no-cache-dir \
      "pymodbus[serial]==3.6.9" \
      asyncua \
      paho-mqtt

WORKDIR /labs
CMD ["bash"]
