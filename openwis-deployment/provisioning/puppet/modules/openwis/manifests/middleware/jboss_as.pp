class openwis::middleware::jboss_as (
  $installer_repo = "http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final",
  $installer_file = "jboss-as-7.1.1.Final.tar.gz",
)
{
  include openwis::common::systemd

  require openwis
  require openwis::middleware::java

  $downloads_dir  = $openwis::downloads_dir
  $jboss_as_dir   = "/usr/share/jboss-as"
  $jboss_logs_dir = "${openwis::logs_root_dir}/jboss"
  $touch_files_dir = $openwis::touch_files_dir

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
  # ensure target folders exist
  #==============================================================================
  file { ["${jboss_as_dir}", "/etc/jboss-as", "/var/run/jboss-as"]:
    ensure => directory,
    owner  => "openwis",
    group  => "openwis",
  }

  #==============================================================================
  # download & install JBoss-AS
  #==============================================================================
  exec { "download-installer":
    command => "wget ${installer_repo}/${installer_file} -O ${downloads_dir}/${installer_file}",
    creates => "${downloads_dir}/${installer_file}",
  } ->
  exec { "unpack-installer":
    command => "tar -xvzf ${downloads_dir}/${installer_file} -C ${jboss_as_dir} --strip-components 1",
    user    => "openwis",
    creates => "${jboss_as_dir}/LICENSE.txt",
    require => File["${jboss_as_dir}"]
  } ->
  file_line { "standalone.conf: debug JAVA_OPTS":
    path => "${jboss_as_dir}/bin/standalone.conf",
    match => '^.*dt_socket.*$',
    line => 'JAVA_OPTS="$JAVA_OPTS -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n"'
  } ->
  file_line { "standalone.conf: extra JAVA_OPTS":
    path => "${jboss_as_dir}/bin/standalone.conf",
    line => 'JAVA_OPTS="$JAVA_OPTS -Duser.timezone=UTC -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=127.0.0.1"'
  } ->
  file { "/etc/systemd/system/jboss-as.service":
    ensure  => file,
    content => dos2unix(epp("openwis/middleware/jboss/jboss-as.service", {
      jboss_as_dir => $jboss_as_dir
    })),
    notify  => Exec["systemd-daemon-reload"]
  } ->
  file { "/etc/jboss-as/jboss-as.conf":
    ensure  => file,
    content => dos2unix(file("openwis/middleware/jboss/jboss-as.conf")),
    notify  => Service["jboss-as"]
  } ->
  file { "${jboss_as_dir}/standalone/configuration/jboss-log4j.xml":
    ensure  => file,
    content => file("openwis/middleware/jboss/jboss-log4j.xml"),
    notify  => Service["jboss-as"]
  } ->
  exec { "set-http-port":
    command => 'jboss-cli.sh -c --controller=127.0.0.1:9999 --command="/socket-binding-group="standard-sockets"/socket-binding="http":write-attribute(name="port",value=8180)"',
    unless => "grep 8180 ${jboss_as_dir}/standalone/configuration/standalone-full.xml",
    path    => ["${jboss_as_dir}/bin", $::path],
    require => Service["jboss-as"],
    notify  => Exec["restart-jboss"]
  }

  #==============================================================================
  # manage folders & links
  #==============================================================================
  file { "${jboss_logs_dir}":
    ensure  => directory,
  } ->
  file { "${jboss_as_dir}/standalone/log":
    ensure  => link,
    target  => "${jboss_logs_dir}",
    require => Exec["unpack-installer"],
    notify => Service[jboss-as]
  } ->
  file { "/var/log/jboss-as":
    ensure  => link,
    target  => "${jboss_logs_dir}",
    notify => Service[jboss-as]
  }

    #==============================================================================
    # enable & start services
    #==============================================================================
    service { "jboss-as":
      ensure => running,
      enable => true
    }

    #==============================================================================
    # re-start services
    #==============================================================================
    exec { "restart-jboss":
      command     => 'service jboss-as restart',
      refreshonly => true
    }

}
