# Kafka-Manager
class dockers::containers::kafkamanager(
  $conf_dir,
  $conf_file,
  $port,
  $image,
) {
 
  motd::register{ 'dockers::kafka-manager': }
 
  require 'dockers'
  include 'dsglobals'

  file { $conf_dir:
    ensure => directory,
  }

  file { "$conf_dir/$conf_file":
    ensure => file,
    content => template("${module_name}${conf_dir}${conf_file}.erb"),
  }

  docker::run { "Kafka-Manager":
    image                  => $image,
    volumes                => "${conf_dir}${conf_file}:/opt/kafka-manager/conf/application.conf",
    restart_service        => true,
    pull_on_start          => true,
    hostname               => "Kafka-Manager",
    ports                  => "${port}:${port}",
    expose                 => "${port}",
    health_check_interval  => 10,
    require                => File[ "${conf_dir}/${conf_file}" ],
  }

}