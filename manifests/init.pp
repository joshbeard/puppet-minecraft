class minecraft(
  $install_base         = '/opt/minecraft',
  $user                 = 'minecraft',      # The user account for the Minecraft service
  $group                = 'minecraft',      # The user group for the Minecraft service
  $manage_user          = true,
  $manage_group         = true,
  $user_shell           = '/bin/sh',
  $user_home            = undef,
  $manage_home          = false,
  $manage_install_base  = true,
  $manage_java          = true,
  $mode                 = '0750',
  $instances            = {},
  $instance_defaults    = {},
  $init_path            = $minecraft::params::init_path,
  $init_path_suffix     = $minecraft::params::init_path_suffix,
  $init_template        = $minecraft::params::init_template,
) inherits minecraft::params {
  $_user_home = $user_home ? {
    undef   => $install_base,
    default => $user_home,
  }

  if $manage_group {
    group { $group:
      ensure => 'present',
    }
  }

  if $manage_user {
    user { $user:
      ensure => 'present',
      shell  => $user_shell,
      home   => $_user_home,
      managehome => $manage_home,
    }
  }

  if $manage_install_base {
    file { $install_base:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => $mode,
    }
  }

  include ::minecraft::packages

  create_resources('minecraft::instance', $instances, $instance_defaults)
}
