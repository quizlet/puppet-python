# This function contains the python development package name determination
# logic.
function python::dev_name() {
  case $facts['osfamily'] {
    'RedHat': {
      $dev_name = "${::python::install::python_name}-devel"
    }
    'Debian': {
      $dev_name = "${::python::install::python_name}-dev"
    }
    default: {
      $dev_name = undef
    }
  }
}
