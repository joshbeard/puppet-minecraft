define minecraft::plugin(
  $source,
  $install_dir,
  $plugin_name  = $title,
  $ensure       = present,
  $user,
  $group,
  $checksum        = undef,
  $checksum_type   = undef,
  $checksum_url    = undef,
  $checksum_verify = undef,
) {

  if $plugin_name =~ /^.*\.jar$/ {
    fail("minecraft plugin title ${plugin_name} must not end in '.jar'")
  }

  archive { $title:
    ensure          => $ensure,
    source          => $source,
    path            => "${install_dir}/plugins/${plugin_name}.jar",
    user            => $user,
    checksum        => $checksum,
    checksum_type   => $checksum_type,
    checksum_url    => $checksum_url,
    checksum_verify => $checksum_verify,
  }

  if $ensure == present {
    $jar_ensure = file
  } else {
    $jar_ensure = $ensure
  }

  file { "${install_dir}/plugins/${plugin_name}.jar":
    ensure  => $jar_ensure,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Archive[$title],
  }
}
