class dockers::containers::cerebro(
  $image,
  $conf_dir,
  $conf_file,
  $port,
) {

  motd::register { 'dockers::cerebro': }

  $escluster_name = lookup('es::clustername')
  $esmaster = lookup('es::masternode')
  $esmaster_port = lookup('es::masternode_port')

  file { $conf_dir:
    ensure => directory,
  }

  file { "$conf_dir/$conf_file":
    ensure => file,
    content => template("${module_name}${conf_dir}${conf_file}.erb"),
  }
  
  docker::run { "Cerebro":
    image                  => $image,
    volumes                => "${conf_dir}${conf_file}:/opt/cerebro/conf/application.conf",
    restart_service        => true,
    pull_on_start          => true,
    hostname               => "Cerebro",
    expose                 => "${port}",
    ports                  => "${port}:${port}",
    health_check_interval  => 10,
    require                => File[ "${conf_dir}/${conf_file}" ],
  }


}