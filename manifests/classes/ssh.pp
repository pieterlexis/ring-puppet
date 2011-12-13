class ssh {

    file { "/etc/ssh/ssh_known_hosts":
        ensure => present,
        mode => 644,
    }

    @@sshkey { 
        "${hostname}": 
            host_aliases => ["${fqdn}"],
            type => ssh-dss,
            key => "${sshdsakey}",
            require => File["/etc/ssh/ssh_known_hosts"],
    }

# we don't need both DSA and RSA hostkeys
#        "${hostname}-rsa": 
#            host_aliases => ["${fqdn}","${hostname}"], 
#            type => ssh-rsa,
#            key => "${sshrsakey}";

    Sshkey <<| |>>

    resources { sshkey:
        purge => true,
    }
}
