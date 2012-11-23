class munin::node (
    $libvirt_plugin      = true,
    $nova-plugin         = false,
    $glance-plugin       = false,
    $keystone-plugin     = false,
    $swift-plugin        = false,
    $cinder-plugin       = false
) {
    package {'munin-node':
        ensure => present,
        }
    file {'/etc/munin/munin-node.conf':
        ensure  => present,
        source  => 'puppet:///modules/munin/munin-node.conf',
        require => Package['munin-node']
        }
    service {'munin-node':
        ensure  => true,
        subscribe => File['/etc/munin/munin-node.conf'],
        }
    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
    if $libvirt-plugin == true {
        package {'munin-libvirt-plugins':
            ensure  => present
                }
        exec {'enable_libvirt_plugin':
            command     => 'munin-libvirt-plugins-detect  -r',
            subscribe   => Package['munin-libvirt-plugins'],
            refreshonly => true
            }
        }
    exec {'download_openstack_plugins':
            cwd         => '/tmp',
            command     => 'git clone git://github.com/NewpTone/openstack-munin.git',
            unless      => "test -d /tmp/openstack-munin"
         }
    exec {'update_plugin':
            cwd         => '/tmp/openstack-munin',
            command     => 'git pull origin master && cp * /usr/share/munin/plugins',
            require     => Exec['download_openstack_plugins'],
            refresh       => true,
         }

    if $nova-plugin == true {
        exec {'ln_nova_plugin':
            cwd         => '/usr/share/munin/plugins/',
            command     => 'ln -s /tmp/openstack-munin/nova_services && \
                            ln -s /tmp/openstack-munin/nova_instance_timing && \
                            ln -s /tmp/openstack-munin/nova_instance_launched && \
                            ln -s /tmp/openstack-munin/nova_floating_ips',
             }
        }
        

}


