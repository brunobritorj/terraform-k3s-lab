frontend http-in
    bind *:80
    default_backend servers

backend servers
%{ for vm in vms ~}
    server ${vm.name} ${vm.ip}:80 check
%{ endfor ~}
