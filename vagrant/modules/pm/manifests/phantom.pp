# == Class: pm::phantom
#
# Install phantomjs with help of community module
#
#
# === Authors
#
# Eric Fehr <ricofehr@nextdeploy.io>
#
class pm::phantom {
    class { '::phantomjs':
        package_version => '2.1.1',
        package_update => true,
        install_dir => '/usr/local/bin',
        source_dir => '/opt',
        timeout => 300
    }

    ensure_packages(['imagemagick'])
}
