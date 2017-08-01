define minecraft::instance (
  $instance             = $title,
  $user                 = $minecraft::user,
  $group                = $minecraft::group,
  $install_dir          = undef,
  $source               = '1.7.4',
  $service_ensure       = 'running',
  $service_enable       = true,
  $xmx                  = '1024M',
  $xms                  = '512M',
  $plugins              = {},
  $ops                  = undef,
  $banned_players       = undef,
  $banned_ips           = undef,
  $white_list_players   = undef,
  $mode                 = '0750',
  $init_path            = $minecraft::init_path,
  $init_path_suffix     = $minecraft::init_path_suffix,
  $init_template        = $minecraft::init_template,
  $plugins_defaults     = {},
  $java_args            = '',
  $jar                  = 'minecraft_server.jar',
  $server_properties    = {},
  $java_command         = 'java',
  $zip_file             = false,
) {
  $_install_dir = $install_dir ? {
    undef => "${minecraft::install_base}/${instance}",
    default => $install_dir,
  }

  # Ensures deletion of install_dir does not break module, setup for plugins
  $dirs = [ $_install_dir, "${_install_dir}/plugins" ]

  file { $dirs:
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => $mode,
  }

  minecraft::source { $title:
    source      => $source,
    install_dir => $_install_dir,
    user        => $user,
    group       => $group,
    jar         => $jar,
    require     => File[$dirs],
    zip_file    => $zip_file,
  }

  if $ops != undef {
    minecraft_setting { "${_install_dir}/ops.json":
      value          => $ops,
      id_property    => 'name',
      add_command    => 'op %s',
      remove_command => 'deop %s',
      user           => $user,
      instance       => $instance,
      require        => Minecraft::Service[$instance],
    }
  }
  if $banned_ips != undef {
    minecraft_setting { "${_install_dir}/banned-ips.json":
      value          => $banned_ips,
      id_property    => 'ip',
      add_command    => 'ban-ip %s',
      remove_command => 'pardon-ip %s',
      user           => $user,
      instance       => $instance,
      require        => Minecraft::Service[$instance],
    }
  }
  if $banned_players != undef {
    minecraft_setting { "${_install_dir}/banned-players.json":
      value          => $banned_players,
      id_property    => 'name',
      add_command    => 'ban %s',
      remove_command => 'pardon %s',
      user           => $user,
      instance       => $instance,
      require        => Minecraft::Service[$instance],
    }
  }
  if $white_list_players != undef {
    minecraft_setting { "${_install_dir}/whitelist.json":
      value          => $white_list_players,
      id_property    => 'name',
      add_command    => 'whitelist add %s',
      remove_command => 'whitelist remove %s',
      user           => $user,
      instance       => $instance,
      require        => Minecraft::Service[$instance],
    }
  }

  file { "${_install_dir}/server.properties":
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    mode    => '0660',
    require => Minecraft::Source[$title],
  }

  # Build an array of augeas commands for the $server_properties hash. Each is 'set "<key>" "<value>"'
  $server_properties_changes = suffix(
    prefix(
      join_keys_to_values($server_properties, '" "'),
      'set "'
    ),
    '"'
  )
  augeas { "minecraft-${instance}-server-properties":
    lens    => 'Properties.lns',
    incl    => "${_install_dir}/server.properties",
    changes => $server_properties_changes,
    notify  => Minecraft::Service[$instance],
    require => File["${_install_dir}/server.properties"],
  }

  minecraft::service { $title:
    instance         => $instance,
    install_dir      => $_install_dir,
    service_ensure   => $service_ensure,
    service_enable   => $service_enable,
    init_path        => $init_path,
    init_path_suffix => $init_path_suffix,
    init_template    => $init_template,
    xmx              => $xmx,
    xms              => $xms,
    user             => $user,
    group            => $group,
    java_args        => $java_args,
    jar              => $jar,
    java_command     => $java_command,
    subscribe        => Minecraft::Source[$title],
  }

  if $plugin_defaults != undef {
    $_plugin_defaults = $plugin_defaults
  } else {
    $_plugin_defaults = {
      install_dir => $_install_dir,
      user        => $user,
      group       => $group,
      ensure      => $present,
      require     => Minecraft::Source[$title],
      notify      => Minecraft::Service[$title],
    }
  }

  $_plugins = prefix($plugins, "${title}__")
  create_resources('minecraft::plugin', $_plugins, $_plugin_defaults)
}
