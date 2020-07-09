class roles::flink_streaming {

  include hadoop::roles::flinkmanager
  include flink, flink::manager, flink::applications

}
