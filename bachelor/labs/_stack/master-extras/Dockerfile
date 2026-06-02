# Analysis container for the Master labs.
#
# A heavier Debian image that ships every host-side tool the Master labs
# call for, EXCEPT Ghidra (~400 MB graphical app -- install on the host).
#
# Built only when the "master" Compose profile is active:
#     docker compose --profile master up -d
#
# Once running, exec in:
#     docker compose exec master-extras bash
#
# Package coverage:
#   Lab 01 firmware RE       -- binwalk, squashfs-tools, qemu-user-static,
#                                binutils, file, strace
#   Lab 02 PLC ladder RE     -- gdb (binutils already in; for the disassembly
#                                step, the lab assumes Ghidra on the host --
#                                radare2 is acceptable but not bundled)
#   Lab 03 advanced protocols-- tshark; pip: scapy, boofuzz
#   Lab 04 offensive ICS     -- nmap, tcpdump, iproute2, iputils-ping;
#                                pip: pymodbus, asyncua, paho-mqtt
#   Lab 06 threat intel      -- pip: stix2
#   Lab 08 research methods  -- git, python3, pip
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# System tools first. No inline comments inside the line-continuation --
# Dockerfile would join them all into one shell command and a stray `#`
# would silence the rest of the apt-get install.
RUN apt-get update && apt-get install -y --no-install-recommends \
      binwalk \
      squashfs-tools \
      qemu-user-static \
      binutils \
      file \
      strace \
      gdb \
      tshark \
      nmap \
      tcpdump \
      iproute2 \
      iputils-ping \
      git \
      python3 \
      python3-pip \
      python3-venv \
      curl \
      ca-certificates \
      less \
      vim-tiny \
      jq \
      unzip \
 && rm -rf /var/lib/apt/lists/*

# Python tooling. Pinned where the API matters (scapy contrib, stix2,
# boofuzz). The pymodbus / asyncua / paho-mqtt mirror the student container.
RUN pip3 install --break-system-packages --no-cache-dir \
      "scapy==2.5.0" \
      "stix2==3.0.1" \
      "boofuzz==0.4.2" \
      "pymodbus[serial]==3.6.9" \
      asyncua \
      paho-mqtt

WORKDIR /labs

COPY motd /etc/motd
RUN printf '\n[ -t 0 ] && [ -r /etc/motd ] && cat /etc/motd\n' >> /etc/bash.bashrc

CMD ["bash"]
