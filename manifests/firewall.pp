#
#
#
class profile_gitlab::firewall (
  Stdlib::Port $http_port              = $::profile_gitlab::http_port,
  Stdlib::Port $ssh_port               = $::profile_gitlab::ssh_port,
  Stdlib::Port $redis_exporter_port    = $::profile_gitlab::redis_exporter_port,
  Stdlib::Port $postgres_exporter_port = $::profile_gitlab::postgres_exporter_port,
  Stdlib::Port $gitlab_exporter_port   = $::profile_gitlab::gitlab_exporter_port,
  Stdlib::Port $gitlab_pages_port      = $::profile_gitlab::gitlab_pages_port,
  Stdlib::Port $registry_port          = $::profile_gitlab::registry_port,
  Stdlib::Port $registry_debug_port    = $::profile_gitlab::registry_debug_port,
) {
  firewall { "000${http_port} allow gitlab http":
    dport  => $http_port,
    action => 'accept',
  }

  firewall { "0${ssh_port} allow gitlab ssh":
    dport  => $ssh_port,
    action => 'accept',
  }

  firewall { "0${redis_exporter_port} allow gitlab redis exporter":
    dport  => $redis_exporter_port,
    action => 'accept',
  }

  firewall { "0${postgres_exporter_port} allow gitlab postgres exporter":
    dport  => $postgres_exporter_port,
    action => 'accept',
  }

  firewall { "0${gitlab_exporter_port} allow gitlab exporter":
    dport  => $gitlab_exporter_port,
    action => 'accept',
  }

  firewall { "0${gitlab_pages_port} allow gitlab pages":
    dport  => $gitlab_pages_port,
    action => 'accept',
  }

  firewall { "0${registry_port} allow gitlab registry":
    dport  => $registry_port,
    action => 'accept',
  }

  firewall { "0${registry_debug_port} allow gitlab registry debug":
    dport  => $registry_debug_port,
    action => 'accept',
  }
}
