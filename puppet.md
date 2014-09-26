# Intro

Opskelaton fully supports Puppet based sandboxes with the same lifecycle semantics as Chef.

# Usage

Creating out first sandbox

```bash
$ opsk generate_puppet redis ubuntu-14.04
$ cd redis-sandbox
```

## Layout

Opskelaton creates the complete folder structure fine tuned to match best practices:

Folder layout:

<img src="https://github.com/opskeleton/opskeleton/blob/master/img/puppet-layout.png" width='30%' hight='50%'  alt="" />


## Module lifecycle

Opskelaton defines a simple module life cycle:

 1. Internal non reusable modules (usually specific to a client site) go under static-modules
 2. If we create a general reusable module which is ready for prime time we pull out to a new git repository.
 3. The extracted module is added back as a third party (using [librarian-puppet](https://github.com/rodjek/librarian-puppet) module which resides under modules folder.

Life cycle scheme:

<img src="https://github.com/opskeleton/opskeleton/blob/master/img/puppet-cycle.png" width='30%' hight='50%'  alt="" />

Creating new (static) modules is easy as:

```bash
$ opsk module foo
```

Each generated module will contain puppet-rspec with matching Rakefile (see [testing](https://github.com/opskeleton/opskeleton#testing)).

## Testing

Opskelaton supports two levels of testing:

* Static module testing that includes rspec and linting.
* Integration testing using [serverspec](http://serverspec.org/) and Vagrant.

```bash
# linting all static modules
$ rake lint
# rspecing 
$ rake modspec
# running serverspec
$ rake spec
```

## Packaging 
Opskelaton fully supports deployment and portable execution of sandboxes on non Vagrant environments:

```bash
$ opsk generate_puppet foo ubuntu-13.10
$ cd foo-sandbox
# The package version file
$ cat opsk.yaml
--- 
  version: '0.0.1'
  name: foo

# post bundle and gem install ..
$ opsk package
      create  pkg/foo-sandbox-0.0.1
      create  pkg/foo-sandbox-0.0.1/scripts
      create  pkg/foo-sandbox-0.0.1/scripts/lookup.rb
       chmod  pkg/foo-sandbox-0.0.1/scripts/lookup.rb
      create  pkg/foo-sandbox-0.0.1/scripts/run.sh
       chmod  pkg/foo-sandbox-0.0.1/scripts/run.sh
      create  pkg/foo-sandbox-0.0.1/manifests/site.pp
       exist  pkg
$ ls pkg
foo-sandbox-0.0.1  foo-sandbox-0.0.1.tar.gz
```
The packaging process creates a portable tar file that can be run on any machine with puppet installed via the bundled run.sh:

```bash 
$ tar -xvzf foo-sandbox-0.0.1.tar.gz
$ cd foo-sandbox-0.0.1 
$ sudo ./run.sh
```

An external node classifier based runner is also available under scripts/run.sh, this runner expects to get a <hostname>.yaml input file with the required node classes.


## Deployment

The packaged tar files can be consumed using any tool and protocol however http is recommended, opsk has built in support for deploying public sandboxes into bintray:

```bash 
$ opsk package
$ opsk deploy <bintray-repo>
deployed foo-sandbox-0.0.1.tar.gz to http://dl.bintray.com/narkisr/<bintray-repo>/foo-sandbox-0.0.1.tar.gz
```

Make sure to  [configure](https://github.com/narkisr/bintray-deploy#usage) configure the bintray API key.

## Updating
Keeping you box up to date with latest opsk version is easy, just re-generate it again and resolve conflicts by answering y/n:
```bash
# Moving to latest opsk
$ gem update opskeleton
# foo box already exists
$ opsk generate foo <vagrant-box>
 exist  foo-sandbox
    conflict  foo-sandbox/Vagrantfile
Overwrite /home/ronen/code/foo-sandbox/Vagrantfile? (enter "h" for help) [Ynaqdh]
```

## Vagrant
Opskeleton generates a Vagrant file with couple of enhancements:
 
* VAGRANT_BRIDGE (default eth0) for setting up public bridge on the go.
* PUPPET_ENV (default dev) for setting puppet environment.
* Puppet options preset to match modules and hiera folders.

## Docker
The only assumption that Opskelaton makes is that the target host will have Pupppet installed, this enables us to create docker images from our sandboxes quite easily:

```bash
$ opsk package
# creates the Dockerfile
$ opsk dockerize
# builds <sandbox>/<version> image
$ sudo ./build_docker.sh
```