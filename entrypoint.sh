#!/bin/sh -e
/usr/sbin/rsyslogd
/usr/bin/weewxd --pidfile=/var/run/weeewx.pid -x /etc/weewx/weewx.conf
