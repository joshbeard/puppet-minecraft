class minecraft::params {

  case $::osfamily {
    'FreeBSD': {
      $init_path = '/usr/local/etc/rc.d'
      $init_path_suffix = ''
      $init_template = 'minecraft/minecraft_freebsd_init.erb'
    }

    default: {
      if $::systemd {
        $init_path = '/etc/systemd/system'
        $init_path_suffix = '.service'
        $init_template = 'minecraft/minecraft_systemd_service.erb'
      } else {
        $init_path = '/etc/init.d'
        $init_path_suffix = ''
        $init_template = 'minecraft/minecraft_init.erb'
      }
    }
  }
}
