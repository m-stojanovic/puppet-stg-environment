# due to unability of providing us correct application name "Kinga" is used from name of main developer.
class roles::flink_kinga {

  include hadoop::roles::flinkmanager
  include flink, flink::manager, flink::applications

}
