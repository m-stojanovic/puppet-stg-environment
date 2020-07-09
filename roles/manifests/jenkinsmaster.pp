class roles::jenkinsmaster{

  motd::register { 'jenkins::master': }

  require 'java'
  require 'profiles::dockerengine'
  include 'jenkins'
  include 'jenkins::master'

}
