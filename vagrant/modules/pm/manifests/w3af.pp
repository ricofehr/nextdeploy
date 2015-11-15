# == Class: pm::w3af
#
# Install w3af audit tools and other dependencies
#
#
# === Authors
#
# Eric Fehr <eric.fehr@publicis-modem.fr>
#
class pm::w3af {
  Exec {
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/opt/bin" ],
    user => 'root'
  }

  # w3af is used by security scan into jenkins
  package { [
  'python-lxml',
  'python-scapy',
  'python-setuptools',
  'python-pip',
  'libssl-dev',
  'python2.7-dev',
  'libsqlite3-dev',
  'libffi-dev',
  'libjpeg-dev',
  'libyaml-dev']
  :
    ensure => latest,
  } ->

  exec { 'clonew3af':
    command => 'git clone https://github.com/andresriancho/w3af.git',
    cwd => '/opt',
    creates => '/root/.w3af'
  } ->

  exec { 'chmodw3af':
    command => 'chmod a+x /opt/w3af/w3af_console',
    creates => '/root/.w3af'
  } ->
  
  exec { 'pipupdate':
    command => 'pip install --upgrade pip',
    creates => '/root/.w3af'
  } ->

  exec { 'pipdependencies':
    command => 'pip install pyClamd==0.3.15 PyGithub==1.21.0 GitPython==0.3.2.RC1 pybloomfiltermmap==0.3.14 esmre==0.3.1 phply==0.9.1 nltk==3.0.1 chardet==2.1.1 tblib==0.2.0 pdfminer==20140328 futures==2.1.5 pyOpenSSL==0.15.1 ndg-httpsclient==0.3.3 pyasn1==0.1.8 lxml==3.4.4 scapy-real==2.2.0-dev guess-language==0.2 cluster==1.1.1b3 msgpack-python==0.4.4 python-ntlm==1.0.1 halberd==0.2.4 darts.util.lru==0.5 Jinja2==2.7.3 vulndb==0.0.19 markdown==2.6.1 psutil==2.2.1 mitmproxy==0.13 ruamel.ordereddict==0.4.8 Flask==0.10.1 PyYAML==3.11',
    creates => '/root/.w3af'
  } ->
  
  exec { 'touchw3af':
    command => 'touch /root/.w3af',
    creates => '/root/.w3af'
  } ->

  exec { 'pullw3af':
    command => 'git pull',
    cwd => '/opt/w3af'
  }
}