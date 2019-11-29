FROM debian:buster-slim

ENV WEEWX_VERSION 3.9.2-1
ENV TZ=Europe/London

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
mkdir /tmp/setup && apt-get update && apt-get install -y \
wget \
python-mysqldb \
procps \
unzip \
python-paho-mqtt \
python-cjson

WORKDIR /tmp/setup

RUN wget http://www.weewx.com/downloads/released_versions/weewx_${WEEWX_VERSION}_all.deb && \
dpkg -i weewx_${WEEWX_VERSION}_all.deb || apt-get -y --no-install-recommends -f install && \
rm weewx_${WEEWX_VERSION}_all.deb && \
\
wget http://lancet.mit.edu/mwall/projects/weather/releases/weewx-mqtt-0.19.tgz && \
wee_extension --install weewx-mqtt-0.19.tgz && \
\
wget https://github.com/cavedon/weewx-aprs/archive/v0.1.tar.gz && \
wee_extension --install v0.1.tar.gz && \
\
wget https://github.com/morrowwm/weewxMQTT/archive/master.zip && \
unzip master.zip && \
cd weewxMQTT-master/bin/user && \
mv wxMesh.py /usr/share/weewx/user

RUN cd / && rm -rf /tmp/setup

ENTRYPOINT /usr/bin/weewxd --pidfile=/var/run/weeewx.pid /etc/weewx/weewx.conf
