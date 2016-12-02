# OpenWIS v4
OpenWIS v4 is an upgrade of the [OpenWIS software](http://openwis.github.io/openwis/) based on the 3.2.x series of [GeoNetwork](https://github.com/geonetwork/core-geonetwork) software. The major difference is a brand-new, modern user interface based on [AngularJS](https://angularjs.org/) framework.

## Installation

### Production
* [[Production installation guide]], including upgrading from OpenWIS 3.14.x. _TBD_

### Development
_TBD_

## Enhancements/Differences with GeoNetwork
You can read on our Wiki what additional functionality OpenWIS provides on top of GeoNetwork under [Enhancements/Differences with GeoNetwork](). _TBD_

## Development approach
Our initial approach was based on forking GeoNetwork and locally changing its code. That proved to be more complicated than initially thought, as GeoNetwork is a very active project with frequent updates. Merging upstream changes was not always an easy task and, usually, only experienced developers of the project could securely perform successful merges. A side-effect of this was that compatibility-checking of our own code/changes with GeoNetwork was taking place late, thus resulting in more errors and conflicts.

The alternative approach we decided to use was to use GeoNetwork as an external artefact rather than working directly on its source code. [Maven](https://maven.apache.org/), which is our build-tool, provides an efficient mechanism to support such requirements via its [Shade](https://maven.apache.org/plugins/maven-shade-plugin/) and [Overlay](https://maven.apache.org/plugins/maven-war-plugin/overlays.html) plugins.

You may check on our Wiki for a detailed explanation of the role of each module on this repository, together with an in-depth discussion of our development approach under [[Development approach]]. _TBD_
