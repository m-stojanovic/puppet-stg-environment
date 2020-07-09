# Datastore speed offset watcher application
class datastore::applications::speedoffsetwatcher(
  $package,
  $version,
  $katopic,
  $kafkatopicnamemembership,
  $topicnameuserresponse,
  $offsetdifftolerance,
  $esalias,
  $executiondelayperiod,
  $aliaschangertimeout,
  $aliaschangerperiod,
  $swapobserverenabled,
  $swapobservertimeout,
  $swapobserver.period,
  $esbatchdeletesize,
  $jobmanageripcport,
  $loglevel,
  
) {

  motd::register{ 'datastore::speedoffsetwatcher': }
 
  # Main dependencies 
  include datastore

  apt::pin { 'speed-offset-watcher':
    packages => 'speed-offset-watcher',
    version  => $version,
    priority => '1001',
  }

  package { $package:
    ensure => $version,
    notify  => Service[''],
  }

  file { '/opt/datastore-user-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/user-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-user-read'],
  }
  
  file { '/opt/datastore-user-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/user-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-user-read'],
  }
   
  file { '/etc/default/datastore-user-read':
    ensure  => present,
    content => template ('datastore/etc/user-read/datastore-user-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-user-read'],
  }

  service { 'datastore-user-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
