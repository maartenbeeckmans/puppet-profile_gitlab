#
#
#
class profile_gitlab::runner (
  Boolean                                    $manage_repo,
  String                                     $repo_name,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $repo_location,
  Hash                                       $repo_key,
  String                                     $package_name,
  String                                     $package_ensure,
  Boolean                                    $manage_pin,
  Boolean                                    $register,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $gitlab_url,
  String                                     $gitlab_token,
) {
  if $manage_repo {
    apt::source { $repo_name:
      comment  => 'Gitlab runner configuration',
      location => $repo_location,
      key      => $repo_key,
      before   => Package[$package_name],
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
      packages    => $package_name,
      origin      => $repo_location,
      priority    => 1001,
    }
  }

  if $register {
    exec { 'registering_runner':
      command    => "/usr/bin/gitlab-runner register --non-interactive --url ${gitlab_url} --registration-token ${gitlab_token} --executor docker --docker-image alpine:latest --description ${facts[networking][fqdn]} --tag-list puppet_managed --run-untagged=true --locked=false --access-level=not_protected && touch /etc/gitlab-runner/registered",
      creates    => '/etc/gitlab-runner/registered',
      subscribe  => Package[$package_name],
    }
  }
}
