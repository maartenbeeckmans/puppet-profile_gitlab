#
#
#
class profile_gitlab::runner (
  Hash                                       $runners,
  Hash                                       $runner_defaults,
  Boolean                                    $manage_repo,
  Stdlib::IP::Address                        $gitlab_runner_exporter_listen_address,
  Stdlib::Port                               $gitlab_runner_exporter_port,
  Array                                      $gitlab_runner_exporter_tags,
  Boolean                                    $manage_sd_service                     = lookup('manage_sd_service', Boolean, first, true),
) {
  file { '/etc/profile.d/gitlab_runner.sh':
    ensure  => file,
    mode    => '0644',
    content => 'GITLAB_RUNNER_DISABLE_SKEL=true',
    before  => Class['gitlab_ci_runner'],
  }

  class { 'gitlab_ci_runner':
    runners         => $runners,
    runner_defaults => $runner_defaults,
    concurrent      => $facts['processors']['count'],
    log_level       => 'info',
    check_interval  => 1,
    listen_address  => "${gitlab_runner_exporter_listen_address}:${gitlab_runner_exporter_port}",
    manage_docker   => false,
    manage_repo     => $manage_repo,
  }

  # Add custom config for session timeout
  $_session_server_options = {
    'session_server' => {
      'session_timeout' => 1800,
    }
  }
  concat::fragment { "${::gitlab_ci_runner::config_path} - session timeout":
    target  => $::gitlab_ci_runner::config_path,
    order   => 1,
    content => gitlab_ci_runner::to_toml($_session_server_options),
  }

  if $manage_sd_service {
    consul::service { 'gitlab-runner':
      checks => [
        {
          http     => "http://${gitlab_runner_exporter_listen_address}:${gitlab_runner_exporter_port}/metrics",
          interval => '10s'
        }
      ],
      port   => $gitlab_runner_exporter_port,
      tags   => $gitlab_runner_exporter_tags,
    }
  }
}
