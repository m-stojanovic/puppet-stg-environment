define azkaban::upload(
  $project,
) {
  
  include 'azkaban'

  exec { "Create archive - $project":
    cwd         => "/opt/azkaban-config-${project}",
    command     => "/usr/bin/zip -FSr /tmp/${project}.zip *",
    refreshonly => true,
  }
 
  exec { "Upload project - $project":
    command     => "azkaban upload -u ${azkaban::user}:${azkaban::password}@${azkaban::azkaban_url} -cp ${project} /tmp/${project}.zip",
    path        => '/usr/local/bin/',
    refreshonly => true,
  }

}
