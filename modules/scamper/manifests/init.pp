class scamper {

    package { 'scamper':
        ensure      => 'latest',
    }

    file { "/etc/init/scamper.conf":
        source => "puppet:///scamper/upstart-scamper.conf",
    }

    service { "scamper":
        ensure      => 'running',
        provider    => 'upstart',
        require     => [Package['scamper'], File['/etc/init/scamper.conf']],
        restart     => "stop scamper; start scamper",
        subscribe   => File["/etc/init/scamper.conf"],
    }

    file { "/home/scamper/collected/":
        ensure => directory,
        owner => "scamper",
        group => "scamper",
        require => User["scamper"],
    }

    $first = fqdn_rand(30)
    $second = (fqdn_rand(30) + 30)

    cron { "collect_all_traces":
        user => "scamper",
        command => "/usr/bin/sc_attach -p 23456 -c trace -i /etc/ring/node-list.txt -o /home/scamper/collected/$(hostname)-$(date +%s).warts; gzip -9 /home/scamper/collected/*.warts ; chmod +r /home/scamper/collected/*",
        minute => [$first, $second],
        hour => "*",
        require => [Service["scamper"], File["/home/scamper/collected/"]],
    }

    cron { "clean_scamper":
        user => "scamper",
        command => "find /home/scamper/collected/* -mtime +8 -exec rm {} \;",
        minute => "10",
        hour => "00",
        require => FIle["/home/scamper/collected/"],
    }
}
