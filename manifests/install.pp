# This class installs core python packages.  This should only be used by
# including the 'python' class.
#
# @example
#   include python::install
#
class python::install {

  $python_name = python::python_name()

  $python_dev = python::dev_name()
  $dev_ensure = $python::dev ? {
    true    => present,
    default => absent,
  }

  $pip_ensure = $python::pip ? {
    true    => present,
    default => absent,
  }

  $virtualenv_ensure = $python::virtualenv ? {
    true    => present,
    default => absent,
  }

  if $python_dev {
    package { $python_dev: ensure => $dev_ensure }
  }

  if $python::use_epel == true {
    include 'epel'
    Class['epel'] -> Package[$python_name]
  }

  python::ensure_pip($pip_ensure)
  python::ensure_virtualenv($virtualenv_ensure)

  case $facts['kernel'] {
    'OpenBSD': {
      package { $python_name: ensure => $::python::version }
    }
    default: {
      package { $python_name: ensure => present }
    }
  }
}
