echo '*********************** Centos 7.5 *************************'
echo 'Config rsyslog, td-agent et metricbeat on Cloud VM..........'
echo '**************************** By am.chamkha@gmail.com ******'



echo '**************  Create efk user without password  ***********'
sudo useradd -m efk
echo 'Done'
echo 'add user efk to sudoers:'
sudo usermod –aG wheel efk
echo '*************************************************************'



echo '2- Create a working dir *************************************'
mkdir /home/efk/deploy
echo '.... done'


echo '************************************************************'
echo '********************* JDK configuration ********************'
echo '************************************************************'
echo '1- Installing OpenJdk 1.8 ...'
yum install java-1.8.0-openjdk-devel unzip -y
echo '.....done'
echo '************************************************************'

echo '************************************************************'
echo '******* Download and install MetricBeat 7.7.0 OSS **********'
echo '************************************************************'

echo '1- Move to deplyment folder ********************************' 
cd /home/efk/deploy


echo '2- Download Metricbeat OSS package *************************'
curl -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-oss-7.7.0-linux-x86_64.tar.gz
echo 'Done'

echo '3- untar metricbeat downloaded package *********************'
mv metric* metricbeat.tar.gz
tar -xzf metricbeat.tar.gz
mv metric*/ metricbeat
echo 'Done'


chown -R efk /home/efk/deploy/metricbeat
cd /home/efk/deploy/metricbeat
mv metricbeat.yml metricbeat.yml.orig


echo '3- Load metricbeat config file from Github ******************'
curl -O https://raw.githubusercontent.com/the-ac/terraform/master/master/metricbeat-clt.yml
echo 'Done'

echo '3-1 Rename metricbeat config file from Github **************'
mv metricbeat-clt.yml metricbeat.yml
echo 'Done'

echo '4- Change metricbeat folder permissions to efk user*********' 
chown -R efk /home/efk/deploy/metricbeat
echo 'Done'

echo '****************************  display server IP for outside tests ****************************'
curl ifconfig.co
echo '**********************************************************************************************'

echo '**************************** Install Fluend ***************************************************'
sudo curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sh
echo '*.* @10.0.2.101:5140' >> /etc/rsyslog.conf
sudo systemctl restart rsyslog

cd /etc/td-agent
sudo mv td-agent.conf td-agent.conf.orig
sudo curl -O https://raw.githubusercontent.com/the-ac/terraform/master/master/td-agent.conf

sudo systemctl restart td-agent
echo '*********************************** End FlentD config ********************************************'




echo '***************************         Start MetricBeat    ****************************************'
cd /home/efk/deploy/metricbeat
sudo curl -O https://raw.githubusercontent.com/the-ac/terraform/master/master/metricbeat_autostarter.sh
chown -R efk /home/efk/deploy/metricbeat
sudo chmod 777 metricbeat_autostarter.sh
su efk -c "./metricbeat_autostarter.sh &"

#nohup bash -c 'su efk -c "while [ true ]; do echo test; done;"' &
#while true;do ./metricbeat run -e;sleep 5;done;
#sudo ./metricbeat run &



echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'



echo '************************************ Ssh config (Permit PasswordAuth) **************************'
echo 'Permit ssh login with password after deployment to fine tune configuration'
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo '************************************************************************************************'

echo "END CLIENT CONFIG"
echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo ' CAP GEMINI '
echo '**************************************   All rights reserved by Capgemini. Copyright © 2020 ****'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'
