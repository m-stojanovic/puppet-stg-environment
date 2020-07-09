class azkaban::executor(
  $package,
  $version,
) {

  motd::register{'azkaban::executor':}
  
  package { $package:
    ensure => $version,
  }

  file { '/opt/azkaban-exec-server/conf/azkaban.properties':
    content => template("azkaban/executor/azkaban.properties.erb"),
    require => Package['azkaban-executor'],
    # notify => Service['azkaban-executor'],
  }

  file { '/lib/systemd/system/azkaban-exec-server.service':
    ensure => present,
    source => 'puppet:///modules/azkaban/service/azkaban-exec-server.service',
  }

  # service { 'azkaban-executor':
  #   enable => true,
  #   ensure     => running,
  #   hasstatus  => true,
  #   hasrestart => true,
  #   require => Package['azkaban-executor'],
  # }

}
