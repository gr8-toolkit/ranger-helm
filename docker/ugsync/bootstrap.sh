#!/bin/bash
set -xe

./setup.sh
# give Ranger Admin a moment
sleep 120

# your xml edits
cp /opt/ranger_usersync/conf/ranger-ugsync-site.xml /tmp/ranger-ugsync-site.xml
xmlstarlet ed -u "//property[name='ranger.usersync.enabled']/value" -v true /tmp/ranger-ugsync-site.xml \
  > /opt/ranger_usersync/conf/ranger-ugsync-site.xml
cp /opt/ranger_usersync/conf/ranger-ugsync-site.xml /tmp/ranger-ugsync-site.xml
xmlstarlet ed -u "//property[name='ranger.usersync.group.searchenabled']/value" -v true /tmp/ranger-ugsync-site.xml \
  > /opt/ranger_usersync/conf/ranger-ugsync-site.xml

# 1) start as daemon
./ranger-usersync-services.sh start

# 2) stream logs in background
tail -f /var/log/ranger/usersync/usersync-usersync-* &
TAIL_PID=$!

# 3) find the Usersync Java PID and wait for it
#    use -n to get the newest match in case there are leftovers
SYNC_PID=$(pgrep -f -n 'org.apache.ranger.usergroupsync')
wait $SYNC_PID

# 4) once the sync run exits, kill the log tail and exit
kill $TAIL_PID
exit 0
