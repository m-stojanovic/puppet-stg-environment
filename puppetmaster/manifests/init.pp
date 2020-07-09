class puppetmaster {
  
  class { 'r10k':
    sources => {
      'bigdatal3' => {
        'remote'  => 'git@gitlab01.muc.ecircle.de:puppetmaster_puppet5/configuration.git',
        'basedir' => "/etc/puppetlabs/code/environments",
      },
  }

  class {'r10k::webhook::config':
    use_mcollective => false,
  }

  class {'r10k::webhook':
    use_mcollective => false,
    user            => 'root',
    group           => '0',
    require         => Class['r10k::webhook::config'],
  }

  git_webhook { 'web_post_receive_webhook' :
    ensure             => present,
    webhook_url        => 'https://puppet:8088/payload',
    token              =>  hiera('github_api_token'),
    project_name       => 'git@gitlab01.muc.ecircle.de:puppetmaster_puppet5/configuration.git',
    server_url         => 'https://gitlab01.muc.ecircle.de',
    disable_ssl_verify => true,
    provider           => 'github',
  }

}
