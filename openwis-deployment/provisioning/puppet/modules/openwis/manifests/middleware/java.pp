class openwis::middleware::java (
  
  $java_7_version = "java-1.7.0-openjdk",
  $java_8_version = "java-1.8.0-openjdk"
)
{
  require openwis

  #==============================================================================
  # Install Required packages
  #==============================================================================
 
   package { ["${java_8_version}", "${java_8_version}-devel", "${java_8_version}-headless"]:
    ensure => latest,
  } ->
   package { ["${java_7_version}", "${java_7_version}-devel", "${java_7_version}-headless"]:
    ensure => latest,
  } ->
   exec { "update-java-alternative-install-1.7.0":
    command => "sudo update-alternatives --install \"/usr/bin/java\" \"java\" \"/usr/lib/jvm/java-1.7.0-openjdk/jre/bin/java\" 0"
  } -> 
  exec { "update-java-alternative-install-1.8.0":
    command => "sudo update-alternatives --install \"/usr/bin/java\" \"java\" \"/usr/lib/jvm/java-1.8.0-openjdk/jre/bin/java\" 0"
  } ->
  exec { "update-java-alternative-set-1.7.0":
    command => "sudo update-alternatives --set java /usr/lib/jvm/java-1.7.0-openjdk/jre/bin/java"
  }
}
