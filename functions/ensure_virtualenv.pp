function python::ensure_virtualenv($ensure) {

  $virtualenv_package = $::python::virtualenv_package

  if $virtualenv_package {
    if $facts['os']['family'] == 'RedHat' and $::python::version =~ /^3/ {
      if $ensure == 'present' {
        python::require_pip()
        package { $virtualenv_package:
          ensure   => $ensure,
          provider => 'pip3',
          require  => Exec['install_pip3'],
        }
      } else {
        package { $virtualenv_package:
          ensure   => $ensure,
          provider => 'pip3',
        }
      }
    } else {
      package { $virtualenv_package:
        ensure  => $ensure,
        require => Package[$python::install::python_package],
      }
    }
  }
}
