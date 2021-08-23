#
#
#
class profile_gitlab::sd_services (
  Stdlib::IP::Address $listen_address                        = $::profile_gitlab::listen_address,

  Stdlib::Port        $http_port                             = $::profile_gitlab::http_port,
  String              $http_sd_service_name                  = $::profile_gitlab::http_sd_service_name,
  Array               $http_sd_service_tags                  = $::profile_gitlab::http_sd_service_tags,

  Stdlib::Port        $ssh_port                              = $::profile_gitlab::ssh_port,
  String              $ssh_sd_service_name                   = $::profile_gitlab::ssh_sd_service_name,
  Array               $ssh_sd_service_tags                   = $::profile_gitlab::ssh_sd_service_tags,

  Stdlib::Port        $redis_exporter_port                   = $::profile_gitlab::redis_exporter_port,
  String              $redis_exporter_sd_service_name        = $::profile_gitlab::redis_exporter_sd_service_name,
  Array               $redis_exporter_sd_service_tags        = $::profile_gitlab::redis_exporter_sd_service_tags,

  Stdlib::Port        $postgres_exporter_port                = $::profile_gitlab::postgres_exporter_port,
  String              $postgres_exporter_sd_service_name     = $::profile_gitlab::postgres_exporter_sd_service_name,
  Array               $postgres_exporter_sd_service_tags     = $::profile_gitlab::postgres_exporter_sd_service_tags,

  Stdlib::Port        $gitlab_exporter_port                  = $::profile_gitlab::gitlab_exporter_port,
  String              $gitlab_exporter_sd_service_name       = $::profile_gitlab::gitlab_exporter_sd_service_name,
  Array               $gitlab_exporter_sd_service_tags       = $::profile_gitlab::gitlab_exporter_sd_service_tags,

  Stdlib::Port        $gitlab_pages_port                     = $::profile_gitlab::gitlab_pages_port,
  String              $gitlab_pages_sd_service_name          = $::profile_gitlab::gitlab_pages_sd_service_name,
  Array               $gitlab_pages_sd_service_tags          = $::profile_gitlab::gitlab_pages_sd_service_tags,

  Stdlib::Port        $gitlab_pages_exporter_port            = $::profile_gitlab::gitlab_pages_exporter_port,
  String              $gitlab_pages_exporter_sd_service_name = $::profile_gitlab::gitlab_pages_exporter_sd_service_name,
  Array               $gitlab_pages_exporter_sd_service_tags = $::profile_gitlab::gitlab_pages_exporter_sd_service_tags,

  Stdlib::Port        $registry_port                         = $::profile_gitlab::registry_port,
  String              $registry_sd_service_name              = $::profile_gitlab::registry_sd_service_name,
  Array               $registry_sd_service_tags              = $::profile_gitlab::registry_sd_service_tags,

  Stdlib::Port        $registry_debug_port                   = $::profile_gitlab::registry_debug_port,
  String              $registry_debug_sd_service_name        = $::profile_gitlab::registry_debug_sd_service_name,
  Array               $registry_debug_sd_service_tags        = $::profile_gitlab::registry_debug_sd_service_tags,
) {
  consul::service { $http_sd_service_name:
    checks => [
      {
        tcp      => "${listen_address}:${http_port}",
        interval => '10s'
      }
    ],
    port   => $http_port,
    tags   => $http_sd_service_tags,
  }

  consul::service { $ssh_sd_service_name:
    checks => [
      {
        tcp      => "${listen_address}:22",
        interval => '10s'
      }
    ],
    port   => 22,
    tags   => $ssh_sd_service_tags,
  }

  consul::service { $redis_exporter_sd_service_name:
    checks => [
      {
        http     => "http://${listen_address}:${redis_exporter_port}/metrics",
        interval => '10s'
      }
    ],
    port   => $redis_exporter_port,
    tags   => $redis_exporter_sd_service_tags,
  }

  consul::service { $postgres_exporter_sd_service_name:
    checks => [
      {
        http     => "http://${listen_address}:${postgres_exporter_port}/metrics",
        interval => '10s'
      }
    ],
    port   => $postgres_exporter_port,
    tags   => $postgres_exporter_sd_service_tags,
  }

  consul::service { $gitlab_exporter_sd_service_name:
    checks => [
      {
        http     => "http://${listen_address}:${gitlab_exporter_port}/metrics",
        interval => '10s'
      }
    ],
    port   => $gitlab_exporter_port,
    tags   => $gitlab_exporter_sd_service_tags,
  }

  consul::service { $gitlab_pages_sd_service_name:
    checks => [
      {
        http     => "http://${listen_address}:${gitlab_pages_port}/@status",
        interval => '10s'
      }
    ],
    port   => $gitlab_pages_port,
    tags   => $gitlab_pages_sd_service_tags,
  }

  consul::service { $gitlab_pages_exporter_sd_service_name:
    checks => [
      {
        http     => "http://${listen_address}:${gitlab_pages_exporter_port}/metrics",
        interval => '10s'
      }
    ],
    port   => $gitlab_pages_exporter_port,
    tags   => $gitlab_pages_exporter_sd_service_tags,
  }

  consul::service { $registry_sd_service_name:
    checks => [
      {
        tcp      => "${listen_address}:${registry_port}",
        interval => '10s'
      }
    ],
    port   => $registry_port,
    tags   => $registry_sd_service_tags,
  }

  consul::service { $registry_debug_sd_service_name:
    checks => [
      {
        tcp      => "${listen_address}:${registry_debug_port}",
        interval => '10s'
      }
    ],
    port   => $registry_debug_port,
    tags   => $registry_debug_sd_service_tags,
  }
}
