# This function contains the python development package name determination
# logic.
function python::dev_name() {
  case $facts['os']['family'] {
    'RedHat': {
      $dev_name = "${::python::install::python_package}-devel"
    }
    'Debian': {
      $dev_name = "${::python::install::python_package}-dev"
    }
    default: {
      $dev_name = undef
    }
  }
}
