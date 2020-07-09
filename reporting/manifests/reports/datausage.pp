class reporting::reports::datausage(
  $targetlocation,
  $schedulehours,
  $esquery,
) {

  require 'reporting'
  motd::register { 'reporting::hdfsusage': }
  
  $esmasternode = lookup('es::masternode')
  $esmasterport = lookup('es::masternode_port')

  file { "${reporting::reportroot}/datausage":
    ensure => directory,
  }

  file { "${reporting::reportroot}/datausage/getReport.sh":
    ensure => file,
    content => template("${module_name}/datausage/getReport.sh.erb"),
  }

  cron { 'hdfsReport':
    command => "${reporting::reportroot}/datausage/getReport.sh",
    user => 'root',
    hour => $schedulehours,
  }

}
