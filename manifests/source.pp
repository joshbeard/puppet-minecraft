define minecraft::source (
  $source,
  $install_dir,
  $user,
  $group,
  $jar,
  $zip_file,
) {

  case $source {
    /^(\d+)\.(\d+)(\.(\d+))?$/, # Matches Semantic Versioning for vanilla Minecraft, see http://semver.org/
    /^(\d{2})w(\d{2})[a-z]$/: { # Matches current versioning scheme for vanilla Minecraft snapshots, uses the same download source URL
      $download = "https://s3.amazonaws.com/Minecraft.Download/versions/${source}/minecraft_server.${source}.jar"
    }
    # Downloads latest type of Bukkit server
    'recommended', 'rb', 'stable': {
      $download = 'http://dl.bukkit.org/latest-rb/craftbukkit.jar'
    }
    'beta', 'dev': {
      $download = "http://dl.bukkit.org/latest-${source}/craftbukkit-${source}.jar"
    }
    default: {
      $download = $source
    }
  }

  if ($zip_file) {
    archive { "${title}_minecraft_server":
      ensure       => 'present',
      source       => $download,
      path         => "${install_dir}/download.zip",
      extract_path => $install_dir,
      user         => $user,
      extract      => true,
      creates      => "${install_dir}/${jar}"
    }
  } else {
    archive { "${title}_minecraft_server":
      ensure  => 'present',
      source  => $download,
      path    => "${install_dir}/${jar}",
      user    => $user,
    }
  }

  file { "${install_dir}/${jar}":
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Archive["${title}_minecraft_server"],
  }

  file { "${install_dir}/eula.txt":
    ensure  => file,
    owner   => $user,
    group   => $group,
    content => "eula=true\n",
  }

}
