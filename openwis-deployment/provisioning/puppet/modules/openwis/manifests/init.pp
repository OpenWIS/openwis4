class openwis (
  $touch_files_dir              = "/home/openwis/touchfiles",
  $logs_root_dir                = "/home/openwis/logs",
  $db_server_host_name,
  $db_user_password             = "openwis",
  $openwis_opt_dir              = "/var/opt/openwis",
  $data_services_base_url       = "http://localhost:8180",
  $management_services_base_url = "http://localhost:8180",
  $portal_server_host_name,
  $staging_post_server_host_name,
)
{
  $provisioning_root_dir = "/tmp/provisioning"
  $scripts_dir           = "${provisioning_root_dir}/scripts"
  $config_src_dir        = "${provisioning_root_dir}/config"
  $working_dir           = "${provisioning_root_dir}/working"
  $downloads_dir         = "${provisioning_root_dir}/downloads"
  $openwis_logs_dir      = "${logs_root_dir}/openwis"

  # default attributes
  File {
    owner => "openwis",
    group => "openwis",
  }

  #==========================================================================
  # Put SELinux into permissive mode
  #==========================================================================
  file_line { "SELinux permissive mode":
    path   => "/etc/selinux/config",
    match  => '^SELINUX=enforcing$',
    line   => 'SELINUX=permissive',
    notify => Exec["SELinux permissive mode"]
  }
  exec { "SELinux permissive mode":
    command     => "setenforce 0",
    user        => "root",
    path        => $::path,
    refreshonly => true
  }

  #==========================================================================
  # Install common utility packages
  #==========================================================================
  package { [unzip, wget]:
    ensure => latest,
  }

  #==========================================================================
  # Ensure OpenWIS user && group exists
  #==========================================================================
  group { openwis:
    ensure => present
  } ->
  user { openwis:
    ensure => present,
    gid    => "openwis",
    home   => "/home/openwis",
    shell  => "/bin/bash"
  }

  #==========================================================================
  # Manage folders & links
  #==========================================================================
  file { ["/home/openwis", "${openwis_opt_dir}"]:
    ensure => directory,
    owner  => "openwis",
    group  => "openwis",
    mode   => "0770"
  } ->
  file { ["${touch_files_dir}", "${logs_root_dir}", "${openwis_logs_dir}"]:
    ensure => directory,
  }

  file { ["${provisioning_root_dir}",
          "${scripts_dir}",
          "${config_src_dir}",
          "${working_dir}",
          "${downloads_dir}"]:
    ensure  => directory,
    owner  => "root",
    group  => "root"
  }

  #==============================================================================
  # Configure scripts
  #==============================================================================
  file { "${scripts_dir}/setenv.sh":
    ensure  => file,
    mode    => "0774",
    content => dos2unix(epp("openwis/scripts/setenv.sh", {
      config_src_dir => $config_src_dir,
      working_dir    => $working_dir,
      downloads_dir  => $downloads_dir
    })),
    require => File["${scripts_dir}"]
  } ->
  file { "${scripts_dir}/functions.sh":
    ensure  => file,
    mode    => "0774",
    content => dos2unix(epp("openwis/scripts/functions.sh"))
  }

}
