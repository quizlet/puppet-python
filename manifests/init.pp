# This class installs and manages python, python-dev, and python-virtualenv.
#
# @param version Python version to install. Beware that valid values for this
# differ by the osfamily/operatingsystem you are using.
#   Default: system default
#   Allowed values:
#     - provider == pip: everything pip allows as a version after the 'python=='
#     - else: 'system', 'pypy', 3/3.3/...
#        - Be aware that 'system' means default, usually python 2.X.
#        - 3/3.3/... means you are going to install the python3/python3.3/...
#          package, if available on your osfamily.
#
# @param pip Boolean to install python-pip. Default: true
# @param dev Boolean to install python-dev. Default: false
# @param virtualenv Boolean to Install python-virtualenv. Default: false
# @param use_epel Boolean to determine if the epel class is used. Default: true
# @param valid_versions Array of strings for platform versions available
#
# @example
#   class { 'python':
#     version    => 'system',
#     pip        => true,
#     dev        => true,
#     virtualenv => true,
#   }
#
class python (
  Boolean $pip,
  Boolean $dev,
  Boolean $virtualenv,
  String $version,
  Array $valid_versions = [],
  Boolean $use_epel     = false,
) {

  unless $version == 'system' or $version in $valid_versions {
    fail("Python version ${version} not supported on ${facts['os']['name']}: ${valid_versions} ${facts['os']}")
  }

  $version_data = python::version_data($version)

  # Useful variables for the default version 
  $virtualenv_cmd     = $version_data['virtualenv_cmd']
  $virtualenv_package = $version_data['virtualenv_package']

  $pip_cmd     = $version_data['pip_cmd']
  $pip_package = $version_data['pip_package']

  contain python::install
  contain python::config
}
