Тепер переходимо до worker-1
sudo swapoff -a

відкрити sudo nano /etc/fstab
закоментувати рядок swap.img

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

sudo sysctl --system

Встановлюємо containerd
sudo apt update
sudo apt install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

перезапуск
sudo systemctl restart containerd
systemctl status containerd
sudo systemctl enable containerd

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' \
| sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm
sudo apt-mark hold kubelet kubeadm

потім підключаємо worker-1

kubeadm join 192.168.2.154:6443 --token ydao3b.nes7wcv7jiw2lb48 \
  --discovery-token-ca-cert-hash sha256:e3caf62c33119cbd1fe8fadace72874c53e82703c9d8f188fc0085958fd70fed 

З bastion перевіряєм:
kubectl get nodes
NAME                 STATUS     ROLES           AGE     VERSION
master-1.novalocal   Ready      control-plane   50m     v1.34.9
master-2.novalocal   Ready      control-plane   47m     v1.34.9
master-3.novalocal   Ready      control-plane   46m     v1.34.9
worker-1.novalocal   Ready      <none>          7m53s   v1.34.9
worker-2.novalocal   Ready      <none>          2m52s   v1.34.9
worker-3.novalocal   NotReady   <none>          8s      v1.34.9
