# Namespace for confluentapp
class confluentapp(
) {
  
  service { 'rsyslog':
    ensure => running,
  }
  
  $hd_zookeeper_nodes = lookup('zookeeper::quorumsrv.hadoop')
  $hd_zookeeper_clientport = lookup('zookeeper::ports.hadoop.clientport')
  $hd_zookeeper_quorum = $hd_zookeeper_nodes.keys.map |$node| { "$node:$hd_zookeeper_clientport" }.join(',')

}
