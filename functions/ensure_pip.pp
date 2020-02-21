function python::ensure_pip($ensure) {

  $pip_package = $python::pip_package

  if $pip_package {
    package { $pip_package:
      ensure  => $ensure,
      require => Package[$python::install::python_package],
    }
  }

  if $facts['os']['family'] == 'RedHat' {
    if $ensure == present {
      if $python::use_epel == true {
        include 'epel'
      }
    }

    if $ensure == present and $::python::version =~ /^3/ {
      exec { 'install_pip3':
        command => '/bin/curl https://bootstrap.pypa.io/get-pip.py | /bin/python3',
        creates => '/bin/pip3',
        require => Package[$python::install::python_package],
      }
    }

  }
}
