# == Define: python::install
#
# Installs core python packages
#
# === Examples
#
# include python::install
#
# === Authors
#
# Sergey Stankevich
# Ashley Penney
# Fotis Gimian
#

class python::install {

  $python = $python::version ? {
    'system' => $::osfamily ? {
      Solaris => 'python27',
      default => 'python'
    },
    'pypy'   => 'pypy',
    default  => "python${python::version}",
  }

  $pythonbase = $::osfamily ? {
    'smartos' => 'py27',
    default => "python${python::version}"
  }

  $pythondev = $::osfamily ? {
    RedHat => "${python}-devel",
    Debian => "${python}-dev",
    Solaris => "${pythonbase}-py",
    default => "${python}-devel"
  }

  $dev_ensure = $python::dev ? {
    true    => present,
    default => absent,
  }

  $pythonpip = "${pythonbase}-pip"

  $pip_ensure = $python::pip ? {
    true    => present,
    default => absent,
  }

  $venv_ensure = $python::virtualenv ? {
    true    => present,
    default => absent,
  }

  # Install latest from pip if pip is the provider
  case $python::provider {
    pip: {
      package { 'virtualenv': ensure => latest, provider => pip }
      package { 'pip': ensure => latest, provider => pip }
      package { $pythondev: ensure => latest }
      package { "python==${python::version}": ensure => latest, provider => pip }
    }
    default: {
      package { 'python-virtualenv': ensure => $venv_ensure }
      package { $pythonpip: ensure => $pip_ensure }
      package { $pythondev: ensure => $dev_ensure }
      package { $python: ensure => present }
    }
  }

  if $python::manage_gunicorn {
    $gunicorn_ensure = $python::gunicorn ? {
      true    => present,
      default => absent,
    }
    package { 'gunicorn': ensure => $gunicorn_ensure }
  }

}
