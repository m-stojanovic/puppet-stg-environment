class profiles::puppetserver {

  include '::r10k'
  include '::r10k::webhook'

  motd::register { 'puppetserver': }

}

