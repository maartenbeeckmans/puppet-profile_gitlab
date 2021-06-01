#
#
#
class profile_gitlab (
  String                                     $initial_root_password,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $external_url,
  Stdlib::Port                               $external_port,
  Stdlib::Port                               $http_port,
  Stdlib::Port                               $ssh_port,
  String                                     $backup_on_calendar,
  Stdlib::AbsolutePath                       $install_location,
  String                                     $install_device,
  Stdlib::AbsolutePath                       $data_location,
  String                                     $data_device,
  Stdlib::AbsolutePath                       $backup_location,
  String                                     $backup_device,
  String                                     $backup_ssh_command,
  Array[Stdlib::Host]                        $trusted_proxies,
  String                                     $http_sd_service_name,
  Array                                      $http_sd_service_tags,
  String                                     $ssh_sd_service_name,
  Array                                      $ssh_sd_service_tags,
  Boolean                                    $manage_firewall_entry,
  Boolean                                    $manage_sd_service            = lookup('manage_sd_service', Boolean, first, true),
) {
  $_gitlab_rails_config = {
    'initial_root_password' => $initial_root_password,
    'backup_path'           => $backup_location,
    'trusted_proxies'       => concat($trusted_proxies, $facts['networking']['ip'], '127.0.0.1', 'localhost'])
    'gitlab_default_theme'  => 2,
    'gitlab_shell_ssh_port' => $ssh_port,
  }

  $_nginx_config = {
    'listen_https' => false,
    'listen_port'  => $http_port,
  }

  profile_base::mount{ $install_location,
    device => $install_device,
  }
  -> profile_base::mount{ $data_location:
    device => $data_device,
  }
  -> class { 'gitlab':
    external_url  => $external_url,
    external_port => $external_port,
    gitlab_rails  => $_gitlab_rails_config,
    nginx         => $_nginx_config,
  }

  if $manage_firewall_entry {
    firewall { "000${http_port} allow gitlab http":
      dport  => $http_port,
      action => 'accept',
    }
    firewall { "0${ssh_port} allow gitlab_ssh":
      dport  => $ssh_port,
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $http_sd_service_name:
      checks => [
        {
          http     => "http://${facts[networking][fqdn]}:${http_port}/-/health",
          interval => '10s'
        }
      ],
      port   => $http_port,
      tags   => $http_sd_service_tags,
    }

    consul::service { $ssh_sd_service_name:
      checks => [
        {
          tcp      => "${facts[networking][fqdn]}:${ssh_port}",
          interval => '10s'
        }
      ],
      port   => $ssh_port,
      tags   => $ssh_sd_service_tags,
    }
  }
}
