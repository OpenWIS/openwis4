class openwis::middleware::httpd ()
{
  require openwis

  $httpd_logs_dir  = "${openwis::logs_root_dir}/httpd"

  #=============================================================================
  # Install Required packages
  #=============================================================================
  package { httpd:
    ensure => latest,
  }

  #=============================================================================
  # Enable & start services
  #=============================================================================
  service { httpd:
    ensure => running,
    enable => true,
    require => Package[httpd]
  }

  #==============================================================================
  # Add the 'apache' user to the 'openwis' group
  #==============================================================================
  user { "apache":
    groups  => "openwis",
    shell   => "/sbin/nologin",
    require => [Package["httpd"], Group["openwis"]]
  }

  #==============================================================================
  # Configure logging
  #==============================================================================
  file { "${httpd_logs_dir}":
    ensure  => directory,
  } ->
  file { "/var/log/httpd":
    ensure  => link,
    target  => "${httpd_logs_dir}",
    force   => true,
    require => Package[httpd],
    notify  => Service[httpd]
  }

}
