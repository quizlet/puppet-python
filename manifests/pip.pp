# This class handles the installation and management of pip packages.
#
# @param ensure
# @param virtualenv
# @param url  URL to install from. Default: none
# @param owner The owner of the virtualenv being manipulated. Default: root
# @param editable Boolean. If true the package is installed as an editable resource.
# @param environment Additional environment variables required to install the packages. Default: none
# @param timeout The maximum time in seconds the "pip install" command should take. Default: 1800
# @param install_args String. Any additional installation arguments that will be supplied when running pip install.
# @param uninstall_args String. Any additional arguments that will be supplied when running pip uninstall.
# @param log_dir String. Log directory.
#
# @example
#   python::pip { 'flask':
#     virtualenv => '/var/www/project1',
#   }
#
define python::pip (
  $pkgname                                                  = $name,
  $ensure                                                   = present,
  Variant[Stdlib::Absolutepath, Enum['system']] $virtualenv = 'system',
  $url                                                      = false,
  $owner                                                    = 'root',
  $egg                                                      = false,
  $editable                                                 = false,
  $environment                                              = [],
  $timeout                                                  = 1800,
  $install_args                                             = '',
  $uninstall_args                                           = '',
  $log_dir                                                  = '/tmp',
) {

  # Parameter validation
  if ! $virtualenv {
    fail('python::pip: virtualenv parameter must not be empty')
  }

  if $virtualenv == 'system' and $owner != 'root' {
    fail('python::pip: root user must be used when virtualenv is system')
  }

  $cwd = $virtualenv ? {
    'system' => '/',
    default  => $virtualenv,
  }

  $log = $virtualenv ? {
    'system' => $log_dir,
    default  => $virtualenv,
  }

  $pip_env = $virtualenv ? {
    'system' => 'pip',
    default  => "${virtualenv}/bin/pip",
  }

  if $editable == true {
    $install_editable = ' -e '
  }
  else {
    $install_editable = ''
  }

  #TODO: Do more robust argument checking, but below is a start
  if ($ensure == absent) and ($install_args != '') {
    fail('python::pip cannot provide install_args with ensure => absent')
  }

  if ($ensure == present) and ($uninstall_args != '') {
    fail('python::pip cannot provide uninstall_args with ensure => present')
  }

  # Check if searching by explicit version.
  if $ensure =~ /^((19|20)[0-9][0-9]-(0[1-9]|1[1-2])-([0-2][1-9]|3[0-1])|[0-9]+\.[0-9]+(\.[0-9]+)?)$/ {
    $grep_regex = "^${pkgname}==${ensure}\$"
  } else {
    $grep_regex = $pkgname ? {
      /==/    => "^${pkgname}\$",
      default => "^${pkgname}==",
    }
  }

  $egg_name = $egg ? {
    false   => $pkgname,
    default => $egg
  }

  $source = $url ? {
    false               => $pkgname,
    /^(\/|[a-zA-Z]\:)/  => $url,
    /^(git\+|hg\+|bzr\+|svn\+)(http|https|ssh|svn|sftp|ftp|lp)(:\/\/).+$/ => $url,
    default             => "${url}#egg=${egg_name}",
  }

  # We need to jump through hoops to make sure we issue the correct pip command
  # depending on wheel support and versions.
  #
  # Pip does not support wheels prior to version 1.4.0
  # Pip wheels require setuptools/distribute > 0.8
  # Python 2.6 and older does not support setuptools/distribute > 0.8
  # Pip >= 1.5 tries to use wheels by default, even if wheel package is not
  # installed, in this case the --no-use-wheel flag needs to be passed
  # Versions prior to 1.5 don't support the --no-use-wheel flag
  #
  # To check for this we test for wheel parameter using help and then using
  # version, this makes sure we only use wheels if they are supported and
  # installed

  # Explicit version out of VCS when PIP supported URL is provided
  if $source =~ /^(git\+|hg\+|bzr\+|svn\+)(http|https|ssh|svn|sftp|ftp|lp)(:\/\/).+$/ {
      if $ensure != present and $ensure != latest {
        exec { "pip_install_${name}":
          command     => "${pip_env} wheel --help > /dev/null 2>&1 && { ${pip_env} wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { ${pip_env} --log ${log}/pip.log install ${install_args} \$wheel_support_flag ${install_args} ${install_editable} ${source}@${ensure}#egg=${egg_name} || ${pip_env} --log ${log}/pip.log install ${install_args} ${install_args} ${install_editable} ${source}@${ensure}#egg=${egg_name} ;}",
          unless      => "${pip_env} freeze | grep -i -e ${grep_regex}",
          user        => $owner,
          cwd         => $cwd,
          environment => $environment,
          path        => ['/usr/local/bin','/usr/bin','/bin', '/usr/sbin'],
          timeout     => $timeout,
          }
        }
    else {
          exec { "pip_install_${name}":
            command     => "${pip_env} wheel --help > /dev/null 2>&1 && { ${pip_env} wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { ${pip_env} --log ${log}/pip.log install ${install_args} \$wheel_support_flag ${install_args} ${install_editable} ${source} || ${pip_env} --log ${log}/pip.log install ${install_args} ${install_args} ${install_editable} ${source} ;}",
            unless      => "${pip_env} freeze | grep -i -e ${grep_regex}",
            user        => $owner,
            cwd         => $cwd,
            environment => $environment,
            path        => ['/usr/local/bin','/usr/bin','/bin', '/usr/sbin'],
            timeout     => $timeout,
        }
    }
  }
  else {
    case $ensure {
      /^((19|20)[0-9][0-9]-(0[1-9]|1[1-2])-([0-2][1-9]|3[0-1])|[0-9]+\.[0-9]+(\.[0-9]+)?)$/: {
        # Version formats as per http://guide.python-distribute.org/specification.html#standard-versioning-schemes
        # Explicit version.
        exec { "pip_install_${name}":
          command     => "${pip_env} wheel --help > /dev/null 2>&1 && { ${pip_env} wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { ${pip_env} --log ${log}/pip.log install ${install_args} \$wheel_support_flag ${install_args} ${install_editable} ${source}==${ensure} || ${pip_env} --log ${log}/pip.log install ${install_args} ${install_args} ${install_editable} ${source}==${ensure} ;}",
          unless      => "${pip_env} freeze | grep -i -e ${grep_regex}",
          user        => $owner,
          cwd         => $cwd,
          environment => $environment,
          path        => ['/usr/local/bin','/usr/bin','/bin', '/usr/sbin'],
          timeout     => $timeout,
        }
      }
      'present': {
        # Whatever version is available.
        exec { "pip_install_${name}":
          command     => "${pip_env} wheel --help > /dev/null 2>&1 && { ${pip_env} wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { ${pip_env} --log ${log}/pip.log install \$wheel_support_flag ${install_args} ${install_editable} ${source} || ${pip_env} --log ${log}/pip.log install ${install_args} ${install_editable} ${source} ;}",
          unless      => "${pip_env} freeze | grep -i -e ${grep_regex}",
          user        => $owner,
          cwd         => $cwd,
          environment => $environment,
          path        => ['/usr/local/bin','/usr/bin','/bin', '/usr/sbin'],
          timeout     => $timeout,
        }
      }

      'latest': {
        # Latest version.
        exec { "pip_install_${name}":
          command     => "${pip_env} wheel --help > /dev/null 2>&1 && { ${pip_env} wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { ${pip_env} --log ${log}/pip.log install --upgrade \$wheel_support_flag ${install_args} ${install_editable} ${source} || ${pip_env} --log ${log}/pip.log install --upgrade ${install_args} ${install_editable} ${source} ;}",
          unless      => "${pip_env} search ${source} | grep -i INSTALLED | grep -i latest",
          user        => $owner,
          cwd         => $cwd,
          environment => $environment,
          path        => ['/usr/local/bin','/usr/bin','/bin', '/usr/sbin'],
          timeout     => $timeout,
        }
      }

      default: {
        # Anti-action, uninstall.
        exec { "pip_uninstall_${name}":
          command     => "echo y | ${pip_env} uninstall ${uninstall_args}",
          onlyif      => "${pip_env} freeze | grep -i -e ${grep_regex}",
          user        => $owner,
          cwd         => $cwd,
          environment => $environment,
          path        => ['/usr/local/bin','/usr/bin','/bin', '/usr/sbin'],
          timeout     => $timeout,
        }
      }
    }
  }
}
