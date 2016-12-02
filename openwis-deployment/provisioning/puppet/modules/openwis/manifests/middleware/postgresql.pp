class openwis::middleware::postgresql (
  $postgresql_version = 9.5,
  $postgis_version    = 2.2,
)
{
  require openwis

  $postgresql_short_version = regsubst("${postgresql_version}", '^([0-9]*)\.([0-9]*)$', '\1\2')
  $postgis_major_version    = regsubst("${postgis_version}", '^([0-9]*)\.([0-9]*)$', '\1')
  $postgis_short_version    = regsubst("${postgis_version}", '^([0-9]*)\.([0-9]*)$', '\1\2')

  $postgresql_package         = "postgresql${postgresql_short_version}"
  $postgresql_server_package  = "${postgresql_package}-server"
  $postgresql_libs_package    = "${postgresql_package}-libs"
  $postgresql_contrib_package = "${postgresql_package}-contrib"
  $postgresql_devel_package   = "${postgresql_package}-devel"
  $postgresql_service         = "postgresql-${postgresql_version}"
  $postgresql_repo            = "postgresql-${postgresql_version}"

  $data_dir = "/var/lib/pgsql/${postgresql_version}/data"

  Exec {
    user    => "root",
    timeout => 0,
    path    => $::path
  }

  #==============================================================================
  # Add PostgreSQL repository
  #==============================================================================
  yumrepo { "${postgresql_repo}":
    baseurl  => "http://yum.postgresql.org/${postgresql_version}/redhat/rhel-7-x86_64/",
    descr    => "PosrgrSQL ${postgresql_version} repository",
    enabled  => 1,
    gpgcheck => 0,
  }

  #==============================================================================
  # Install required packages
  #==============================================================================
  package { ["${postgresql_package}",
             "${postgresql_server_package}",
             "${postgresql_libs_package}",
             "${postgresql_contrib_package}",
             "${postgresql_devel_package}"]:
    ensure  => latest,
    require => Yumrepo["${postgresql_repo}"]
  } ->
  package { ["epel-release"]:
    ensure => latest,
  } ->
  package { ["postgis${postgis_major_version}_${postgresql_short_version}",
             "ogr_fdw${postgresql_short_version}", #
             "pgrouting_${postgresql_short_version}"]:
    ensure => latest,
  }

  #==============================================================================
  # Configure PostgreSQL, initialise database, enable & start services
  #==============================================================================
  exec { "initdb":
    command     => "/usr/pgsql-${postgresql_version}/bin/postgresql${postgresql_short_version}-setup initdb",
    environment => 'PGSETUP_INITDB_OPTIONS=--locale en_US.UTF-8',
    creates     => "/var/lib/pgsql/${postgresql_version}/initdb.log",
    notify      => Service["${postgresql_service}"],
    require     => Package["${postgresql_server_package}"]
  } ->
  file_line { "postgresql.conf: listen_addresses":
    path   => "${data_dir}/postgresql.conf",
    line   => "listen_addresses = '*'",
    match  => "^.?listen_addresses",
    notify => Service["${postgresql_service}"],
  } ->
  file_line { "postgresql.conf: max_stack_depth":
    ensure => present,
    path   => "${data_dir}/postgresql.conf",
    line   => "max_stack_depth = 10MB",
    match  => "^.?max_stack_depth",
    notify => Service["${postgresql_service}"],
  } ->
  file_line { "postgresql.conf: log_line_prefix":
    ensure  => present,
    path    => "${data_dir}/postgresql.conf",
    line    => "log_line_prefix = '%t'",
    match   => "^.?log_line_prefix",
    notify  => Service["${postgresql_service}"],
  } ->
  file_line { "pg_hba.conf: enable remote password connections":
    path  => "${data_dir}/pg_hba.conf",
    line  => "host    all             all             0.0.0.0/0               md5",
    match => "host    all             all             127.0.0.1/32            ident",
    notify  => Service["${postgresql_service}"],
  }

  openwis::common::service_limits { "postgresql":
    service => "${postgresql_service}",
    nofile  => "8192",
    stack   => "12582912",
  } ->
  service { "${postgresql_service}":
    ensure => running,
    enable => true,
  }
}
