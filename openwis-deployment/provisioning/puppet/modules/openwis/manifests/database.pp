class openwis::database ()
{
  require openwis
  require openwis::middleware::postgresql

  $scripts_dir        = $openwis::scripts_dir
  $config_src_dir     = $openwis::config_src_dir
  $touch_files_dir    = $openwis::touch_files_dir
  $postgresql_version = $openwis::middleware::postgresql::postgresql_version
  $postgis_version    = $openwis::middleware::postgresql::postgis_version
  $db_user_password   = $openwis::db_user_password

  $postgis_dir = "/usr/pgsql-${postgresql_version}/share/contrib/postgis-${postgis_version}"

  # default attributes
  File {
    owner => "openwis",
    group => "openwis",
  }
  Exec {
    user    => "root",
    timeout => 0,
    path    => $::path
  }

  #==============================================================================
  # Initialise database
  #==============================================================================
  file { "${config_src_dir}/database":
      ensure  => directory,
      require => File["${config_src_dir}"]
  } ->
  file { "${config_src_dir}/database/citext.sql":
    ensure  => file,
    content => file("openwis/database/citext.sql")
  } ->
  file { "${config_src_dir}/database/create_db-postgres.sql":
    ensure  => file,
    content => file("openwis/database/create_db-postgres.sql")
  } ->
  file { "${config_src_dir}/database/create-postgis-spatialindex.sql":
    ensure  => file,
    content => file("openwis/database/create-postgis-spatialindex.sql")
  } ->
  file { "${config_src_dir}/database/data-db-postgres.sql":
    ensure  => file,
    content => file("openwis/database/data-db-postgres.sql")
  } ->
  file { "${config_src_dir}/database/openwis-3.14.sql":
    ensure  => file,
    content => file("openwis/database/openwis-3.14.sql")
  } ->
  file { "${config_src_dir}/database/openwis-roles.sql":
    ensure  => file,
    content => epp("openwis/database/openwis-roles.sql", {
        db_user_password   => $db_user_password
      })
  } ->
  file { "${config_src_dir}/database/purge.sql":
    ensure  => file,
    content => file("openwis/database/purge.sql")
  } ->
  file { "${config_src_dir}/database/schema.ddl":
    ensure  => file,
    content => file("openwis/database/schema.ddl")
  } ->
  file { "${scripts_dir}/initialise-db.sh":
    ensure  => file,
    mode    => "0774",
    content => dos2unix(epp("openwis/scripts/initialise-db.sh", {
        postgis_dir => $postgis_dir,
        touch_file  => "${touch_files_dir}/db-initialised"
      })),
    require => File["${scripts_dir}"]
  } ->
  exec { "initialise-db":
    command => "${scripts_dir}/initialise-db.sh",
    creates => "${touch_files_dir}/db-initialised",
  }

}
