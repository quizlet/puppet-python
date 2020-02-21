# This function takes a platform specific version string and returns a hash
# who's keys map to the various commands, package names, etc for parts of the
# isntallation and management of python.  This helps centralize the logic for
# where data comes from, so that we can more easily hack around the various
# oddities and inconsistencies that is the nature of python deployment on a
# variety of platforms.

function python::version_data($version) {
  unless $version in $python::valid_versions or $version == 'system' {
    fail "The python version ${version} is unknown on ${facts['osfamily']}"
  }

  $data_hash            = lookup('python::version_data', Hash, 'hash')
  $defaults             = lookup('python::version_defaults')
  $current_version_data = $data_hash.dig($version)
  $data                 = merge($defaults, $current_version_data)

  # Virtualenv Data
  $virtualenv_cmd     = $data['virtualenv_cmd']
  $virtualenv_package = $data['virtualenv_package']

  # Pip Data
  $pip_cmd     = $data['pip_cmd']
  $pip_package = $data['pip_package']

  $blob = {
    'virtualenv_cmd'     => $virtualenv_cmd,
    'virtualenv_package' => $virtualenv_package,
    'pip_cmd'            => $pip_cmd,
    'pip_package'        => $pip_package,
  }
}
