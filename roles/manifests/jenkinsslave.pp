# Jenkins slaves are used as jenkins slaves and gitlab runners
class roles::jenkinsslave{

  motd::register { 'jenkins::slave': }

  require 'java'
  require 'profiles::dockerengine'
  include 'jenkins::slave'
  
  package { 'gitlab-runner':
    ensure => latest,
  }
  
  # Perform cleanup of docker images used during runner builds
  cron { 'ImagesCleanup':
    command => '/usr/sbin/docker image rm `docker images | awk \'{ print $3}\'` --force',
    user    => 'root',
    hour    => '2',
  }
  
}