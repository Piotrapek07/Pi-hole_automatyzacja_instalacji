if [ "$(id -u)" -ne 0 ]; then
  echo -e "\e[1mProszę uruchom ten skrypt jako administrator (używając sudo)\e[0m"
  exit 1  
fi

sudo cat > /etc/cron.d/pihole << EOF
# Pi-hole: A black hole for Internet advertisements
# (c) 2017 Pi-hole, LLC (https://pi-hole.net)
# Network-wide ad blocking via your own hardware.
#
# Updates ad sources every week
#
# This file is copyright under the latest version of the EUPL.
# Please see LICENSE file for your rights under this license.
#
#
#
# This file is under source-control of the Pi-hole installation and update
# scripts, any changes made to this file will be overwritten when the software
# is updated or re-installed. Please make any changes to the appropriate crontab
# or other cron file snippets.

# Pi-hole: Update the ad sources once a week on Sunday at a random time in the
#          early morning. Download any updates from the adlists
#          Squash output to log, then splat the log to stdout on error to allow for
#          standard crontab job error handling.
0 */6  * * *   root    PATH="$PATH:/usr/sbin:/usr/local/bin/" pihole updateGravity >/var/log/pihole/pihole_updateGravity.log || cat /var/log/pihole/pihole_updateGravity.log

# Pi-hole: Flush the log daily at 00:00
#          The flush script will use logrotate if available
#          parameter "once": logrotate only once (default is twice)
#          parameter "quiet": don't print messages
00 00   * * *   root    PATH="$PATH:/usr/sbin:/usr/local/bin/" pihole flush once quiet

@reboot root /usr/sbin/logrotate --state /var/lib/logrotate/pihole /etc/pihole/logrotate

# Pi-hole: Grab remote and local version every 24 hours
13 18  * * *   root    PATH="$PATH:/usr/sbin:/usr/local/bin/" pihole updatechecker
@reboot root    PATH="$PATH:/usr/sbin:/usr/local/bin/" pihole updatechecker reboot
EOF

sudo service cron reload
