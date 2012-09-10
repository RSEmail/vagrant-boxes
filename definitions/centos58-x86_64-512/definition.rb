Veewee::Session.declare({
    :cpu_count => '1',
    :memory_size=> '512',
    :disk_size => '20480',
    :disk_format => 'VDI',
    :hostiocache => 'off',
    :os_type_id => 'RedHat_64',
    :iso_file => "CentOS-5.8-x86_64-netinstall.iso",
    :iso_src => "http://mirror.rackspace.com/CentOS/5.8/isos/x86_64/" +
        "CentOS-5.8-x86_64-netinstall.iso",
    :iso_md5 => "6425035e9adee4b8653a85f59877ac5b",
    :iso_download_timeout => 1000,
    :boot_wait => "10",
    :boot_cmd_sequence => [
        '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>'
    ],
    :kickstart_port => "7122",
    :kickstart_timeout => 10000,
    :kickstart_file => "ks.cfg",
    :ssh_login_timeout => "1200",
    :ssh_user => "vagrant",
    :ssh_password => "vagrant",
    :ssh_key => "",
    :ssh_host_port => "7222",
    :ssh_guest_port => "22",
    :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
    :shutdown_cmd => "/sbin/halt -h -p",
    :postinstall_files => ["postinstall.sh"],
    :postinstall_timeout => 10000
})

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
