class openwis::staging_post_proxy (
)
{
  require openwis
  include openwis::middleware::httpd

  $staging_post_server_host_name = $openwis::staging_post_server_host_name

  openwis::common::apache_conf_file { "openwis_staging_psot.conf":
    content => epp("openwis/staging_post/apache/staging_post.conf", {
      staging_post_server_host_name => $staging_post_server_host_name
    }),
    require => Package[httpd],
    notify  => Service[httpd]
  }
}
