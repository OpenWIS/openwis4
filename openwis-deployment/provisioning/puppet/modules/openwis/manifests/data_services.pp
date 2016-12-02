class openwis::data_services (
  $source_config_module,
  $source_managementservice_ear,
  $source_dataservice_ear,
  $source_jdbc_driver_jar,
  $staging_post_public_addr     = "http://staging_post_public_addr/not-set",
  $dissemination_wsdl_url       = undef,
  $admin_email                  = "admin@openwis.io",
)
{
  require openwis
  require openwis::middleware::jboss_as

  $scripts_dir         = $openwis::scripts_dir
  $config_src_dir      = $openwis::config_src_dir
  $openwis_opt_dir     = $openwis::openwis_opt_dir
  $touch_files_dir     = $openwis::touch_files_dir
  $jboss_as_dir        = $openwis::middleware::jboss_as::jboss_as_dir
  $openwis_logs_dir    = $openwis::openwis_logs_dir
  $db_server_host_name = $openwis::db_server_host_name
  $db_user_password    = $openwis::db_user_password
  $jdbc_driver_jar     = regsubst("${source_jdbc_driver_jar}", '^.*/(.*)$', '\1')


  notice("**** Starting data_services.pp")

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
  # ensure required folders exist
  #==============================================================================
  file { ["/home/openwis/conf",
        "/home/openwis/openwis-data-service",
        "${openwis_opt_dir}/harness",
        "${openwis_opt_dir}/harness/incoming",
        "${openwis_opt_dir}/harness/ingesting",
        "${openwis_opt_dir}/harness/ingesting/fromReplication",
        "${openwis_opt_dir}/harness/outgoing",
        "${openwis_opt_dir}/harness/working",
        "${openwis_opt_dir}/harness/working/fromReplication",
        "${openwis_opt_dir}/cache",
        "${openwis_opt_dir}/temp",
        "${openwis_opt_dir}/replication",
        "${openwis_opt_dir}/replication/sending",
        "${openwis_opt_dir}/replication/sending/local",
        "${openwis_opt_dir}/replication/sending/destinations",
        "${openwis_opt_dir}/status"
      ]:
    ensure  => directory,
    require => File[["/home/openwis", "${openwis_opt_dir}"]]
  }

  notice("**** folders exist done")

  #==============================================================================
  # OpenWIS configuration files
  #==============================================================================
  file { "/home/openwis/conf/openwis-dataservice.properties":
    ensure  => file,
    content => epp("openwis/data_service/conf/openwis-dataservice.properties", {
        openwis_opt_dir          => $openwis_opt_dir,
        staging_post_public_addr => $staging_post_public_addr,
        dissemination_wsdl_url   => $dissemination_wsdl_url,
        admin_email              => $admin_email
      }),
    require => File["/home/openwis/conf"]
  } ->
  file { "/home/openwis/conf/localdatasourceservice.properties":
    ensure  => file,
    content => file("openwis/data_service/conf/localdatasourceservice.properties")
  }

  notice("**** config files done")

  #==============================================================================
  # configure JBoss
  #==============================================================================
  notice("**** jboss config start")
  file { "${scripts_dir}/configure-jboss.sh":
    ensure  => file,
    mode    => "0774",
    content => dos2unix(epp("openwis/scripts/configure-jboss.sh", {
        touch_file             => "${touch_files_dir}/jboss-configured",
        source_config_module   => $source_config_module,
        source_jdbc_driver_jar => $source_jdbc_driver_jar,
        jboss_as_dir           => $jboss_as_dir
      })),
      require => File[["${scripts_dir}",
                       "/home/openwis/conf/localdatasourceservice.properties"]]
  } ->
  file { "${scripts_dir}/configure-jboss.cli":
    ensure  => file,
    mode    => "0774",
    content => dos2unix(epp("openwis/data_service/jboss/configure-jboss.cli", {
        openwis_logs_dir    => $openwis_logs_dir,
        db_server_host_name => $db_server_host_name,
        db_user_password    => $db_user_password,
        jdbc_driver_jar     => $jdbc_driver_jar
      }))
  } ->
  exec { "configure-jboss":
    command => "${scripts_dir}/configure-jboss.sh",
    creates => "${touch_files_dir}/jboss-configured"
  }

  notice("**** scripts_dir = ${scripts_dir}")
  notice("**** jboss config done")

  #==============================================================================
  # deploy Management Service
  #==============================================================================
  file { "${scripts_dir}/deploy-managementservice.sh":
    ensure  => file,
    mode    => "0774",
    content => dos2unix(epp("openwis/scripts/deploy-managementservice.sh", {
        touch_file                   => "${touch_files_dir}/management-service-deployed",
        source_managementservice_ear => $source_managementservice_ear,
      })),
      require => File["${scripts_dir}"]
  } ->
  exec { "deploy-managementservice":
    command => "${scripts_dir}/deploy-managementservice.sh",
    creates => "${touch_files_dir}/management-service-deployed",
    require => Exec["configure-jboss"]
  }

  #==============================================================================
  # deploy Data Service
  #==============================================================================
  file { "${scripts_dir}/deploy-dataservice.sh":
    ensure  => file,
    mode    => "0774",
    content => dos2unix(epp("openwis/scripts/deploy-dataservice.sh", {
        touch_file             => "${touch_files_dir}/data-service-deployed",
        source_dataservice_ear => $source_dataservice_ear,
      })),
      require => File["${scripts_dir}"]
  } ->
  exec { "deploy-dataservices":
    command => "${scripts_dir}/deploy-dataservice.sh",
    creates => "${touch_files_dir}/data-service-deployed",
    require => Exec["deploy-managementservice"]
  }
}
