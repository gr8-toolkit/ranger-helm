#!/bin/bash
set -euo pipefail

# 1) Copy the unpacked distro into place & cd in
cp -a /tmp/ranger_usersync/. /opt/ranger_usersync
cd /opt/ranger_usersync

# 2) Initial setup
./setup.sh

# 3) Enable usersync & group-search in one xmlstarlet call
xmlstarlet ed -L \
  -u "//property[name='ranger.usersync.enabled']/value"  -v "true" \
  -u "//property[name='ranger.usersync.group.searchenabled']/value" -v "true" \
  conf/ranger-ugsync-site.xml

# 4) Start the service (daemonizes)
./ranger-usersync-services.sh start

# 5) Stream logs so kubectl logs shows everything
LOG_GLOB=(/opt/ranger_usersync/logs/usersync-*.log)
tail -n +1 -F "${LOG_GLOB[@]}" &
TAIL_PID=$!
trap 'kill $TAIL_PID' EXIT

# 6) Wait for the end-of-cycle marker that Ranger emits when one pass completes
#    (you can watch your logs to confirm this exact line appears)
until grep "Done initializing user/group source and sink"  "${LOG_GLOB[@]}"; do
  sleep 1
done

# 7) Stop the daemon and exit cleanly (exit 0)
./ranger-usersync-services.sh stop
kill $TAIL_PID
exit 0

