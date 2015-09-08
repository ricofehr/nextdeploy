# == Class: pm::elastic
#
# Install elasticsearch with help of official modules
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::elastic {
  Exec {
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
    user => 'modem',
    group => 'www-data',
    unless => 'test -f /home/modem/.esrun',
    environment => ["HOME=/home/modem"]
  }

  #elastic setting
  class { 'elasticsearch': }
  ->
  exec { 'defaultes':
    command => 'sed -i "s;#START_DAEMON=true;START_DAEMON=true;" /etc/default/elasticsearch',
    onlyif => 'test -f /etc/default/elasticsearch',
    user => 'root'
  }
  ->
  exec { 'reastartes':
    command => 'service elasticsearch restart',
    onlyif => 'test -f /etc/default/elasticsearch',
    user => 'root'
  }
  ->
  exec { 'touches':
    command => 'touch /home/modem/.esrun'
  }
}