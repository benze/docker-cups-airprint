FROM drpsychick/airprint-bridge

# Copy canon drivers and install them
COPY drivers/linux-UFRII-drv-v520-uken-05.tar.gz /tmp

# Extract the canon drivers & install them
RUN cd /tmp && \
    tar zfvx /tmp/linux-UFRII-drv-v520-uken-05.tar.gz && \
	dpkg -i /tmp/linux-UFRII-drv-v520-uken/64-bit_Driver/Debian/cnrdrvcups-ufr2-uk_5.20-1_amd64.deb && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Override the default startup script with some custom tweaks
COPY start-cups.sh /root/
