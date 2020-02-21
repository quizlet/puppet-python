# This class installs and manages Python packages from requirements file.
#
# @param requirements Path to the requirements file. Defaults to the resource
# name
#
# @param virtualenv virtualenv to run pip in. Default: system-wide
#
# @param owner The owner of the virtualenv being manipulated. Default: root
#
# @param group The group relating to the virtualenv being manipulated. Default:
# root
#
# @param proxy Proxy server to use for outbound connections. Default: none
#
# @param src Pip --src parameter; if the requirements file contains --editable
# resources, this parameter specifies where they will be installed. See the pip
# documentation for more. Default: none (i.e. use the pip default).
#
# @param environment Additional environment variables required to install the
# packages. Default: none
#
# @param forceupdate Run a pip install requirements even if we don't receive an
# event from the requirements file - Useful for when the requirements file is
# written as part of a resource other than file (E.g vcsrepo)
#
# @param cwd The directory from which to run the "pip install" command.
# Default: undef
#
# @param extra_pip_args Extra arguments to pass to pip after the requirements
# file
#
# @param fix_requirements_owner Change owner and group of requirements file.
# Default: true
#
# @param log_dir String. Log directory.
#
# @param timeout The maximum time in seconds the "pip install" command should
# take. Default: 1800
#
# @example
#   python::requirements { '/var/www/project1/requirements.txt':
#     virtualenv => '/var/www/project1',
#     proxy      => 'http://proxy.domain.com:3128',
#   }
#
define python::requirements (
  $requirements           = $name,
  $virtualenv             = 'system',
  $owner                  = 'root',
  $group                  = '0',
  $proxy                  = false,
  $src                    = false,
  $environment            = [],
  $forceupdate            = false,
  $cwd                    = undef,
  $extra_pip_args         = '',
  $fix_requirements_owner = true,
  $log_dir                = '/tmp',
  $timeout                = 1800,
) {

  if $virtualenv == 'system' and ($owner != 'root' or $group != '0') {
    fail('python::pip: root user must be used when virtualenv is system')
  }

  if $fix_requirements_owner {
    $owner_real = $owner
    $group_real = $group
  } else {
    $owner_real = undef
    $group_real = undef
  }

  $log = $virtualenv ? {
    'system' => $log_dir,
    default  => $virtualenv,
  }

  $pip_env = $virtualenv ? {
    'system' => 'pip',
    default  => "${virtualenv}/bin/pip",
  }

  $proxy_flag = $proxy ? {
    false    => '',
    default  => "--proxy=${proxy}",
  }

  $src_flag = $src ? {
    false   => '',
    default => "--src=${src}",
  }

  # This will ensure multiple python::virtualenv definitions can share the
  # the same requirements file.
  if !defined(File[$requirements]) {
    file { $requirements:
      ensure  => present,
      mode    => '0644',
      owner   => $owner_real,
      group   => $group_real,
      replace => false,
      content => '# Puppet will install and/or update pip packages listed here',
    }
  }

  exec { "python_requirements${name}":
    provider    => shell,
    command     => "${pip_env} --log ${log}/pip.log install ${proxy_flag} ${src_flag} -r ${requirements} ${extra_pip_args}",
    refreshonly => !$forceupdate,
    timeout     => $timeout,
    cwd         => $cwd,
    user        => $owner,
    subscribe   => File[$requirements],
    environment => $environment,
  }

}
