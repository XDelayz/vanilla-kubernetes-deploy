Йдемо на VM master-1, важливо замінити адресу 192.168.2.154 на virtual_ipaddress 192.168.2.150/24 це адреса яка піднімається разом з кіпалівед

sudo kubeadm init \
  --control-plane-endpoint="192.168.2.154:6443" \
  --upload-certs \
  --pod-network-cidr=10.244.0.0/16

В кінці буде вивід наступний, треба буде зберегти для підключення інших master і worker

Приклад:
You can now join any number of control-plane nodes running the following command on each as root:

  kubeadm join 192.168.2.152:6443 --token cezytc.a1aagzrscypy5woy \
	--discovery-token-ca-cert-hash sha256:8b8e59287bf428902abf8812ac5d90c2bd88bed236ea2c22792daf40d98db3b3 \
	--control-plane --certificate-key fcc171d85f9df6aef9f0c448750bcf028f9861036af586c4cb17a3e30bf3c778

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.2.152:6443 --token cezytc.a1aagzrscypy5woy \
	--discovery-token-ca-cert-hash sha256:8b8e59287bf428902abf8812ac5d90c2bd88bed236ea2c22792daf40d98db3b3 

Запускаємо команди
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Перевіряємо що ноди підключились
kubectl get nodes:
NAME                 STATUS     ROLES           AGE     VERSION
master-1.novalocal   NotReady   control-plane   6m13s   v1.34.9
master-2.novalocal   NotReady   control-plane   3m17s   v1.34.9
master-3.novalocal   NotReady   control-plane   2m14s   v1.34.9

Встановити Flannel на master-1
ставимо helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add flannel https://flannel-io.github.io/flannel/
helm repo update

helm install flannel flannel/flannel \
  --namespace kube-flannel \
  --create-namespace

kubectl get pods -n kube-flannel -w
чекаємо поки все запуститься

Тепер, коли control plane повністю готовий, перенесемо адміністрування на bastion.
На VM master-1:
scp /etc/kubernetes/admin.conf root@IP-bastion:/tmp/
