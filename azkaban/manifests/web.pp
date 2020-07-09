class azkaban::web(
  $package,
  $version,
) {

  motd::register{ 'azkaban::web': }

  package { $package:
    ensure => $version,
  }

  file { '/opt/azkaban-web-server/conf/azkaban.properties':
    content => template('azkaban/web/azkaban.properties.erb'),
#    notify  => Service['azkaban-web'],
    require => Package['azkaban-web'],
  }

  file { '/lib/systemd/system/azkaban-web-server.service':
    ensure => present,
    source => 'puppet:///modules/azkaban/service/azkaban-web-server.service',
  }


  # service { 'azkaban-web':
  #   enable => true,
  #   ensure     => running,
  #   hasstatus  => true,
  #   hasrestart => true,
  #   require => Package['azkaban-web'],
  # }

}

