# This function contains the python package name determination logic.
#
function python::python_name() {

  case $facts['kernel'] {
    'OpenBSD': {

      # Installing Python on OpenBSD is always done with the package
      # name 'python'.  The ensure value determines the version.

      $python_name = $::python::version ? {
        'pypy'   => fail('pypi not supported on OpenBSD'),
        default  => 'python',
      }
    }
    default: {
      $python_name = $::python::version ? {
        'system' => 'python',
        'pypy'   => 'pypy',
        default  => "python${python::version}",
      }
    }
  }
}
