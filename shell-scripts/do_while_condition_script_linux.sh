. ~/.bashrc
gcloud components install kubectl gke-gcloud-auth-plugin --quiet
gcloud container clusters create test-cluster \
--zone "$ZONE" \
--enable-private-nodes \
--enable-private-endpoint \
--enable-ip-alias \
--num-nodes=1 \
--master-ipv4-cidr "172.16.0.0/28" \
--enable-master-authorized-networks \
--master-authorized-networks "$IP"
sleep 30
while true; do
    output=$(kubectl describe daemonsets container-watcher -n kube-system)
    if [[ $output == *container-watcher-unique-id* ]]; then
        echo "Found unique ID in the output:"
        echo "$output"
        break
    else
        echo "Please Wait for sometime..."
        sleep 10
    fi
done
