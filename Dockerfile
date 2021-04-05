FROM debian:buster-slim

ENV WEEWX_VERSION 4.5.1
ENV TZ=Europe/London

COPY entrypoint.sh /usr/local/bin

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone\
  && mkdir /tmp/setup \
  && DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     rsyslog \
     wget \
     python-mysqldb \
     python-ephem \
     procps \
     unzip \
     python3-paho-mqtt \
     python-cjson \
     gnupg

RUN wget -qO - https://weewx.com/keys.html | apt-key add - \
  && wget -qO - https://weewx.com/apt/weewx-python3.list | tee /etc/apt/sources.list.d/weewx.list \
  && DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install weewx

WORKDIR /tmp/setup

RUN wget -O weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip \
  && wee_extension --install weewx-mqtt.zip \
  \
  && wget https://github.com/morrowwm/weewxMQTT/archive/master.zip \
  && unzip master.zip \
  && cd weewxMQTT-master/bin/user \
  && mv wxMesh.py /usr/share/weewx/user \
  \
  && wget https://github.com/cavedon/weewx-aprs/archive/v0.1.tar.gz \
  && wee_extension --install v0.1.tar.gz \
  && sed -i 's/wind_average/windSpeed/g' /usr/share/weewx/user/aprs.py \
  \
  && sed -i -e "s+-/var/log/messages+/dev/stdout+" /etc/rsyslog.conf \
  && sed -i -e "s+-/var/log/debug+/dev/stdout+" /etc/rsyslog.conf \
  && sed -i -e 's/^.*imklog/# disabled ("imklog/' /etc/rsyslog.conf \
  \
  && chown root.root /usr/local/bin/entrypoint.sh \
  && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT /usr/local/bin/entrypoint.sh
