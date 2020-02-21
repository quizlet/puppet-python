# Puppet-python
[![Puppet Forge](https://img.shields.io/puppetforge/v/zleslie/python.svg)](https://forge.puppet.com/zleslie/python) [![Build Status](https://travis-ci.org/xaque208/puppet-python.svg?branch=master)](https://travis-ci.org/xaque208/puppet-python)

Puppet module for installing and managing python, pip, and virtualenv.

*This module was forked from [stankevich/puppet-python](https://github.com/stankevich/puppet-python)*

## Installation

```shell
puppet module install zleslie-python
```

## Usage

### python

To install python, and optionally the pip, dev and virtualenv packages, use the
`python` class.  See the class documentation for more detail.

```puppet
class { 'python' :
  version    => 'system',
  pip        => true,
  dev        => true,
  virtualenv => true,
}
```

### python::pip

Installs and manages packages from pip.

**pkgname** - the name of the package to install. Required.

**ensure** - present/latest/absent. You can also specify the version. Default: present

**virtualenv** - virtualenv to run pip in. Default: system (no virtualenv)

**url** - URL to install from. Default: none

**owner** - The owner of the virtualenv to ensure that packages are installed with the correct permissions (must be specified). Default: root

**proxy** - Proxy server to use for outbound connections. Default: none

**environment** - Additional environment variables required to install the packages. Default: none

**egg** - The egg name to use. Default: `$name` of the class, e.g. cx_Oracle

**install_args** - Array of additional flags to pass to pip during installaton. Default: none

**uninstall_args** - Array of additional flags to pass to pip during uninstall. Default: none

**timeout** - Timeout for the pip install command. Defaults to 1800.
```puppet
  python::pip { 'cx_Oracle' :
    pkgname       => 'cx_Oracle',
    ensure        => '5.1.2',
    virtualenv    => '/var/www/project1',
    owner         => 'appuser',
    proxy         => 'http://proxy.domain.com:3128',
    environment   => 'ORACLE_HOME=/usr/lib/oracle/11.2/client64',
    install_args  => ['-e'],
    timeout       => 1800,
   }
```

### python::requirements

Installs and manages Python packages from requirements file.

**virtualenv** - virtualenv to run pip in. Default: system-wide

**proxy** - Proxy server to use for outbound connections. Default: none

**owner** - The owner of the virtualenv to ensure that packages are installed with the correct permissions (must be specified). Default: root

**src** - The `--src` parameter to `pip`, used to specify where to install `--editable` resources; by default no `--src` parameter is passed to `pip`.

**group** - The group that was used to create the virtualenv.  This is used to create the requirements file with correct permissions if it's not present already.

```puppet
  python::requirements { '/var/www/project1/requirements.txt' :
    virtualenv => '/var/www/project1',
    proxy      => 'http://proxy.domain.com:3128',
    owner      => 'appuser',
    group      => 'apps',
  }
```

### python::virtualenv

Creates Python virtualenv.

**ensure** - present/absent. Default: present

**version** - Python version to use. Default: system default

**requirements** - Path to pip requirements.txt file. Default: none

**proxy** - Proxy server to use for outbound connections. Default: none

**systempkgs** - Copy system site-packages into virtualenv. Default: don't

**venv_dir** - The location of the virtualenv if resource path not specified. Must be absolute path. Default: resource name

**owner** - Specify the owner of this virtualenv

**group** - Specify the group for this virtualenv

**index** - Base URL of Python package index. Default: none

**cwd** - The directory from which to run the "pip install" command. Default: undef

**timeout** - The maximum time in seconds the "pip install" command should take. Default: 1800

```puppet
  python::virtualenv { '/var/www/project1' :
    ensure       => present,
    version      => 'system',
    requirements => '/var/www/project1/requirements.txt',
    proxy        => 'http://proxy.domain.com:3128',
    systempkgs   => true,
    distribute   => false,
    venv_dir     => '/home/appuser/virtualenvs',
    owner        => 'appuser',
    group        => 'apps',
    cwd          => '/var/www/project1',
    timeout      => 0,
  }
```

### python::pyvenv

Creates Python3 virtualenv.

**ensure** - present/absent. Default: present

**version** - Python version to use. Default: system default

**systempkgs** - Copy system site-packages into virtualenv. Default: don't

**venv_dir** - The location of the virtualenv if resource path not specified. Must be absolute path. Default: resource name

**owner** - Specify the owner of this virtualenv

**group** - Specify the group for this virtualenv

**path** - Specifies the PATH variable that contains `pyvenv` executable. Default: [ '/bin', '/usr/bin', '/usr/sbin' ]

**environment** - Specify any environment variables to use when creating pyvenv

```puppet
  python::pyvenv { '/var/www/project1' :
    ensure       => present,
    version      => 'system',
    systempkgs   => true,
    venv_dir     => '/home/appuser/virtualenvs',
    owner        => 'appuser',
    group        => 'apps',
  }
```

### python::dotfile

Manages arbitrary python dotiles with a simple config hash.

**ensure** - present/absent. Default: present

**filename** - Default: $title

**mode** - Default: 0644

**owner** - Default: root

**group** - Default: root

**config** Config hash. This will be expanded to an ini-file. Default: {}

```puppet
python::dotfile { '/var/lib/jenkins/.pip/pip.conf':
  ensure => present,
  owner  => 'jenkins',
  group  => 'jenkins',
  config => {
    'global' => {
      'index-url       => 'https://mypypi.acme.com/simple/'
      'extra-index-url => https://pypi.risedev.at/simple/
    }
  }
}
```

### hiera configuration

This module supports configuration through hiera. The following example
creates two python3 virtualenvs. The configuration also pip installs a
package into each environment.

```yaml
python::python_pyvenvs:
  "/opt/env1":
    version: "system"
  "/opt/env2":
    version: "system"
python::python_pips:
  "nose":
    virtualenv: "/opt/env1"
  "coverage":
    virtualenv: "/opt/env2"
```

## Release Notes
**Version 1.7.10 Notes**

Installation of python-pip previously defaulted to `false` and was not installed. This default is now `true` and python-pip is installed. To prevent the installation of python-pip specify `pip => false` as a parameter when instantiating the `python` puppet class.

**Version 1.1.x Notes**

Version `1.1.x` makes several fundamental changes to the core of this module, adding some additional features, improving performance and making operations more robust in general.

Please note that several changes have been made in `v1.1.x` which make manifests incompatible with the previous version.  However, modifying your manifests to suit is trivial.  Please see the notes below.

Currently, the changes you need to make are as follows:

* All pip definitions MUST include the owner field which specifies which user owns the virtualenv that packages will be installed in.  Adding this greatly improves performance and efficiency of this module.
* You must explicitly specify pip => true in the python class if you want pip installed.  As such, the pip package is now independent of the dev package and so one can exist without the other.

## Authors

[Sergey Stankevich](https://github.com/stankevich) | [Shiva Poudel](https://github.com/shivapoudel) | [Peter Souter](https://github.com/petems) | [Garrett Honeycutt](http://learnpuppet.com)
