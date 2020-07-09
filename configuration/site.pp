# Provide default to package so that it depends on apt update
Package {
  provider => 'apt',
  require => Class['apt::update'],
}

$hostroles.each |$role| {
  include "roles::${role}"
}

