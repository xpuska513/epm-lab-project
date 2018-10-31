#!/bin/bash
### Start of script vars ###
### End of script vars ###

echo "Applying terraform scheme"
    cd ~/infrastracture/ || exit 5
    terraform apply -auto-approve
echo "Provision of machines with Ansible"
    export ANSIBLE_HOSTS=$(pwd)/ec2.py
    export EC2_INI_PATH=$(pwd)/ec2.ini
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ec2.py --private-key=./1.pem ./ansible/jenkins_playbook/site.yml
echo "Copy private key to jenkins instance"
    scp -i 1.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no 1.pem ec2-user@"$(terraform output jenkins_ip)":/home/ec2-user/
    ssh -i 1.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@"$(terraform output jenkins_ip)" "sudo mkdir -p /var/lib/jenkins/.ssh && sudo cp /home/ec2-user/1.pem /var/lib/jenkins/.ssh/id_rsa && sudo chmod 400 /var/lib/jenkins/.ssh/id_rsa && sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa"
echo "Copy job and user info to jenkins"
    scp -i 1.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ../other/build_and_deploy_app.tgz ec2-user@"$(terraform output jenkins_ip)":/home/ec2-user/
    ssh -i 1.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@"$(terraform output jenkins_ip)" "sudo tar xvzf build_and_deploy_app.tgz -C /var/lib/jenkins/jobs"
    ssh -i 1.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@"$(terraform output jenkins_ip)" "sudo sed -i 's%<defaultValue>127.0.0.1</defaultValue>%<defaultValue>$(terraform output application_private_ip)</defaultValue>%g' /var/lib/jenkins/jobs/build_and_deploy_app/config.xml"
echo "Done login to Jenkins by using next page: http://$(terraform output jenkins_ip)/node_info.html"