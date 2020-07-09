class azkaban::database {

  include 'azkaban'

  # Install mysql server and create Azkaban database
  class{ 'mysql::server':
    root_password           => $azkaban::mysql_root_pw,
    remove_default_accounts => true,
    override_options => {
      'mysqld' => {
        'innodb_log_file_size'  => '128M',
        'innodb_large_prefix'   => 'true',
        'innodb_file_format'    => 'Barracuda',
        'innodb_file_per_table' => 'ON',
        'max_allowed_packet'    => '1024M',
      }

    }
  }

  # update innbo db size to avoind Azkaban chunking error on upload
  $innodb_size = 128
  $innodb_byte_size = $innodb_size * 1024 * 1024

  exec { 'Set innodb size':
    command   => "/etc/init.d/mysql stop; rm /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile1; /etc/init.d/mysql start",
    path      => "/usr/bin:/usr/sbin:/bin",
    onlyif    => "test -e /var/lib/mysql/ib_logfile0 -a \$(du -b /var/lib/mysql/ib_logfile0 | awk '{ print \$1 }') -ne ${innodb_log_file_byte_size}",
    require => Class['mysql::server'],
  }


  file { '/tmp/create-all-sql-3.5.0.sql':
    source  => 'puppet:///modules/azkaban/sql/create-all-sql-3.5.0.sql',
  }

  mysql::db { $azkaban::mysql_database:
    user     => $azkaban::mysql_user,
    password => $azkaban::mysql_password,
    host     => $azkaban::mysql_host,
    grant    => ['all'],
    sql      => '/tmp/create-all-sql-3.5.0.sql',
    require  => File['/tmp/create-all-sql-3.5.0.sql'],
  }

}
