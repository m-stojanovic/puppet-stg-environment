class azkaban::cli {

  package { 'python-pip': 
    ensure => installed, 
  }

  package { 'azkaban':
    ensure   => installed,
    provider => 'pip',
    require => Package['python-pip'],
  }

  # The original azkabancli does not support email notifications only for failed jobs, so we patched it
  file { '/usr/local/bin/azkaban_cli_td':
    source  => 'puppet:///modules/azkaban/azkaban_cli_td',
    mode    => '+x',
  }

}

