#!/usr/bin/python
import sys
import yaml
import time
import getopt

try:
  opts, args = getopt.getopt(sys.argv[1:], "w:c:")
except getopt.GetoptError:
  print("Can't parse command line options, check it")
  sys.exit(2)
for opt, arg in opts:
  if opt == '-w':
    time_delta_warning=int(arg)
  elif opt == '-c':
    time_delta_critical=int(arg)

try:
  time_delta_warning
  time_delta_critical
except NameError:
  print("Deltas for warning and critical needs to be defined (-w and -c params)!")
  sys.exit(2)

last_run_summary_file="/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml"
now = time.time()

try:
  lrsf = open(last_run_summary_file, 'r')
except IOError as e:
  print("Can't read %s" % last_run_summary_file)
  print(e)
  sys.exit(2)
else:
  with lrsf:
    lrs = lrsf.read()

try:
  last_run_status = yaml.load(lrs)
except Exception as e:
  print("Encountered problem with loading content of %s" % last_run_summary_file)
  print(e)
  sys.exit(2)

try:
  last_run_time = last_run_status['time']['last_run']
  resources_failures=last_run_status['resources']['failed']
  events_failures=last_run_status['events']['failure']
except TypeError:
  print("Can't find all necessary data in %s\This might indicate Puppet Agent failing completly!" % last_run_summary_file)
  sys.exit(2)

times_delta=now-last_run_time
if times_delta > time_delta_critical:
  print("Time since last run is %d (more than CRITICAL threshold %d)" % (times_delta, time_delta_critical))
  sys.exit(2)

if times_delta > time_delta_warning:
  print("Time since last run is %d (more than WARNING threshold %d)" % (times_delta, time_delta_warning))
  sys.exit(1)

if resources_failures > 0 or events_failures > 0:
  print("There were some failures logged, check it!")
  print(lrs)
  sys.exit(1)

print("OK")