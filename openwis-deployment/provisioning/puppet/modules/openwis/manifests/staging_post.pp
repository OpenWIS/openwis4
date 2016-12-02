class openwis::staging_post (
    $source_staging_post_war
)
{
  require openwis
  include openwis::middleware::tomcat

  $scripts_dir      = $openwis::scripts_dir
  $staging_post_dir = "${openwis::openwis_opt_dir}/stagingPost"

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
  file { "${scripts_dir}/deploy-staging-post.sh":
      ensure  => file,
      mode    => "0774",
      content => dos2unix(epp("openwis/scripts/deploy-staging-post.sh", {
          source_staging_post_war => $source_staging_post_war,
          staging_post_dir        => $staging_post_dir
      }))
  }

  #==============================================================================
  # Deploy Staging Post
  #==============================================================================
  exec { "deploy-staging-post":
      command => "${scripts_dir}/deploy-staging-post.sh",
      creates => "${staging_post_dir}/WEB_INF/web.xml",
      require => [File["${scripts_dir}/deploy-staging-post.sh"], Package[tomcat]],
  } ->
  file { "/usr/share/tomcat/conf/Catalina/localhost/stagingPost.xml":
    ensure  => file,
    owner   => "tomcat",
    group   => "tomcat",
    mode    => "0444",
    content => epp("openwis/staging_post/tomcat/stagingPost.xml", {
      staging_post_dir => $staging_post_dir
    }),
    notify  => Service[tomcat],
  }
}
