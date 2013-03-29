class virtualbox {}

class ec2 {}

class buildbot {
    $USER = 'vagrant'
    $ROOT_PATH = '/data/buildbot'

    # Install dependencies
    Package { ensure => 'installed' }
    package { ['python-dev','python-pip','supervisor','golang','debhelper']: }

    file{ [ '/data' ]:
        owner => $USER, group => $USER, ensure => 'directory' }

    file { '/var/tmp/requirements.txt':
        content => template('buildbot/requirements.txt') }

    exec { 'requirements':
        require => [ Package['python-dev'], Package['python-pip'],
            File['/var/tmp/requirements.txt'] ],
        cwd     => '/var/tmp',
        command => "/bin/sh -c '(/usr/bin/pip install -r requirements.txt;
            rm /var/tmp/requirements.txt)'" }

    # Deploy buildbot setup
    file { '/data/buildbot-cfg.sh':
        content => template('buildbot/buildbot-cfg.sh'),
        owner   => $USER, group => $USER, mode => 755 }

    exec { 'buildbot-cfg.sh':
        require => [ Package['supervisor'], Exec['requirements'],
            File['/data/buildbot-cfg.sh'] ],
        path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
        cwd     => '/data',
        command => '/data/buildbot-cfg.sh --target .' }
}
