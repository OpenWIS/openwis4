define openwis::common::apache_conf_file (
  $content
)
{
  include openwis::middleware::httpd

  file { "/etc/httpd/conf.d/${name}":
    ensure  => file,
    content => $content,
    owner   => "root",
    group   => "root",
    mode    => "0444",
    require => Package[httpd],
    notify  => Service[httpd],
  }
}
