Aerobase Server Omnibus
==================================
This project creates full-stack platform-specific packages for the Aerobase Server.

Aerobase Server is part of the [Aerobase project](http://aerobase.org/), see the [Community Page](http://aerobase.org/community) for general guidelines for contributing to the project.

The easiest way to start using Aerobase is sign-up a free Plan at [Aerobase.io](https://aerobase.io)

Download Binaries
------------
Please follow the steps on the [installation page](https://aerobase.atlassian.net/wiki/spaces/ARB/pages)


Preperation 
------------
only when runing under non root user.

```shell
sudo mkdir -p /opt/aerobase /var/cache/omnibus
sudo chown $USER:$USER /opt/aerobase
sudo chown $USER:$USER /var/cache/omnibus
```

Windows Builds
--------------
Required packages:
- [omnibus-toolchain](https://github.com/aerobase/omnibus-toolchain)
- [WiX Toolset v3.11](http://wixtoolset.org/releases/)
- [Windows Kits 10](https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk)
- [7zip](https://www.7-zip.org/download.html)
- Install .net 3.5 and .net 4+
- Install [Visual C++ Redistributable 2013](https://www.microsoft.com/en-us/download/confirmation.aspx?id=40784)
- Create Directory C:\omnibus-ruby

Any OS
--------------
Required packages:
- Java OpenJDK
- NodeJS
- Apache Maven 3.5+

Installation
------------
You must have a sane Ruby 2.4+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
yum -y install gcc ruby-devel rubygems libpng-devel
gem install omnibus
gem install bundler
npm install -g phantomjs-prebuilt
```

```shell
# Windows Only
$ load-omnibus-toolchain.bat
```

```shell
$ bundle install --without development --binstubs
```

Usage
-----
### Build

You create a platform-specific package using the `build project` command:

```shell
$ bundle exec omnibus build aerobase
```

The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bundle exec omnibus clean aerobase
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/aerobase-server`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bundle exec omnibus clean aerobase --purge
```

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships will a project-specific
[Berksfile](http://berkshelf.com/) that will allow you to build your omnibus projects on all of the projects listed
in the `.kitchen.yml`. You can add/remove additional platforms as needed by
changing the list found in the `.kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you to building on other platforms. Simply use
the [omnibus cookbook](https://github.com/opscode-cookbooks/omnibus) to setup
your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `.kitchen.yml` (or `.kitchen.local.yml`) to your
liking, you can bring up an individual build environment using the `kitchen`
command.

```shell
$ bin/kitchen converge ubuntu-1204
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bundle exec kitchen login ubuntu-1204
[vagrant@ubuntu...] $ cd aerobase-server
[vagrant@ubuntu...] $ bundle install
[vagrant@ubuntu...] $ ...
[vagrant@ubuntu...] $ bin/omnibus build aerobase-server
```

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.
