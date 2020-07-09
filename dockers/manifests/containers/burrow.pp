# Burrow - tool for kafka lag monitoring
class dockers::containers::burrow(
  $conf_dir,
  $kafka_version,
  $conf_file,
  $port,
  $clustername,
  $cluster_classname,
  $consumer_classname,
  $consumers,
  $image,
) {
 
  motd::register{ 'dockers::burrow': }
 
  require 'dockers'
  include 'dsglobals'
  
  $zookeepers = $dsglobals::hd_zookeeper_nodes.keys.map |$node| { "\"${node}:${dsglobals::hd_zookeeper_clientport}\"" }.join(',')
  $kafkas =  $dsglobals::kafka_nodes.keys.map |$node| { "\"${node}:${dsglobals::kafka_broker_port}\"" }.join(',')
   

  file { $conf_dir:
    ensure => directory,
  }

  file { "$conf_dir/$conf_file":
    ensure => file,
    content => template("${module_name}${conf_dir}${conf_file}.erb"),
  }

  docker::run { "Burrow":
    image                  => $image,
    volumes                => "/opt/docker/ds-kafka-burrow/burrow.toml:/etc/burrow/burrow.toml",
    restart_service        => true,
    pull_on_start          => true,
    hostname               => "Burrow",
    expose                 => "${port}",
    ports                  => "${port}:${port}",
    health_check_interval  => 10,
    require                => File[ "${conf_dir}/${conf_file}" ],
  }

}


