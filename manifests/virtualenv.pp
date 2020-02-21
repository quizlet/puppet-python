# This class handles creating Python virtualenvs
#
# @param ensure
#  present|absent. Default: present
#
# @param version
#  Python version to use. Default: system default
#
# @param requirements
#  Path to pip requirements.txt file. Default: none
#
# @param systempkgs
#  Copy system site-packages into virtualenv. Default: don't
#  If virtualenv version < 1.7 this flag has no effect since
#
# @param venv_dir
#  Directory to install virtualenv to. Default: $name
#
# @param index
#  Base URL of Python package index. Default: none (http://pypi.python.org/simple/)
#
# @param owner
#  The owner of the virtualenv being manipulated. Default: root
#
# @param group
#  The group relating to the virtualenv being manipulated. Default: root
#
# @param mode
# Optionally specify directory mode. Default: 0755
#
# @param [*environment*]
#  Additional environment variables required to install the packages. Default: none
#
# @param [*path*]
#  Specifies the PATH variable. Default: [ '/bin', '/usr/bin', '/usr/sbin' ]
#
# @param [*cwd*]
#  The directory from which to run the "pip install" command. Default: undef
#
# @param [*timeout*]
#  The maximum time in seconds the "pip install" command should take. Default: 1800
#
# @param [*extra_pip_args*]
#  Extra arguments to pass to pip after requirements file.  Default: blank

# @example
#   python::virtualenv { '/var/www/project1':
#     ensure       => present,
#     version      => 'system',
#     requirements => '/var/www/project1/requirements.txt',
#     systempkgs   => true,
#     index        => 'http://www.example.com/simple/'
#   }
#
define python::virtualenv (
  String $ensure         = present,
  String $version        = 'system', # TODO: This doesn't look to work
  Boolean $requirements  = false,
  Boolean $systempkgs    = false,
  String $venv_dir       = $name,
  Boolean $index         = false,
  String $owner          = 'root',
  String $group          = '0',
  String $mode           = '0755',
  Array $environment     = [],
  Array $path            = [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
  $cwd                   = undef,
  Integer $timeout       = 1800,
  String $extra_pip_args = '',
  $virtualenv            = undef,
) {
  include python

  unless $python::virtualenv {
    fail('to use a virtualenv, you must set $python::virtualenv to true')
  }

  if $ensure == 'present' {
    $python = $version ? {
      'system' => 'python',
      'pypy'   => 'pypy',
      default  => "python${version}",
    }

    if $virtualenv {
      $virtualenv_cmd = $virtualenv
    } else {
      $virtualenv_cmd = $python::virtualenv_cmd
    }

    # Virtualenv versions prior to 1.7 do not support the
    # --system-site-packages flag, default off for prior versions Prior to
    # version 1.7 the default was equal to --system-site-packages and the flag
    # --no-site-packages had to be passed to do the opposite

    # TODO: This code doesn't look to work for the non-system case, since the
    # fact 'virtualenv_version' simply executes 'virtualenv' to determine the
    # version, so any setting of version in this class would mean this logic
    # doesn't work.  Likely this will be dropping support for older virtualenv
    # and just fail if we don't find a version that handles the case we need.

    #if $facts['virtualenv_version'] {
    #  if (( versioncmp($facts['virtualenv_version'],'1.7') > 0 ) and ( $systempkgs == true )) {
    #    $system_pkgs_flag = '--system-site-packages'
    #  } elsif (( versioncmp($facts['virtualenv_version'],'1.7') < 0 ) and ( $systempkgs == false )) {
    #    $system_pkgs_flag = '--no-site-packages'
    #  } else {
    #  }
    #}
    $system_pkgs_flag = $systempkgs ? {
      true    => '--system-site-packages',
      false   => undef,
    }

    $pypi_index = $index ? {
      false   => undef,
      default => "-i ${index}",
    }

    file { $venv_dir:
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }

    $pip_cmd = "${venv_dir}/bin/pip"

    $virtualenv_create_args = [
      $virtualenv_cmd,
      $system_pkgs_flag,
      "-p ${python}",
      "${venv_dir} &&",
      "${pip_cmd} wheel --help > /dev/null 2>&1 &&",
      "{ ${pip_cmd} wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; };",
      "{ ${pip_cmd} --log ${venv_dir}/pip.log install ${pypi_index} \$wheel_support_flag --upgrade pip setuptools || ${pip_cmd} --log ${venv_dir}/pip.log install ${pypi_index}  --upgrade pip setuptools ;}",
    ]

    exec { "python_virtualenv_${venv_dir}":
      command     => $virtualenv_create_args.delete_undef_values().join(' '),
      user        => $owner,
      creates     => "${venv_dir}/bin/activate",
      path        => $path,
      cwd         => '/tmp',
      environment => $environment,
      #Unless activate exists and VIRTUAL_ENV is correct we re-create the virtualenv
      unless      => "grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate",
      require     => File[$venv_dir],
    }

    if $requirements {
      exec { "python_requirements_initial_install_${requirements}_${venv_dir}":
        command     => "${pip_cmd} wheel --help > /dev/null 2>&1 && { ${pip_cmd} wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; ${pip_cmd} --log ${venv_dir}/pip.log install ${pypi_index} \$wheel_support_flag -r ${requirements} ${extra_pip_args}",
        refreshonly => true,
        timeout     => $timeout,
        user        => $owner,
        subscribe   => Exec["python_virtualenv_${venv_dir}"],
        environment => $environment,
        cwd         => $cwd,
      }

      python::requirements { "${requirements}_${venv_dir}":
        requirements   => $requirements,
        virtualenv     => $venv_dir,
        owner          => $owner,
        group          => $group,
        cwd            => $cwd,
        require        => Exec["python_virtualenv_${venv_dir}"],
        extra_pip_args => $extra_pip_args,
      }
    }
  } elsif $ensure == 'absent' {
    file { $venv_dir:
      ensure  => absent,
      force   => true,
      recurse => true,
      purge   => true,
    }
  }
}
