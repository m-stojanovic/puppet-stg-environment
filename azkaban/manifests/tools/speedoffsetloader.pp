class azkaban::tools::speedoffsetloader(
  $package,
  $version,
  $configfiles,
) {

  include 'dsglobals'

  motd::register { 'azkaban::tools::speedoffsetloader': }

  package{ $package:
    ensure => $version,
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  $configfiles.each |$cf, $settings| {
    file { "${cf}":
      ensure => file,
      content =>  template("${module_name}/tools/${settings['template']}"),
    }
  }
}
