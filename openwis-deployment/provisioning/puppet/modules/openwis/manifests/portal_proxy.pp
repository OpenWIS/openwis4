class openwis::portal_proxy (
)
{
  require openwis
  include openwis::middleware::httpd

  $portal_server_host_name = $openwis::portal_server_host_name

  openwis::common::apache_conf_file { "openwis_portal.conf":
    content => epp("openwis/portal/apache/portal.conf", {
      portal_server_host_name => $portal_server_host_name
    }),
    require => Package[httpd],
    notify  => Service[httpd]
  }
}
