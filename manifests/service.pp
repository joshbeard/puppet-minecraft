define minecraft::service (
  $instance = $title,
  $install_dir,
  $service_ensure,
  $service_enable,
  $init_path,
  $init_path_suffix,
  $init_template,
  $xmx,
  $xms,
  $user,
  $group,
  $java_args,
  $jar,
  $java_command,
) {

  file { "minecraft_${title}_init":
    ensure  => 'file',
    path    => "${init_path}/minecraft_${title}${init_path_suffix}",
    owner   => 'root',
    group   => '0',
    mode    => '0744',
    content => template($init_template),
    notify  => Service["minecraft_${title}"],
  }

  if $::osfamily == 'FreeBSD' {
    file { "/etc/rc.conf.d/minecraft_${title}":
      ensure  => 'file',
      owner   => 'root',
      group   => '0',
      mode    => '0644',
      content => template('minecraft/minecraft_rc.erb'),
      notify  => Service["minecraft_${title}"],
    }
  }

  if $::systemd {
    include ::systemd

    File["minecraft_${title}_init"] ~> Exec['systemctl-daemon-reload'] -> Service["minecraft_${title}"]
  }

  service { "minecraft_${title}":
    ensure    => $service_ensure,
    enable    => $service_enable,
    subscribe => File["minecraft_${title}_init" ],
  }
}
