# This function handles the logic of checking if pip is enabled on the python
# class and failing if it is not.  This allows the user to require that pip is
# installed in a clean way and allow for consistent messaging.
#
# @example
#   python::require_pip()
#
function python::require_pip() {
  unless $::python::pip {
    fail("Installing virtualenv on ${facts['os']['id']} ${facts['os']['releae']['major']} with ${::python::version} requires that 'python::pip' be set true")
  }
}
