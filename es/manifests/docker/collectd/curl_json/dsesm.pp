define es::docker::collectd::curl_json::dsesm () {
  collectd::plugin::curl_json {
  'es_cluster_stats':
    url => "http://${name}:9200/_cluster/stats",
    instance => 'es-cluster-stats',
    keys => {
      'indices/count' => {'type' => 'gauge'},
      'indices/shards/primaries' => {'type' => 'gauge'},
      'indices/shards/total' => {'type' => 'gauge'},
      'nodes/count/*' => {'type' => 'gauge'},
      'nodes/jvm/mem/heap_used_in_bytes' => {'type' => 'gauge'},
      'nodes/jvm/mem/heap_max_in_bytes' => {'type' => 'gauge'},
      'nodes/jvm/threads' => {'type' => 'gauge'},
      'nodes/os/available_processors' => {'type' => 'gauge'},
      'nodes/os/allocated_processors' => {'type' => 'gauge'},
      'nodes/os/mem/total_in_bytes' => {'type' => 'gauge'},
    }
  }

  collectd::plugin::curl_json {
  'es_cluster_stats_detailed':
    url => "http://${name}:9200/_stats",
    instance => 'es-cluster-stats-detailed',
    keys => {
      '_all/primaries/get/time_in_millis' => {'type' => 'gauge'},
      '_all/primaries/get/total' => {'type' => 'gauge'},
      '_all/primaries/indexing/index_time_in_millis' => {'type' => 'gauge'},
      '_all/primaries/indexing/index_total' => {'type' => 'gauge'},
      '_all/total/docs/count' => {'type' => 'gauge'},
      '_all/total/docs/deleted' => {'type' => 'gauge'},
      '_all/total/get/total' => {'type' => 'gauge'},
      '_all/total/indexing/index_failed' => {'type' => 'gauge'},
      '_all/total/indexing/index_total' => {'type' => 'gauge'},
      '_all/total/merges/total' => {'type' => 'gauge'},
      '_all/total/query_cache/evictions' => {'type' => 'gauge'},
      '_all/total/query_cache/hit_count' => {'type' => 'gauge'},
      '_all/total/query_cache/memory_size_in_bytes' => {'type' => 'gauge'},
      '_all/total/query_cache/miss_count' => {'type' => 'gauge'},
      '_all/total/search/query_time_in_millis' => {'type' => 'gauge'},
      '_all/total/search/query_total' => {'type' => 'gauge'},
      '_all/total/store/size_in_bytes' => {'type' => 'gauge'},
    }
  }

  collectd::plugin::curl_json {
  'es_cluster_health':
    url => "http://${name}:9200/_cluster/health",
    instance => 'es-cluster-health',
    keys => {
      'timed_out' => {'type' => 'gauge'},
      'number_of_nodes' => {'type' => 'gauge'},
      'number_of_data_nodes' => {'type' => 'gauge'},
      'active_primary_shards' => {'type' => 'gauge'},
      'active_shards' => {'type' => 'gauge'},
      'relocating_shards' => {'type' => 'gauge'},
      'initializing_shards' => {'type' => 'gauge'},
      'unassigned_shards' => {'type' => 'gauge'},
      'delayed_unassigned_shards' => {'type' => 'gauge'},
      'number_of_pending_tasks' => {'type' => 'gauge'},
      'number_of_in_flight_fetch' => {'type' => 'gauge'},
      'task_max_waiting_in_queue_millis' => {'type' => 'gauge'},
      'active_shards_percent_as_number' => {'type' => 'gauge'},
    }
  }

  collectd::plugin::curl_json {
  'es_indices_stats':
    url => "http://${name}:9200/_stats",
    instance => 'es-indices-stats',
    keys => {
      'indices/*/primaries/indexing/index_total' => {'type' => 'gauge'},
      'indices/*/total/docs/count' => {'type' => 'gauge'},
      'indices/*/total/flush/total' => {'type' => 'gauge'},
      'indices/*/total/flush/total_time_in_millis' => {'type' => 'gauge'},
      'indices/*/total/get/current' => {'type' => 'gauge'},
      'indices/*/total/get/time_in_millis' => {'type' => 'gauge'},
      'indices/*/total/get/total' => {'type' => 'gauge'},
      'indices/*/total/indexing/index_failed' => {'type' => 'gauge'},
      'indices/*/total/indexing/index_total' => {'type' => 'gauge'},
      'indices/*/total/merges/current' => {'type' => 'gauge'},
      'indices/*/total/merges/current_docs' => {'type' => 'gauge'},
      'indices/*/total/merges/total' => {'type' => 'gauge'},
      'indices/*/total/query_cache/evictions' => {'type' => 'gauge'},
      'indices/*/total/query_cache/hit_count' => {'type' => 'gauge'},
      'indices/*/total/query_cache/memory_size_in_bytes' => {'type' => 'gauge'},
      'indices/*/total/query_cache/miss_count' => {'type' => 'gauge'},
      'indices/*/total/search/fetch_current' => {'type' => 'gauge'},
      'indices/*/total/search/fetch_time_in_millis' => {'type' => 'gauge'},
      'indices/*/total/search/fetch_total' => {'type' => 'gauge'},
      'indices/*/total/search/query_current' => {'type' => 'gauge'},
      'indices/*/total/search/query_total' => {'type' => 'gauge'},
      'indices/*/total/store/size_in_bytes' => {'type' => 'gauge'},
    }
  }
}