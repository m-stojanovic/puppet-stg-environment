#!/usr/bin/env python
import urllib2, json, os

conn_protocol = "http"
conn_nodename = os.uname()[1]
conn_port = "9200"
conn_endpoint = "_nodes"
conn_timeout = 4

response = False
for num in range(1,4):
  if not response:
    url = "%s://%s-es%s:%s/%s" % (conn_protocol, conn_nodename, num, conn_port, conn_endpoint)
    try:
      response = urllib2.urlopen(url, timeout=conn_timeout)
    except:
      response = False

if response:
  esnodes = json.load(response)['nodes']

  ourfact = { 'esnodes': { 'dsesd': {}, 'dsesm': {} } }
  for node in esnodes:
    if 'dsesd' in esnodes[node]['name']:
      ourfact['esnodes']['dsesd'][esnodes[node]['name']] = node
    elif 'dsesm' in esnodes[node]['name']:
      ourfact['esnodes']['dsesm'][esnodes[node]['name']] = node
  print(json.dumps(ourfact))
