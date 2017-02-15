# This function contains the pip package name determination logic.
#
function python::pip_name() {

  case $::kernel {
    'Linux': {
      if $::python::version == 'system' {
        $pip_name = 'python-pip'
      } elsif $::python::version =~ /^3.*/ {
        if $facts['osfamily'] == 'RedHat' {
          # As of 2016-05-31 RedHat osfamilies curl get-pip.py to install python3
          $pip_name = undef
        } else {
          $pip_name = 'python3-pip'
        }
      } else {
        $pip_name = 'python-pip'
      }
    }
    'FreeBSD': {
      if $::python::version == 'system' {
        $pip_name = "py27-pip"
      } elsif $::python::version =~ /^[23].*/ {
        $pip_name = "py${::python::version}-pip"
      } else {
        $pip_name = undef
      }
    }
    'OpenBSD': {
      if $::python::version == 'system' or $::python::version =~ /^[2].*/ {
        $pip_name = "py-pip"
      } elsif $::python::version =~ /^[3].*/ {
        $pip_name = "py3-pip"
      } else {
        $pip_name = undef
      }
    }
    default: {
      $pip_name = undef
    }
  }
}
