class roles::elasticsearch {

  contain 'profiles::dockerengine'
  contain 'es::docker'
  contain 'es::docker::collectd::curl_json'
  
  Class['profiles::dockerengine'] -> Class['es::docker']

}