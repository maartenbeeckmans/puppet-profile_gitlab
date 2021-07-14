#
#
#
class profile_gitlab (
  String                                     $backup_device,
  Stdlib::AbsolutePath                       $backup_location,
  String                                     $backup_on_calendar,
  String                                     $backup_ssh_command,
  Stdlib::AbsolutePath                       $data_location,
  String                                     $data_device,
  Boolean                                    $gitlab_backup,
  Stdlib::Port                               $external_ssh_port,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $external_url,
  String                                     $gitlab_email_from,
  String                                     $gitlab_email_display_name,
  String                                     $gitlab_email_reply_to,
  Stdlib::Port                               $gitlab_exporter_port,
  String                                     $gitlab_exporter_sd_service_name,
  Array                                      $gitlab_exporter_sd_service_tags,
  Stdlib::Port                               $gitlab_pages_port,
  String                                     $gitlab_pages_sd_service_name,
  Array                                      $gitlab_pages_sd_service_tags,
  Stdlib::Host                               $gitlab_ssh_host,
  Stdlib::Port                               $http_port,
  String                                     $http_sd_service_name,
  Array                                      $http_sd_service_tags,
  Stdlib::AbsolutePath                       $install_location,
  String                                     $install_device,
  Boolean                                    $ldap_auth,
  Optional[Hash]                             $ldap_servers,
  Stdlib::IP::Address                        $listen_address,
  Boolean                                    $manage_firewall_entry,
  Array[Stdlib::Host]                        $monitoring_hosts,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $pages_external_url,
  Stdlib::Port                               $postgres_exporter_port,
  String                                     $postgres_exporter_sd_service_name,
  Array                                      $postgres_exporter_sd_service_tags,
  Stdlib::Port                               $redis_exporter_port,
  String                                     $redis_exporter_sd_service_name,
  Array                                      $redis_exporter_sd_service_tags,
  Stdlib::Port                               $registry_debug_port,
  String                                     $registry_debug_sd_service_name,
  Array                                      $registry_debug_sd_service_tags,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $registry_external_url,
  Stdlib::Host                               $registry_host,
  Stdlib::Port                               $registry_port,
  String                                     $registry_sd_service_name,
  Array                                      $registry_sd_service_tags,
  Stdlib::Port                               $ssh_port,
  String                                     $ssh_sd_service_name,
  Array                                      $ssh_sd_service_tags,
  Array[Stdlib::Host]                        $trusted_proxies,
  String                                     $initial_root_password             = extlib::cache_data('profile_gitlab', 'gitlab_initial_root_password', extlib::random_password(42)), # lint:ignore:140chars
  Boolean                                    $manage_sd_service                 = lookup('manage_sd_service', Boolean, first, true),
) {
  $_alertmanager_config = {
    'enable' => false,
  }

  $_gitlab_exporter_config = {
    'enable'         => true,
    'listen_address' => $listen_address,
    'listen_port'    => $gitlab_exporter_port,
  }

  $_gitlab_pages_config = {
    'enable'       => true,
  }

  $_gitlab_rails_config = {
    'initial_root_password'                               => $initial_root_password,
    'backup_path'                                         => $backup_location,
    'backup_keep_time'                                    => '604800',
    'trusted_proxies'                                     => concat($trusted_proxies, [$listen_address, '127.0.0.1', 'localhost']), # lint:ignore:140chars
    'monitoring_whitelist'                                => concat($monitoring_hosts, [$listen_address, '127.0.0.1', 'localhost']), # lint:ignore:140chars
    'gitlab_default_theme'                                => 2,
    'gitlab_ssh_host'                                     => $gitlab_ssh_host,
    'gitlab_shell_ssh_port'                               => $external_ssh_port,
    'gitlab_default_projects_features_issues'             => false,
    'gitlab_default_projects_features_merge_requests'     => false,
    'gitlab_default_projects_features_wiki'               => false,
    'gitlab_default_projects_features_snippets'           => false,
    'gitlab_default_projects_features_builds'             => false,
    'gitlab_default_projects_features_container_registry' => false,
    'gitlab_email_from'                                   => $gitlab_email_from,
    'gitlab_email_display_name'                           => $gitlab_email_display_name,
    'gitlab_email_reply_to'                               => $gitlab_email_reply_to,
    'registry_enabled'                                    => true,
    'registry_host'                                       => $registry_host,
    'registry_path'                                       => '/var/opt/gitlab/gitlab-rails/shared/registry', # lint:ignore:140chars
    'registry_port'                                       => $registry_port,
    'time_zone'                                           => 'Europe/Brussels',
    'ldap_enabled'                                        => $ldap_auth,
    'ldap_servers'                                        => $ldap_servers,
  }

  $_grafana_config = {
    'enable' => false,
  }

  $_nginx_config = {
    'listen_https'           => false,
    'listen_port'            => $http_port,
    'redirect_http_to_https' => false,
  }

  $_node_exporter_config = {
    'enable' => false,
  }

  $_registry_config = {
    'enable'             => true,
    'registry_http_addr' => "${listen_address}:${registry_port}",
    'debug_addr'         => "${listen_address}:${registry_debug_port}",
  }

  $_redis_exporter_config = {
    'enable'         => true,
    'listen_address' => "${listen_address}:${redis_exporter_port}"
  }

  $_postgres_exporter_config = {
    'enable'         => true,
    'listen_address' => "${listen_address}:${postgres_exporter_port}"
  }

  $_prometheus_config = {
    'enable' => false,
  }

  profile_base::mount{ $install_location:
    device => $install_device,
  }
  -> profile_base::mount{ $data_location:
    device => $data_device,
  }
  -> class { 'gitlab':
    alertmanager          => $_alertmanager_config,
    external_url          => $external_url,
    gitlab_exporter       => $_gitlab_exporter_config,
    gitlab_pages          => $_gitlab_pages_config,
    gitlab_rails          => $_gitlab_rails_config,
    grafana               => $_grafana_config,
    nginx                 => $_nginx_config,
    node_exporter         => $_node_exporter_config,
    registry              => $_registry_config,
    registry_external_url => $registry_external_url,
    redis_exporter        => $_redis_exporter_config,
    pages_external_url    => $pages_external_url,
    postgres_exporter     => $_postgres_exporter_config,
    prometheus            => $_prometheus_config,
  }

  if $manage_firewall_entry {
    include profile_gitlab::firewall
  }

  if $gitlab_backup {
    include profile_gitlab::backup
  }

  if $manage_sd_service {
    include profile_gitlab::sd_services
  }
}
