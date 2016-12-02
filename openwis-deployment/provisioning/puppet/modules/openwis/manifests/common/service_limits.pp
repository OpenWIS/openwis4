define openwis::common::service_limits (
  $service,
  $nofile = undef,
  $stack  = undef)
#
{
  include openwis::common::systemd

  if $nofile != undef {
    augeas { "update-${service}-nofiles":
      incl    => "/usr/lib/systemd/system/${service}.service",
      lens    => "Systemd.lns",
      context => "/files/usr/lib/systemd/system/${service}.service",
      changes => [
        "defnode nofile Service/LimitNOFILE \"\"",
        "set \$nofile/value \"${nofile}\""],
      notify  => Exec[systemd-daemon-reload],
    }
  }

  if $stack != undef {
    augeas { "update-${service}-stack":
      incl    => "/usr/lib/systemd/system/${service}.service",
      lens    => "Systemd.lns",
      context => "/files/usr/lib/systemd/system/${service}.service",
      changes => [
        "defnode stack Service/LimitSTACK \"\"",
        "set \$stack/value \"${stack}\""],
      notify  => Exec[systemd-daemon-reload],
    }
  }
}
