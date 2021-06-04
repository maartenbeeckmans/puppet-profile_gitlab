#
#
#
class profile_gitlab::backup (
  String               $on_calendar = $::profile_gitlab::backup_on_calendar,
  Stdlib::AbsolutePath $location    = $::profile_gitlab::backup_location,
  String               $device      = $::profile_gitlab::backup_device,
  String               $ssh_command = $::profile_gitlab::backup_ssh_command,
) {
  profile_base::systemd_timer { 'gitlab-backup':
    description => 'Gitlab backup',
    on_calendar => $on_calendar,
    command     => "${gitlab::rake_exec} gitlab:backup:create CRON=1"
  }

  profile_base::mount{ $location:
    device => $device,
    owner  => 'git',
    group  => 'rsnapshot',
    mode   => '0755',
  }

  include profile_rsnapshot::user

  @@rsnapshot::backup { "${facts['networking']['fqdn']} gitlab backup":
    source     => "rsnapshot@${facts['networking']['fqdn']}:${location}",
    target_dir => "${facts['networking']['fqdn']}/gitlab_backup",
    tag        => lookup('rsnapshot_tag', String, undef, 'rsnapshot'),
  }
}
