Package {
	allow_virtual => false,
}

case $::hostname {
  # Database Server
  "ow4dev-db": {
    class { openwis::database:
    }
  }

  # Data Services Server
  "ow4dev-data": {
		# JBoss must be installed before Tomcat to avoid port conflicts
		class { openwis::middleware::jboss_as:
		} ->
		class { openwis::middleware::tomcat:
		}

		class { openwis::data_services:
    }

		class { openwis::staging_post:
    }
  }

  # Portal Server
  "ow4dev-portal": {
		class { openwis::portal_proxy:
    }

		class { openwis::staging_post_proxy:
    }

		class { openwis::portal:
    }
  }
}
