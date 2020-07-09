class reporting::reports::bdapps(
  $targetlocation,
  $scheduleminutes,  
) {

  require 'reporting'

  motd::register { 'reporting::bigdataapps': }

  file { "${reporting::reportroot}/bdapps":
    ensure => directory,
  }

  file { "${reporting::reportroot}/bdapps/getReport.py":
    ensure => file,
    content => template("${module_name}/bdapps/getReport.py.erb"),
    mode => '0755',
  }

  cron { 'bdapps':
    command => "${reporting::reportroot}/bdapps/getReport.py",
    user => 'root',
    minute => $scheduleminutes,
  }

}

