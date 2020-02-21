class { 'python':
  version    => 'system',
  dev        => true,
  virtualenv => true,
}

python::pip { 'flask':
  virtualenv => '/var/www/project1',
}
