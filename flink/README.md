# flink

#### Table of Contents

1. [Description](#description
1. [Setup - The basics of getting started with flink](#setup)
    * [What flink affects](#what-flink-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with flink](#beginning-with-flink)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

Bigdata flink module will install and configure flink on target host.
I may also optionally install flink manager.

## Setup

### Beginning with flink

Following variables has to be set in hieradata :

**packages_ensure** - sets flink package version

**user, group** - sets configuration files ownership

**conf** - sets flink configuration directory

**env_java_home** - sets java home

**jobmanager_address** - sets job manager address

**jobmanager_port** - sets job manager port

**jobmanager_heap** - set JVM heap size (in megabytes) for the JobManager

**taskmanager_heap** - JVM heap size (in megabytes) for the TaskManagers, which are the parallel workers of the system

**taskmanager_slots** - sets number of slots per task manager. 

**taskmanager_preallocate_heap** - specifies whether task managers should allocate all managed memory when starting up

**parallelism_default** - The default parallelism to use for programs that have no parallelism specified

**jobmanager_web_port** - Job manager http port

**jobmanager_web_submit_allowed** - Allow / disable job submitting via web interface 

**state_backend** - set backed for saving application state

**state_backend_checkpointdir** - directory path for state saves

**savepoints_state_backend** - backend for save points

**savepoints_state_backend_fs_dir** - when using fs as savepoint dir backed this is directory where they will be stored

**taskmanager_network_numberOfBuffers** - The number of buffers available to the network stack

**taskmanager_tmp_dirs** - sets task managers temp directory

**fs_hdfs_haddoopconf** - haddop configuration location

**flink_masters** - list of masters

**flink_slaves** - list of slaves

If flink manager is going to be installed on machine following minimum settings has to be added to hieradata in order to provide defaults(defaults is treated as application and used to provide default parameters for flink).
When defining application you can add as many optional parameters as needed - module will place them in /etc/flink-manager/<appname>/flink-manager.conf

```
flink::manager::app:
  'defaults':
    fmversion: 'latest'
    hadoop_conf_dir: '/etc/hadoop/conf'
    yarn_session_container_suffix: 'job'
    yarn_properties_prefix: '/tmp/.yarn-properties-'
    yarn_session_tm_no: '2'
    yarn_session_tm_memory: '1024'
    yarn_session_tm_slots: '3'
    yarn_session_queue: 'default'
```
## Usage

After adding necessary variables to hiera include class flink and optionally flink::manager in roles definition

## Reference

Flink configuration: https://ci.apache.org/projects/flink/flink-docs-release-1.3/setup/config.html

Flink manager documentation: https://wiki.mapp.tools/display/DATAS/Flink+Manager

## Limitations

Do not change any default option without consulting devops team.
