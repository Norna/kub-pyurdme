# !/bin/bash

declare DEFAULT_KUB_BIN="/opt/bin"
declare DEFAULT_ECTD_PORT="4001"
declare DEFAULT_USER="core"

declare -a worker_machines='()'

echo 
echo -n ">> Enter Master Machine IP:"
read -r master_machine

echo 
echo -n ">> Enter number of workers:"
read -r num_worker


for ((i=1; i<=$num_worker;i++))
do 
  echo -n ">> Worker Machine IP $i:"
  read -r worker_machines[$i] 
done	

declare -a all_machines
all_machines=($master_machine ${worker_machines[@]})
all_machines_etcd=$(printf "http://%s:$DEFAULT_ECTD_PORT," "${all_machines[@]}")
all_machines_etcd=${all_machines_etcd::-1}

declare -a controller_endpoint
controller_endpoint="https://$master_machine"

sed -e "s|__ETCD_ENDPOINTS__|$all_machines_etcd|g;s|__KUB_BIN__|$DEFAULT_KUB_BIN|g" templates/controller-install.sh.template > script/controller-install.sh

sed -e "s|__ETCD_ENDPOINTS__|$all_machines_etcd|g;s|__CONTROLLER_ENDPOINT__|$controller_endpoint|g;s|__KUB_BIN__|$DEFAULT_KUB_BIN|g" templates/worker-install.sh.template > script/worker-install.sh


# Generate certificate
mkdir -p ssl

# Generate root CA
lib/init-ssl-ca ssl

# Generate admin key/cert
lib/init-ssl ssl admin kube-admin

lib/init-ssl ssl apiserver kube-apiserver "IP.1=10.3.0.1,IP.2=$master_machine"

#work_machine_ip=$(IFS=,;echo "${worker_machines[*]}")

#echo $work_machine_ip

for ((i=1; i<=$num_worker;i++))
do 
  lib/init-ssl ssl "worker" "kube-worker-${worker_machines[i]}" "IP.1=${worker_machines[i]}"
done

echo ""
echo "Set up Master Node"
echo "============================"
echo ""

scp ssl/kube-admin.tar ssl/kube-apiserver.tar $DEFAULT_USER@$master_machine:~/
ssh core@$master_machine "sudo mkdir -p ~/kubadmin/ssl; sudo mkdir -p /etc/kubernetes/ssl;sudo tar -C ~/kubadmin/ssl/ -xf kube-admin.tar;sudo tar -C /etc/kubernetes/ssl/ -xf kube-apiserver.tar; cd /etc/kubernetes/ssl; sudo chmod 600 *-key.pem; sudo chown root:root *-key.pem ; mkdir -p /tmp/rhinokub ; cd /tmp/rhinokub ; git clone https://github.com/Norna/kubernates.git ; cd kubernates ; sudo mkdir -p $DEFAULT_KUB_BIN; sudo cp * $DEFAULT_KUB_BIN; cd ~; rm -rf /tmp/rhinokub;"
tar -czf - script/ | ssh $DEFAULT_USER@$master_machine "cd /home/core; sudo tar xzvf -; cd script; sudo chown core *.sh; sudo chmod +x *.sh"

echo ""
echo "Set up Worker Nodes"
echo "============================"
echo ""

for ((i=1; i<=$num_worker;i++))
do 
  echo ">> Node $DEFAULT_USER@${worker_machines[i]}"
  echo ""

  scp ssl/kube-worker-${worker_machines[i]}.tar $DEFAULT_USER@${worker_machines[i]}:~/
  ssh $DEFAULT_USER@${worker_machines[i]} "sudo mkdir -p /etc/kubernetes/ssl; sudo tar -C /etc/kubernetes/ssl/ -xf kube-worker-${worker_machines[i]}.tar; cd /etc/kubernetes/ssl; sudo chmod 600 *-key.pem; sudo chown root:root *-key.pem ; mkdir -p /tmp/rhinokub ; cd /tmp/rhinokub ; git clone https://github.com/Norna/kubernates.git ; cd kubernates ; sudo mkdir -p $DEFAULT_KUB_BIN; sudo cp * $DEFAULT_KUB_BIN; cd ~; rm -rf /tmp/rhinokub;"
  tar -czf - script/ | ssh $DEFAULT_USER@${worker_machines[i]} "cd /home/core; sudo tar xzvf -; cd script; sudo chown core *.sh; sudo chmod +x *.sh"

done

echo ""
echo "Prepare Master Node"
echo "============================"
echo ""

ssh core@$master_machine "wget https://storage.googleapis.com/kubernetes-release/release/v1.0.6/bin/linux/amd64/kubectl; chmod +x kubectl; sudo mv kubectl /opt/bin/kubectl; cd ~/script ; sudo ./controller-install.sh; cd ~/kubadmin ; kubectl config set-cluster default-cluster --server=https://$master_machine:443 --certificate-authority=${PWD}/ssl/ca.pem; kubectl config set-credentials default-admin --certificate-authority=${PWD}/ssl/ca.pem --client-key=${PWD}/ssl/admin-key.pem --client-certificate=${PWD}/ssl/admin.pem; kubectl config set-context default-system --cluster=default-cluster --user=default-admin; kubectl config use-context default-system"

echo ""
echo "Prepare Woker Nodes"
echo "============================"
echo ""

for ((i=1; i<=$num_worker;i++))
do 
  echo ">> Node $DEFAULT_USER@${worker_machines[i]}"
  echo ""

  ssh $DEFAULT_USER@${worker_machines[i]} "cd ~/script ; sudo ./worker-install.sh;"

done

echo ""
echo "DONE!"





