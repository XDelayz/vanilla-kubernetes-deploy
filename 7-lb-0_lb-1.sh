Встановити Keepalived на обох балансерах
apt update
apt install keepalived -y

на lb-0
дізнайтесь який у вас на машині interface ens3

nano /etc/keepalived/keepalived.conf

global_defs {
    router_id LB0
}

vrrp_instance VI_1 {
    state MASTER
    interface ens3
    virtual_router_id 51
    priority 200
    advert_int 1

    authentication {
        auth_type PASS
        auth_pass Kubernetes
    }

    virtual_ipaddress {
        192.168.2.150/24
    }
}

на lb-1
nano /etc/keepalived/keepalived.conf

global_defs {
    router_id LB1
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens3
    virtual_router_id 51
    priority 100
    advert_int 1

    authentication {
        auth_type PASS
        auth_pass Kubernetes
    }

    virtual_ipaddress {
        192.168.2.150/24
    }
}

Перевірка конфіга на обох серверах
keepalived -t

запускаєм
systemctl enable keepalived
systemctl restart keepalived


На рівні віртуалізації потрібно відкрити буде 80 та 443 порти на віртуальну адресу
virtual_ipaddress 192.168.2.150
