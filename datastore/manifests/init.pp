class datastore { 

  require 'java'

  motd::register{ 'datastore - main': }
  
  include 'dsglobals'

  # collect often used values that requires further transformation
  # Eslatic Search
  $es_clustername = lookup('es::clustername')
  $es_nodes = lookup('es::nodes')
  $es_transport_port = lookup('es::transport_port')
  $es_http_port = lookup('es::http_port')

  $es_transport_nodes = $es_nodes.map |$node| { "${node}:${es_transport_port}" }.join(',')
  $es_http_nodes = $es_nodes.map |$node| { "${node}:${es_http_port}" }.join(',')
 
  $es_master = lookup('es::masternode')
  $es_master_port = lookup('es::masternode_port')
  $es_master_node = "${es_master}:${es_master_port}"

  # Zookeeper
  $zk_scheme = lookup('zookeeper::scheme')

  $hd_zookeeper_nodes = lookup('zookeeper::quorumsrv.hadoop')
  $api_zookeeper_nodes = lookup('zookeeper::quorumsrv.api')
  $hd_zookeeper_clientport = lookup('zookeeper::ports.hadoop.clientport')
  $api_zookeeper_clientport = lookup('zookeeper::ports.api.clientport')

  $hd_zookeeper_list = $hd_zookeeper_nodes.keys.map |$node| { "$node" }.join(',')
  $api_zookeeper_list = $api_zookeeper_nodes.keys.map |$node| { "$node" }.join(',')
  $api_zookeeper_quorum = $api_zookeeper_nodes.keys.map |$node| { "$node:$api_zookeeper_clientport" }.join(',')
  $hd_zookeeper_quorum = $hd_zookeeper_nodes.keys.map |$node| { "$node:$hd_zookeeper_clientport" }.join(',')

  # Kafka
  $kafka_nodes = lookup('kafka::brokers')
  $kafka_broker_port = lookup('kafka::broker_port')
  $kafka_brokers = $kafka_nodes.keys.map |$node| { "${node}:${kafka_broker_port}" }.join(',')
}
