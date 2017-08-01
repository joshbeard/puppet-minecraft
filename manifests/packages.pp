class minecraft::packages {

  if $::minecraft::manage_java {
    class { '::java':
      distribution => 'jre',
      version      => 'latest',
    }
    Class['java'] -> Minecraft::Service<| |>
  }

  ensure_packages('screen')
  Package['screen'] -> Minecraft::Service<| |>
}
