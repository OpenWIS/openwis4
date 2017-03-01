# OpenWIS®

OpenWIS is an implementation of the WMO Information System.

The World Meteorological Organization (WMO) has been working for several years towards upgrading its global infrastructure to support all of its international programmes of work, both operational and research-based, to collect, share and disseminate information. The new infrastructure is called the WIS, the WMO Information System, and identifies three top-level functions. These are:

- GISC: Global Information System Centre;
- DCPC: Data Collection and Production Centre;
- NC: National Centre.

All three functions contribute to the circulation of priority data, system wide security, monitoring and implementation of WMO data policies. GISCs and DCPCs allow the Discovery Access and Retrieval of data, products and services offered by WIS Centres, but GISCs offer a global view of this information and provide distributed and resilient access to critical data and products.

OpenWIS aims to perform all three functions required by the WMO Information System, that is: GISC, DCPC and NC.

# License

OpenWIS® is free software: you can redistribute it and/or modify it under the terms of the License. In accordance with [TITLE 9: SOFTWARE LICENSING](http://openwis.github.io/openwis-documentation/rules/9-software-licensing.html) from the [Internal Rules of the OpenWIS Association AISBL](http://openwis.github.io/openwis-documentation/rules/), each OpenWIS Project must specify a [license approved by the Open Source Initiative](https://opensource.org/licenses/). This Project is licensed under the [GNU General Public Licence, version 3.0](./LICENSE).  

# OpenWIS v4
OpenWIS v4 is an upgrade of the [OpenWIS software](http://openwis.github.io/openwis/) based on the 3.2.x series of [GeoNetwork](https://github.com/geonetwork/core-geonetwork) software. The major difference is a brand-new, modern user interface based on [AngularJS](https://angularjs.org/) framework.

## Installation

### Production
* [[Production installation guide]], including upgrading from OpenWIS 3.14.x. _TBD_

### Development

#### Dependencies

The current version has been tested with the following versions:

- [Java SE JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html): Oracle JDK 1.8.0_45
- [Apache Maven 3](https://maven.apache.org/download.cgi): version 3.2.1
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads): 5.1.4 
- [Vagrant](https://www.vagrantup.com/downloads.html): 1.8.5

	
### Build of CGN
	
	git clone https://github.com/geonetwork/core-geonetwork.git
	
	cd core-geonetwork
	
Init the submodules:

	git submodule init
	git submodule update
	
Checkout OpenWISv4's required version:
	
	git checkout tags/3.2.0

Then build the application:

	mvn clean install -DskipTests

### Build of OpenWIS v3

From the workspace folder 

Clone from the repository:
	
	git clone https://github.com/OpenWIS/openwis.git
	cd openwis

Checkout a stable branch:
	
	git checkout release/openwis-3.14.8
	
Build with maven:

	mvn clean exec:exec
	mvn clean install -P openwis -DskipTests -Dfile.encoding=UTF-8 

### Build of OpenWIS v4

From the workspace folder, clone source code from OpenWIS repository:

	git clone https://github.com/OpenWIS/openwis4.git
	
When clone is done switch to develop branch:
	
	cd openwis4
	git checkout develop
	
Navigate to openwis-parent and build:
	
	cd openwis-parent
	mvn clean install
	
After the successfull build configure the Vangrant environment at:
	
	cd ../openwis-deployment/vagrant-allinone/
	
Create config.yaml and edit according to `config.yaml.sample`
	
	openwis_workspace: <Full path to OpenWIS sources>
	portal_workspace: <Full path to CoreGeoNetwork sources>
	
Save and then execute:

	vagrant box add --force openwis/centos7 https://repository-openwis-association.forge.cloudbees.com/artifacts/vagrant/openwis-centos-7.box
	vagrant up

> Note: In order to re-deploy enter `vagrant reload --provision`

	
When the puppet scripts execution is done OpenWISv4 can be accessed at:

	yourServerUrl:10080/geonetwork/

