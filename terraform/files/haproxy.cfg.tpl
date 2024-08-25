frontend http-in
    mode tcp
    bind *:80
    default_backend k3s

backend k3s
    mode tcp
    balance roundrobin
    option tcp-check
%{ for vm in vms ~}
    server ${vm.name} ${vm.ip}:80 check
%{ endfor ~}
