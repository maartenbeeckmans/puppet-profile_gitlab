#
#
#
class profile_gitlab::runner (
  Boolean                                    $manage_repo,
  Stdlib::IP::Address                        $gitlab_runner_exporter_listen_address,
  Stdlib::Port                               $gitlab_runner_exporter_port,
  Array                                      $gitlab_runner_exporter_tags,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $gitlab_url,
  String                                     $gitlab_token,
  Boolean                                    $manage_sd_service                     = lookup('manage_sd_service', Boolean, first, true),
) {
  file { '/etc/profile.d/gitlab_runner.sh':
    ensure  => file,
    mode    => '0644',
    content => 'GITLAB_RUNNER_DISABLE_SKEL=true',
    before  => Class['gitlab_ci_runner'],
  }

  class { 'gitlab_ci_runner':
    concurrent     => $facts['processors']['count'],
    log_level      => 'info',
    log_format     => 'text',
    check_interval => 1,
    listen_address => "${gitlab_runner_exporter_listen_address}:${gitlab_runner_exporter_port}",
    manage_docker  => false,
    manage_repo    => $manage_repo,
  }

  if $manage_sd_service {
    consul::service { 'gitlab-runner':
      checks => [
        {
          http     => "http://${gitlab_runner_exporter_listen_address}:${gitlab_runner_exporter_port}",
          interval => '10s'
        }
      ],
      port   => $gitlab_runner_exporter_port,
      tags   => $gitlab_runner_exporter_tags,
    }
  }

  gitlab_ci_runner::runner { 'runner':
    ensure  => present,
    config  => {
      url      => $gitlab_url,
      token    => $gitlab_token,
      executor => 'docker',
      limit    => $facts['processors']['count'],
      docker   => {
        image => 'alpine:latest',
      },
    },
    require => Class['gitlab_ci_runner::config'],
    notify  => Class['gitlab_ci_runner::service'],
  }
}
