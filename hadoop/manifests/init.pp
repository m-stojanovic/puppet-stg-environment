# Hadoop class namespace
class hadoop(
  $group,
  $group_yarn,
  $user_dfs,
  $user_mapred,
  $user_yarn,
  $hadoop_version,
  $mapred_version,
  $yarn_version,
  $java_home,
  $java_version,
  $mapp_yarn_am_version,
  $master_cluster_dfs,
  $master_cluster_mr,
  $journalnodeport,
  $data_mounts,
) {
  # Variables calculation
  $hd_zookeeper_nodes = lookup('zookeeper::quorumsrv.hadoop')
  $api_zookeeper_nodes = lookup('zookeeper::quorumsrv.api')
  $hd_zookeeper_clientport = lookup('zookeeper::ports.hadoop.clientport')
  $api_zookeeper_clientport = lookup('zookeeper::ports.api.clientport')

  $hd_zookeeper_list = $hd_zookeeper_nodes.keys.map |$node| { "$node" }.join(',')
  $api_zookeeper_list = $api_zookeeper_nodes.keys.map |$node| { "$node" }.join(',')
  $api_zookeeper_quorum = $api_zookeeper_nodes.keys.map |$node| { "$node:$api_zookeeper_clientport" }.join(',')
  $hd_zookeeper_quorum = $hd_zookeeper_nodes.keys.map |$node| { "$node:$hd_zookeeper_clientport" }.join(',')

  $qjournalnodes = $hd_zookeeper_nodes.keys.map |$node| { "$node:$journalnodeport" }.join(';') 
  $clustermounts = $data_mounts.map |$dm| { "$dm/hadoop-datastore/mapred/local" }.join(',')
  $yarnlocaldirs = $data_mounts.map |$dm| { "$dm/hadoop-datastore/yarn" }.join(',')
  $yarnlogdirs = $data_mounts.map |$dm| { "$dm/hadoop-datastore/yarn/logs" }.join(',')
  $datanodedatadir = $data_mounts.map |$dm|  { "$dm/hadoop-datastore/dfs/data" }.join(',')
}