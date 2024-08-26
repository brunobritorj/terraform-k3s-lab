frontend http-in
    mode tcp
    bind *:80
    default_backend k3s-http

frontend https-in
    mode tcp
    bind *:443
    default_backend k3s-https

backend k3s-http
    mode tcp
    balance roundrobin
    option tcp-check
%{ for vm in vms ~}
    server ${vm.name} ${vm.ip}:80 check
%{ endfor ~}

backend k3s-https
    mode tcp
    balance roundrobin
    option tcp-check
%{ for vm in vms ~}
    server ${vm.name} ${vm.ip}:443 check
%{ endfor ~}
