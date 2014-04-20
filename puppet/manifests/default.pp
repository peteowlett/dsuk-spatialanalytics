Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

exec { 'apt-get update':
  command => 'apt-get update',
  timeout => 60,
  tries   => 3,
}

Exec["apt-get update"] -> Package <| |>

resources { "firewall":
  purge => true
}

class { 'firewall': }

class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses           => '*',
  ipv4acls                   => ['host all all 0.0.0.0/0 password'],
  manage_firewall            => false
}

postgresql::server::db { 'dsuser':
  user     => 'dsuser',
  password => postgresql_password('dsuser', 'password'),
}

firewall { '001 open postgres port':
  iniface => 'eth1',
  port => 5432,
  proto => tcp,
  action => accept,
}


