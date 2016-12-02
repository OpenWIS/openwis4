Package {
	allow_virtual => false,
}

# add the 'vagrant' user to the 'openwis' group
# this is needed to allow the vagrant user to access openwis files
user { "vagrant":
	groups  => "openwis",
}

# ensure that the old provisioning working folders are removed
file {["/vagrant/provisioning/config",
       "/vagrant/provisioning/downloads",
			 "/vagrant/provisioning/scripts",
			 "/vagrant/provisioning/working"]:
	ensure => absent,
	force => true
}

# create symlinks to the deployment scripts in the vagrant user's bin folder
# so that they can be executed manually
file {"/home/vagrant/bin":
  ensure => directory,
  owner  => "vagrant",
  group  => "vagrant",
} ->
link_script { "initialise-db":
} ->
link_script { "configure-jboss":
} ->
link_script { "deploy-dataservices":
} ->
link_script { "deploy-managementservices":
} ->
link_script { "deploy-portal":
}

# clear down the logs folders & re-start the corresponding services (where appropriate)
# this is needed as the logs get written to vagrant shared folders, but the services
# get auto-started before the folders are mounted.
clear_logs { "jboss-as":
	logs_folders => ["/home/openwis/logs/jboss", "/home/openwis/logs/openwis"]
} ->
clear_logs { "tomcat":
	logs_folders => ["/home/openwis/logs/tomcat"]
}
clear_logs { "httpd":
	logs_folders => ["/home/openwis/logs/httpd"]
}

#===============================================================================
define link_script ()
{
	file {"/home/vagrant/bin/${name}":
    ensure => link,
    target => "/tmp/provisioning/scripts/${name}.sh"
	}
}

#===============================================================================
define clear_logs (
	$logs_folders = []
)
{
	exec { "stop service ${name}":
		command => "systemctl stop ${name}",
		onlyif  => "systemctl is-enabled ${name}",
		user    => "root",
		path    => $::path
	}

	$logs_folders.each |String $logs_folder| {
		exec { "clear ${logs_folder}":
			command => "rm -rf ${logs_folder}/*",
			onlyif  => "test -d ${logs_folder}",
			user    => "root",
			path    => $::path,
			require => Exec["stop service ${name}"],
			before  => Exec["start service ${name}"]
		}
	}

	exec { "start service ${name}":
		command => "systemctl start ${name}",
		onlyif  => "systemctl is-enabled ${name}",
		user    => "root",
		path    => $::path
	}
}
