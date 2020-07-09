class roles::flinkmanager {

  include hadoop::roles::flinkmanager
  include flink, flink::manager, flink::applications
}
