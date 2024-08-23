Host *
    User ${username}
    IdentityFile ~/.ssh/lab_id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    ForwardAgent yes

Host gw
    HostName ${public_ip}

%{ for vm in vms ~}
Host ${vm.name}
    HostName ${vm.ip}
    ProxyJump gw
%{ endfor ~}