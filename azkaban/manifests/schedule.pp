define azkaban::schedule(
  $project,
  $flow,
  $span,
) {

  include 'azkaban'

  exec {"Schedule - $flow":
    command     => "azkaban_cli_td schedule -p ${project} -u ${azkaban::user}:${azkaban::password}@${azkaban::azkaban_url} --bounce -e ${azkaban::job_failure_email} -d 01/01/2018 -t 22,00,PM,UTC -s ${span} ${flow}",
    path        => '/usr/local/bin',
    refreshonly => true,
  }
}
