FROM olbat/cupsd

# Patch the sources.list
RUN sed -i "s| testing/updates|/debian-security testing-security|" /etc/apt/sources.list

# Install the additional packages we need. Avahi will be included
RUN apt-get update && apt-get install -y \
	cups \
	cups-pdf \
	inotify-tools \
	python3-cups 

# Copy canon drivers and install them
COPY drivers/linux-UFRII-drv-v520-uken-05.tar.gz /tmp

# Extract the canon drivers & install them
RUN cd /tmp && \
    tar zfvx /tmp/linux-UFRII-drv-v520-uken-05.tar.gz && \
    cd /tmp/linux-UFRII-drv-v520-uken && \
    echo y | bash install.sh

# Clean up the cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf
