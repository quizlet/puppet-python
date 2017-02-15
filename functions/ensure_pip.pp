function python::ensure_pip($ensure) {

  $pip_name = python::pip_name()

  case $facts['osfamily'] {
    'RedHat': {
      if $ensure == present {
        if $python::use_epel == true {
          include 'epel'
          #Class['epel'] -> Package[$pip_name]
        }
      }

      if $ensure == present and $::python::version =~ /^3/ {
        exec { 'install_pip3':
          command => '/bin/curl https://bootstrap.pypa.io/get-pip.py | /bin/python3',
          creates => '/bin/pip3',
          require => Package[$python::install::python_name],
        }
      }

    }
  }

  if $pip_name {
    package { $pip_name: ensure => $::python::install::pip_ensure }
  }

}
