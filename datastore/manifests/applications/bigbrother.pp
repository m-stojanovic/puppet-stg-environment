# NOTE: services variable is used to query hiera for annouce path and admin port of application
# in form of datastore::applicarions::<servicename>::annouce_path.

class datastore::applications::bigbrother(
  $package,
  $version,
  $instance_name,
  $hadoop_properties,
  $storm_url,
  $crypto_secret,
  $mongodb_uri,
  $kafka_zk_path,
  $sla_number_of_last_runs,
  $sla_minimum_success_percentage,
  $sla_maximum_average_duration,
  $auth_enabled,
  $auth_saml_attr_username,
  $auth_saml_attr_email,
  $auth_saml_attr_firstname,
  $auth_saml_attr_lastname,
  $auth_saml_attr_displayname,
  $auth_saml_attr_groups,
  $auth_roles,
  $services,
) {

  motd::register{ 'datastore::bigbrother': }
  
  class { 'mongodb::server':
    package_ensure => '3.0.4',
    package_name   => 'mongodb-org-server',
    service_name   => 'mongod',
  }

  package { $package:
    ensure => $version,
    require => Class['mongodb::server'],
  }

  apt::pin{ $package:
    packages => $package,
    version => $version,
    priority => '1001',
  }

  file { '/opt/bigbrother/conf/application.conf':
    content => template('datastore/opt/bigbrother/application.conf.erb'),
    notify => Service['bigbrother'],
    require => Package[ $package ],
  }

  file { '/opt/bigbrother/conf/keystore.jks':
    source => "puppet:///modules/datastore/bigbrother/keystore.jks",
    notify => Service['bigbrother'],
    require => Package[ $package ],
  }
  
  file { '/opt/bigbrother/conf/saml-idp.xml':
    source => "puppet:///modules/datastore/bigbrother/saml-idp.xml",
    notify => Service['bigbrother'],
    require => Package[ $package ],
  }

  service { 'bigbrother':
    ensure => running,
  }

}

