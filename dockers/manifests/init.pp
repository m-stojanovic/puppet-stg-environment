class dockers {

  require 'profiles::dockerengine'

  # Create folder for config templates that will be mounted inside container
  file { '/opt/docker':
    ensure => directory,
  }

}
