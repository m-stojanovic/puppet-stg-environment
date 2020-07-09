#!/usr/bin/python

import sys
import commands
import stat
import os

# Status of 0 == Ok, 1 == Warning, 2 == Critical
status = 0
errorMsg = ''

# check avahi daemon
output = commands.getoutput('ps -aux')
if 'avahi-daemon' in output:
        status = 2
        errorMsg = errorMsg + 'Avahi daemon running'

# check bind ipv6 only in config
ipv6_conf_file = 'empty'
if os.path.exists('/etc/sysctl.d/ipv6off.conf'):
        ipv6_conf_file = '/etc/sysctl.d/ipv6off.conf'
else:
        ipv6_conf_file = '/etc/sysctl.conf'

output = commands.getoutput('grep ipv6 ' + ipv6_conf_file)
if not 'net.ipv6.bindv6only = 0' in output and not 'net.ipv6.conf.all.disable_ipv6=1' in output:
        status = 2
        errorMsg = errorMsg + 'net.ipv6.bindv6only config not set to 0'

# check bind ipv6 only in proc
output = commands.getoutput('cat /proc/sys/net/ipv6/bindv6only')
if not '0' in output:
        status = 2
        errorMsg = errorMsg + 'net.ipv6.bindv6only proc not set to 0'

# check permission of /tmp
output = os.stat('/tmp').st_mode
if output != 17407:
        status = 2
        errorMsg = errorMsg + '/tmp not set to 41777'


# check all data mounts
mount = commands.getoutput('mount -v | grep -i /data')
if mount:
    lines = mount.split('\n')
    points = map(lambda line: line.split()[2], lines)
    # print points

    fstab = commands.getoutput('cat /etc/fstab | grep -v "#" |grep -i /data | awk \'{print $2}\'')
    entries = fstab.split('\n')
    # print entries

    failed = ''
    for entry in entries:
            if entry not in points:
                    failed = failed + ' ' +  entry
                    status = status + 1

    if status != 0:
            status = 2
            errorMsg = errorMsg + failed + ' not mounted'

# check if DATA4 is mounted
#output = commands.getoutput('ls /')
#if 'DATA4' in output:
#        output = commands.getoutput('mount')
#        if not 'DATA4' in output:
#                status = 2
#                errorMsg = errorMsg + 'DATA4 not mounted'

# ip number
ipnumber = commands.getoutput('ifconfig|grep inet|grep -e "\(172\|10\)"')

if status == 0:
    print 'Cluster node Ok.' + ipnumber
    sys.exit(0)
else:
    print errorMsg
    sys.exit(status)
