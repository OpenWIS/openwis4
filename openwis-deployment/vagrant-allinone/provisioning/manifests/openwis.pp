Package {
	allow_virtual => false,
}

# Apache proxies have no hard dependencies
class { openwis::portal_proxy:
}
class { openwis::staging_post_proxy:
}

# JBoss must be installed before Tomcat to avoid port conflicts
class { openwis::middleware::jboss_as:
} ->
class { openwis::middleware::tomcat:
}

# database, data services & portal must be provisioned in correct order
class { openwis::database:
} ->
class { openwis::data_services:
} ->
class { openwis::portal:
}

# Staging Post has no hard dependencies
class { openwis::staging_post:
}
