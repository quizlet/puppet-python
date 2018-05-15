# == Define: python::config
#
#
# === Examples
#
# include python::config
#
# === Authors
#
# Sergey Stankevich
# Ashley Penney
# Fotis Gimian
#

class python::config {

  Class['python::install'] -> Python::Pip <| |>
  Class['python::install'] -> Python::Requirements <| |>
  Class['python::install'] -> Python::Virtualenv <| |>

  Python::Virtualenv <| |> -> Python::Pip <| |>
}
