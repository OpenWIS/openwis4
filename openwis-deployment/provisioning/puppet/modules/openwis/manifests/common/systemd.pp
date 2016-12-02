class openwis::common::systemd ()
{
  exec { "systemd-daemon-reload":
    command     => "systemctl daemon-reload",
    timeout     => 0,
    user        => "root",
    refreshonly => true,
    path        => $::path
  }
}
