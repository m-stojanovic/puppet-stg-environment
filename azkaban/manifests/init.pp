# Azkaban class namespace
class azkaban(
  $mysql_port,
  $mysql_host,
  $mysql_database,
  $mysql_password,
  $mysql_user,
  $mysql_root_pw,
  $mail_sender,
  $mail_host,
  $job_success_email,
  $job_failure_email,
  $user,
  $password,
  $executor_port,
  $http_port,
  $instancename,
  $instancelabel,
  $azkaban_url,
  $timezone,
  $schedulefolder,
) {

  include 'dsglobals'  
  contain 'azkaban::database'
  contain 'azkaban::executor'
  contain 'azkaban::web'
  Class['azkaban::database'] -> Class['azkaban::executor'] -> Class['azkaban::web']

  # This is artificial solution to scheduling in Azkaban - schedule should only be updated on when changed in hiera.
  # To do this we need to send notify to defined upload type which has refreshonly option enabled.
  # Since we cannot get current flow time span from azkaban_cli - we create file for every flow will contain span
  # on change it will trigged schedule update.
  # All schedule files will be kept in defined folder.

  file { $schedulefolder:
    ensure => directory,
  }

}
