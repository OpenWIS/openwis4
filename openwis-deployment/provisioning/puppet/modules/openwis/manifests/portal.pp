class openwis::portal (
    $source_portal_war
)
{
  require openwis
  include openwis::middleware::tomcat

  $scripts_dir                  = $openwis::scripts_dir
  $config_src_dir               = $openwis::config_src_dir
  $db_server_host_name          = $openwis::db_server_host_name
  $db_user_password             = $openwis::db_user_password
  $data_services_base_url       = $openwis::data_services_base_url
  $management_services_base_url = $openwis::management_services_base_url

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
  # Configure scripts
  #==============================================================================
  file { ["${config_src_dir}/portal",
          "${config_src_dir}/portal/config-node",
          "${config_src_dir}/portal/config-db",
          "${config_src_dir}/portal/config-openwis"]:
      ensure => directory
  } ->
  file { "${config_src_dir}/portal/config-node/srv.xml":
      ensure  => file,
      content => file("openwis/portal/config-node/srv.xml")
  } ->
  file { "${config_src_dir}/portal/config-db/jdbc.properties":
      ensure  => file,
      content => epp("openwis/portal/config-db/jdbc.properties", {
          db_server_host_name => $db_server_host_name,
          db_user_password    => $db_user_password,
        })
  } ->
  file { "${config_src_dir}/portal/config-db/postgres.xml":
      ensure  => file,
      content => epp("openwis/portal/config-db/postgres.xml", {
          db_server_host_name => $db_server_host_name
        })
  } ->
  file { "${config_src_dir}/portal/config-openwis/openwis.properties":
      ensure  => file,
      content => epp("openwis/portal/config-openwis/openwis.properties", {
          data_services_base_url       => $data_services_base_url,
          management_services_base_url => $management_services_base_url
        })
  } ->
  file { "${scripts_dir}/deploy-portal.sh":
      ensure  => file,
      mode    => "0774",
      content => dos2unix(epp("openwis/scripts/deploy-portal.sh", {
          source_portal_war => $source_portal_war
      }))
  }

  #==============================================================================
  # Deploy portal
  #==============================================================================
  exec { "deploy-portal":
      command => "${scripts_dir}/deploy-portal.sh",
      creates => "/usr/share/tomcat/webapps/geonetwork",
      require => [Package[tomcat], File["${scripts_dir}/deploy-portal.sh"]],
      notify  => Service[tomcat]
  }
}
