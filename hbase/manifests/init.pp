class hbase (
  $hbase_version,
  $maintenance,
) {

  require 'java'

  $zk_scheme = lookup('zookeeper::scheme')

  $hd_zookeeper_nodes = lookup('zookeeper::quorumsrv.hadoop')
  $hd_zookeeper_clientport = lookup('zookeeper::ports.hadoop.clientport')
  $hd_zookeeper_peerport = lookup('zookeeper::ports.hadoop.peerport')
  $hd_zookeeper_leaderport = lookup('zookeeper::ports.hadoop.leaderport')

  $hd_zookeeper_list = $hd_zookeeper_nodes.keys.map |$node| { "$node" }.join(',')
  $hd_zookeeper_quorum = $hd_zookeeper_nodes.keys.map |$node| { "$node:$hd_zookeeper_clientport" }.join(',')
}