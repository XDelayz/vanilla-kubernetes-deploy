Тепер починаємо налаштування балансера lb-0
sudo apt install haproxy
sudo nano /etc/haproxy/haproxy.cfg

додаємо наступне вказуючи назви своїх мастер та їх адреси:
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

defaults
    log global
    mode tcp
    option tcplog
    timeout connect 10s
    timeout client 1m
    timeout server 1m

frontend kubernetes
    bind *:6443
    default_backend kubernetes-masters

backend kubernetes-masters
    balance roundrobin
    option tcp-check

    server master-1 192.168.2.193:6443 check
    server master-2 192.168.2.13:6443 check
    server master-3 192.168.2.226:6443 check

Перевірка конфігурації на правильність і запуск:
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy
sudo systemctl enable haproxy
