#!/usr/bin/python
import commands
import sys
cmd = 'curl -s http://localhost:8079/ui/v2/server/host'
state = commands.getoutput(cmd)

# Status of 0 == Ok, 1 == Warning, 2 == Critical
status = 0
errorMsg = ''

#print state
if state == 'NORMAL':
   errorMsg = 'OK: ETL Server operating in ' + state + ' state'
   status = 0
elif state == 'SWEEPER':
   errorMsg = 'WARNING: ETL Server operating in ' + state + ' state'
   status = 1
else:
   errorMsg = 'CRITICAL: ETL Server operating in ' + state + ' state'
   status = 2

print errorMsg
sys.exit(status)