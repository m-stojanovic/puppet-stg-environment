class java(
  $homedir,
  $packages,
  $version,
) {

  motd::register{ 'bigdata-java': }

  # Accept oracle licensing terms -required to install java
  exec { 'Accept-Oracle-license':
    command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections',
    unless  => "/usr/bin/debconf-show oracle-java8-installer | grep 'shared/accepted-oracle-license-v1-1: true'",
  }

  package { $packages:
    ensure => $version,
    install_options => ['--allow-unauthenticated'],
    require => [ Exec['Accept-Oracle-license'], Apt::Source["debian_${facts['os']['distro']['codename']}_hadoopdev"] ]
  }

  apt::pin {'java':
    packages => $packages,
    version  => $version,
    priority => '1001',
  }

  file { "/etc/ld.so.conf.d/java.conf":
      content => "${homedir}/jre/lib/amd64/server",
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
  }

  exec { '/sbin/ldconfig':
    unless => '/sbin/ldconfig -p |grep libjvm.so >/dev/null 2>&1',
  }
}
