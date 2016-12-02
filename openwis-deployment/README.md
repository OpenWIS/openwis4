# OpenWIS / GeoNetwork Deployment

> **Note:** This sub-component is currently in the early stages of development, so there will be ongoing changes for the forseeable future.

> This readme file will be updated as the component evolves.

This sub-component provides facilites that are intended to be used for the provisioning & deployment of OpenWIS 4.x moving forward.

There are 3 aspects to this component:

1. [Puppet](https://docs.puppet.com/puppet/) scripts that are designed for provioning OpenWIS into any environment.
2. [Vagrant](https://www.vagrantup.com/docs/getting-started/) scripts that are designed to stand-up development [VirtualBox](https://www.virtualbox.org/) VMs using Puppet to provison them.
3. Shell scripts that are designed to deploy & configure the various OpenWIS components.

# Vagrant for Development VMs

## Getting Started

### Add the OpenWIS Vagrant Base Box

A bare-bones CentOS 7 has been created with the following included:

* CentOS 7 base install (up to date at 24/06/2016)
* Puppet installed - v3.8.7
* The following Puppet modules installed:
  * puppetlabs-stdlib - v4.12.0
  * AlexCline-dirtree - v0.2.1

This box should be downloaded & added to Vagrant by running:
```
vagrant box add --force openwis/centos7 https://repository-openwis-association.forge.cloudbees.com/artifacts/vagrant/openwis-centos-7.box
```

## Vagrant Environment Configuration

Each Vagrant environment requires a `config.yaml` file with the appropriate settings for that environment.  Each environment comes with a `config.yaml.sample` file that can be used as the basis for the configuraion.

When setting up an environment for the first time, copy the `config.yaml.sample` to `config.yaml` and the set the parameters appropriately for your environment requirements, as per the following table.

| Parameter          | Description
| ------------------ | ------------
| `portal_workspace` | Specifies the location of the Portal development workspace on the host machine (i.e. where you have checked out the _cor-geonetwork_ project). <br/>e.g. `D:/Projects/OpenWIS/code/core-geonetwork`

> **Note:** More parameters will get added to sample configuration file over time, so you are likely to have to update your `config.yaml` file after pulling the latest changes from GitHUB.

## Standing Up a Vagrant Environment

Ensure that you have followed the _Getting Started_ and _xx_ steps above, then from in the appropriate Vagrant environment sub-folder run `vagrant up`.

For example to run-up an _all-in-one_ environment do:
```
cd vagrant-allinone
vagrant up
```

## Tearing Down a Vagrant Environment

One of the beauties of Vagrant is that it is very easy to tear-down your environment, should it get into a 'broken' state, and start again.  The `vagrant destroy -f` command will completely tear-down a broken environment. You then simply need to do `vagrant up` to start again.

For example to re-build the _all-in-one_ environment do:
```
cd vagrant-allinone
vagrant destroy -f
vagrant up
```

## Accessing the Deployed Applications

A number of ports are being mapped between the guest machine(s) & the host machine to allow direct access to applications runing on the guest(s).  The current ports are mapped:

| Host Port | Guest Port | Reason / Notes
| --------- | -----------| --------------
| 10080     | 8080       | Access to web application(s). <br/>This currently maps directly to Tomcat, but this will change to Apache in the future
| 18000     | 8000       | Tomcat remote debug port. Allows remote debugging from Eclipse.

### Web URLs

> Portal : http://localhost:10080/geonetwork

## Available Vagrant Environment Types

There is currently only one Vagrant configuration available that stands up an _all-in-one_ environment, where everything is deployed to a single server instance.  See below for the description of this environment.

There are plans to implement a _multi-server_ environment, where the OpenWIS components are deployed on different server instances, to be more representative of a full test/production environment.

### All-In-One Vagrant Environment

The _vagrant-allinone_ sub-folder, contains the Vagrant scripts that will stand-up a local development VM that contains all of the OpenWIS components depoyed into a single server.

This instance currently contains the following components:

* An empty PostgeSQL database
* The GeoNetwork/OpenWIS Portal deployed into Tomcat

# Shell Scripts for Component Deployment/Configuration

The following shell scripts are available for installing/deploying the OpenWIS components - these can be invoked either from Puppet or manually.

| Script             | Description
| -------------------| -----------
| `create-db.sh`     | Creates the base OpenWIS database, roles, etc
| `deploy-portal.sh` | (re)Deploys the Portal (either from a local or remote build - see `Puppet Configuration` below for more details)

# Puppet for Server provisioning

The puppet scripts provided here are designed to maintain the base server configuration (firewall, installed packages, etc) and the required OpenWIS middleware (PostgeSQL, Tomcat, JBoss, Apache HTTPD etc).

The Puppet provisioning scripts also customize the OpenWIS application configuration files and perform a one-off deployment/installation of the OpenWIS components, but **do not maintain these** on an ongoing basis.  The OpenWIS installations/deployments are performed using Bash shell scripts, which are simply invoked buy Puppet.

| Puppet Class                    | Description
| ------------------------------- | -----------
| `openwis`                         | Common base OpenWIS features ('openwis' user, folders, links etc) & packages
| `openwis::middleware::httpd`      | Installs & configures the Apache HTTPD service
| `openwis::middleware::postgresql` | Installs & configures the PostgeSQL database
| `openwis::middleware::tomcat`     | Installs & configures the Apache Tomcat service
| `openwis::portal_proxy`           | Configures Apache HTTPD to be a reverse proxy for OpenWIS Portal
| `openwis::database`               | Creates the base OpenWIS database, roles, tables etc.  Relies on the `create-db.sh` script.
| `openwis::portal`                 | Deploys & configures the OpenWIS 4.x Portal.   Relies on the `deploy-portal.sh` script.

# Puppet Configuration

Puppet is configured via [Hiera](https://docs.puppet.com/hiera/), allowing a base, default, configuration to be specified & then overridden for each environment and/or server.

## Hiera Hierarchy Specification

> The new Hiera hierachy hasn't yet been set-up for the new OpenWIS 4.x Puppet scripts.  When this has been done, details will be available here.

## Puppet Configuration parameters

The following table lists the available configuration parameters, along with the default Hiera values and any fall-back defaults that have been built into the Puppet script (used when no Hiera value can be discovered).

| Parameter Name                                        | Default Hiera Value | Default Coded into Puppet | Description
| ----------------------------------------------------- | ------------------- | ------------------------- | -----------
| ** Common Configuration **                            |                     |                           |
| `openwis::provisioning_root_dir`                      |                     | /tmp/provisioning         | The base folder used as a _working area_ by the Puppet provisioning scripts
| `openwis::touch_files_dir`                            |                     | /home/openwis/touchfiles  | The folder that will hold 'touch files', used by the Puppet scripts & schell scripts to ensure that certain scripts/commands are only executed once
| `openwis::logs_root_dir`                              |                     | /home/openwis/logs        | The root folder where the various log files will be written.  Re-configuring the various compoents to log to the same locations should simplify support/debugging/investigation
| ** Portal Specific Configuration **                   |                     |                           |
| `openwis::portal::use_local_portal_war`               |                     | false                     | Whether use a locally built portal WAR file
| `openwis::portal::local_portal_war`                   |                     | undef (undefined)         | Where to find the local Portal WAR file (full path & file), if _local_ deployment is specified
| `openwis::portal::remote_portal_war`                  |                     | undef (undefined)         | Where to find the remote Portal WAR file (protocol, repository, full path & file), if _remote_ deployment is specified
| ** Database Specific Configuration **                 |                     |                           |
| `openwis::middleware::postgresql::postgresql_version` |                     | 9.5                       | The version of PostgeSQL to install
| `openwis::middleware::postgresql::postgis_version`    | 2.2                 |                           | The version of PostGIS to install
