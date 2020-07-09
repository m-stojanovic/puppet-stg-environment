---
profiles::firewall::rules::ipv4:
  '800 Allow Kafka hearthbeat':
    chain: INPUT
    proto: udp
    dport: 694
    action: 'accept'
  '801 allow 8182 - kafka rest proxy':
    chain: INPUT
    proto: tcp
    dport: 8182
    action: accept
  '802 allow port 80 - for DMC access via proxy':
    chain: INPUT
    proto: tcp
    dport: 80
    action: accept
  '803 allow port 8443 - for DMP access via proxy':
    chain: INPUT
    proto: tcp
    dport: 8443
    action: accept
