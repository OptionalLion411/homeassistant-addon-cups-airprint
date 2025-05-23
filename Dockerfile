ARG BUILD_FROM
FROM $BUILD_FROM

LABEL io.hass.version="1.5" io.hass.type="addon" io.hass.arch="aarch64|amd64"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt update \
    && apt install -y --no-install-recommends \
        sudo \
        locales \
        cups \
        cups-filters \
        avahi-daemon \
        libnss-mdns \
        dbus \
        colord \
        printer-driver-all-enforce \
        printer-driver-all \
        printer-driver-splix \
        printer-driver-brlaser \
        printer-driver-gutenprint \
        openprinting-ppds \
        hpijs-ppds \
        hp-ppd  \
        hplip \
        printer-driver-foo2zjs \
        printer-driver-hpcups \
        printer-driver-escpr \
        cups-pdf \
        gnupg2 \
        lsb-release \
        nano \
        samba \
        bash-completion \
        procps \
        whois \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

# Add Canon cnijfilter2 driver
RUN cd /tmp \
  && if [ "$(arch)" = 'x86_64' ]; then ARCH="amd64"; else ARCH="arm64"; fi \
  && curl https://gdlp01.c-wss.com/gds/0/0100012300/02/cnijfilter2-6.80-1-deb.tar.gz -o cnijfilter2.tar.gz \
  && tar -xvf ./cnijfilter2.tar.gz cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_${ARCH}.deb \
  && mv cnijfilter2-6.80-1-deb/packages/cnijfilter2_6.80-1_${ARCH}.deb cnijfilter2_6.80-1.deb \
  && apt install ./cnijfilter2_6.80-1.deb

COPY install-hp.sh /tmp

RUN cd /tmp \
  && curl https://ftp.hp.com/pub/softlib/software13/printers/MFP170/uld-hp_V1.00.39.12_00.15.tar.gz -o uld.tar.gz \
  && tar -xvf ./uld.tar.gz \
  && mv install-hp.sh uld/
  # && mv uld/x86_64/rastertospl /usr/lib/cups/filter/ \
  # && chmod -w /usr/lib/cups/filter/rastertospl

COPY rootfs /

RUN chmod a+x /tmp/uld/install-hp.sh 
RUN "/tmp/uld/install-hp.sh"

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

# RUN chown 0:0 /usr/lib/cups/filter/rastertospl

EXPOSE 631

RUN chmod a+x /run.sh
CMD ["/run.sh"]
