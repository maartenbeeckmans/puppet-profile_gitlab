#
#
#
class profile_gitlab::runner (
  Boolean                                    $manage_repo,
  Boolean                                    $repo_name,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $repo_location,
  Hash                                       $repo_key,
  String                                     $package_name,
  String                                     $package_ensure,
  Boolean                                    $manage_pin,
) {
  if $manage_repo {
    apt::source { $repo_name:
      comment  => 'Gitlab runner configuration',
      location => $repo_location,
      key      => $repo_key,
    }
  }

  file { '/etc/profile.d/gitlab_runner.sh':
    ensure  => file,
    mode    => '0644',
    content => 'GITLAB_RUNNER_DISABLE_SKEL=true',
    before  => Package[$package_name],
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  if $manage_pin {
    apt::pin { 'gitlab-runner-pin':
      explanation => 'Prefer GitLab provided packages over Debian native ones',
      package     => $package_name,
      origin      => $repo_location,
      priority    => 1001,
    }
  }
}
