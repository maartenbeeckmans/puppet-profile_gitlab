#
#
#
class profile_gitlab::deployment (
  Boolean              $manage_user,
  Boolean              $manage_group,
  String               $user_name,
  String               $user_group,
  Array[String]        $user_additional_groups,
  Stdlib::AbsolutePath $home,
  String               $ssh_key,
  String               $ssh_key_type,
) {
  if $manage_user {
    user { $user_name:
      ensure     => present,
      groups     => flatten($user_group, $user_additional_groups),
      home       => $home,
      forcelocal => true,
    }
  }

  if $manage_group {
    group { $user_group:
      ensure     => present,
      system     => true,
      forcelocal => true,
    }
  }

  file { $home:
    ensure => directory,
    owner  => $user_name,
  }
  -> file { "${home}/.ssh":
    ensure => directory,
    owner  => $user_name,
    group  => $user_group,
    mode   => '0700',
  }
  -> ssh_authorized_key { $user_name:
    key  => $ssh_key,
    type => $ssh_key_type,
    user => $user_name,
  }

  sudo::conf { $user_name:
    content => "Defaults:${user_name} !requiretty
    ${user_name} ALL=(ALL) NOPASSWD:/usr/bin/dpkg,/usr/bin/systemctl\n",
  }
}
