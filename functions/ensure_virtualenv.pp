function python::ensure_virtualenv($ensure) {

  $virtualenv_name = python::virtualenv_name()

  if $virtualenv_name {
    if $facts['osfamily'] == 'RedHat' and $::python::version =~ /^3/ {
      if $ensure == 'present' {
        python::require_pip()
        package { $virtualenv_name:
          ensure   => $ensure,
          provider => 'pip3',
          require  => Exec['install_pip3'],
        }
      } else {
        package { $virtualenv_name:
          ensure   => $ensure,
          provider => 'pip3',
        }
      }
    } else {
      package { $virtualenv_name:
        ensure  => $ensure,
        require => Package[$python::install::python_name],
      }
    }
  }
}
