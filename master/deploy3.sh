echo '*********************** Centos 7.5 *************************'
echo 'Deploying ElasticSearch and Kibana on Cloud VM..............'
echo '**************************** By am.chamkha@gmail.com ******'




echo '**************  Create efk user without password  ***********'
sudo useradd -m efk
echo 'Done'
echo '*************************************************************'



echo '************************************************************'
echo '********************* JDK configuration ********************'
echo '************************************************************'
echo '1- Installing OpenJdk 1.8 ...'
yum install java-1.8.0-openjdk-devel unzip -y
echo 'Done'
echo '************************************************************'



echo '************************************************************'
echo '********** Elastic Search 7.7.0 OSS Install ****************'
echo '************************************************************'

echo '2- Create a working dir ************************************'
mkdir /home/efk/deploy
echo 'Done'

echo 'move to create dir *****************************************'
cd /home/efk/deploy
echo 'Done'

echo '3- Download ElasticSearch 7.7.0 OSS ************************'
curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.7.0-linux-x86_64.tar.gz
echo 'Done'

echo '4- Untar downloaded package ********************************'
tar -xzf elasticsearch-oss-7.7.0-linux-x86_64.tar.gz
mv elasticsearch*/ elasticsearch
cd elasticsearch
sudo ln -s /usr/lib/jvm/java-1.8.0/lib/tools.jar lib/

echo '5- Download and Install OpenDistro JOB SCHEDULER plugin **'
sudo bin/elasticsearch-plugin install --batch https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/opendistro-job-scheduler/opendistro-job-scheduler-1.8.0.0.zip
echo 'Done'

echo '6- Download and Install OpenDistro Alerting plugin for ElasticSearch ... '
sudo bin/elasticsearch-plugin install --batch https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/opendistro-alerting/opendistro_alerting-1.8.0.0.zip
echo '... Done.'
echo '-----------------------------------------------------------------------------------------------------------------------------------------------------'

echo '6- Configuring network-host parameter for elasticsearch '
#echo 'network.host: 0.0.0.0' >> config/elasticsearch.yml
#echo 'network.bind_host: 0.0.0.0' >> config/elasticsearch.yml
#echo 'node.master: true' >> config/elasticsearch.yml
#echo 'node.data: true' >> config/elasticsearch.yml
#echo 'transport.host: localhost' >> config/elasticsearch.yml
echo 'cluster.name: hysOssCluster' >> config/elasticsearch.yml
echo 'network.host: 0.0.0.0' >> config/elasticsearch.yml
echo 'discovery.type: single-node' >> config/elasticsearch.yml
#echo 'http.host: 0.0.0.0' >> config/elasticsearch.yml
#echo 'discovery.type: single-node' >> config/elasticsearch.yml
#echo 'transport.host: localhost' >> config/elasticsearch.yml
echo '... Done'

#network.host: 127.0.0.1
#http.host: 0.0.0.0
#transport.host: localhost
#network.host: 0.0.0.0
#transport.host: localhost
#transport.tcp.port: 9300
#http.port: 9200
#network.host: 0.0.0.0
echo '-----------------------------------------------------------------------------------------------------------------------------------------------------'




echo '7- Change elasticsearch folder permissions to efk user'
chown -R efk /home/efk/deploy/elasticsearch
echo '...done'


echo '*****************************************************************'
echo '**************** Kibana 7.7.0 OSS install  **********************'
echo '*****************************************************************'

echo '1- Download Kibana 7.7.0 OSS package'
cd /home/efk/deploy
curl -O https://artifacts.elastic.co/downloads/kibana/kibana-oss-7.7.0-linux-x86_64.tar.gz
echo '...done'

echo '2- untar Kibana downloaded package******************************'
tar -xzf kibana-oss-7.7.0-linux-x86_64.tar.gz
echo '...done'

echo '3- Rename Kibana folder*****************************************'
mv kibana*/ kibana
echo 'Done'

echo '4- Move to kibana Folder****************************************'
cd /home/efk/deploy/kibana
chown -R efk /home/efk/deploy/kibana
echo 'Done'


echo '5- Install OpenDistro Alerting plugin for Kibana'
sudo bin/kibana-plugin install --batch https://d3g5vo6xdbdb9a.cloudfront.net/downloads/kibana-plugins/opendistro-alerting/opendistro-alerting-1.8.0.0.zip

echo '6- Config Kibana parameters'
echo 'server.host: 0.0.0.0' >> config/kibana.yml
echo 'elasticsearch.hosts: ["http://localhost:9200"]' >> config/kibana.yml
echo '....done'

#------------------------------------------------------------------------------------------------------------------------------------------------------
echo '7- change kibana folder permissions to efk user'
chown -R efk /home/efk/deploy/kibana
#------------------------------------------------------------------------------------------------------------------------------------------------------

echo '*****************************************************************'
echo '******* Download and install MetricBeat 7.7.0 OSS ***************'
echo '*****************************************************************'

echo '1- Move to deplyment folder ************************************' 
cd /home/efk/deploy
echo 'Done'

echo '2- Download Metricbeat OSS package*****************************'
curl -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-oss-7.7.0-linux-x86_64.tar.gz
echo 'Done'


echo '2- untar metricbeat downloaded package*************************'
mv metric* metricbeat.tar.gz
tar -xzf metricbeat.tar.gz
mv metric*/ metricbeat

chown -R efk /home/efk/deploy/metricbeat
cd /home/efk/deploy/metricbeat
mv metricbeat.yml metricbeat.yml.orig
echo 'Done'

echo '3- Load metricbeat config file from Github********************'
curl -O https://raw.githubusercontent.com/hyscham/terraform/master/metricbeat.yml
echo 'Done'

echo '4- Change metricbeat folder permissions to efk user*********' 
chown -R efk /home/efk/deploy/metricbeat
echo 'Done'
echo '************************ Loading metricbeat dashboards**************************************'
su efk -c "./metricbeat setup --dashboards"
echo '*********************************************************************************************'

echo '****************************  display server IP for outside tests ****************************'
curl ifconfig.co
echo '**********************************************************************************************'

echo '**************************** Install Fluend ***************************************************'
sudo curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sh
echo '*.* @10.0.2.100:5140' >> /etc/rsyslog.conf
sudo systemctl restart rsyslog

cd /etc/td-agent
sudo mv td-agent.conf td-agent.conf.orig
sudo curl -O https://raw.githubusercontent.com/hyscham/terraform/master/td-agent.conf
sudo systemctl restart td-agent
echo '*********************************** End FlentD config ********************************************'

echo '*************************** Start Elastic in daemon mode *****************************************'
cd /home/efk/deploy/elasticsearch/bin
su efk -c "./elasticsearch &"
#su efk -c "./elasticsearch -d &"

sleep 30 ; echo "Fin du sleep!!"

echo '*************************** Start Kibana in daemon mode ****************************************'
cd /home/efk/deploy/kibana/bin
su efk -c "./kibana &"
echo '************************************************************************************************'

sleep 30 ; echo "Fin du sleep!!"


echo '***************************         Start MetricBeat    ****************************************'
cd /home/efk/deploy/metricbeat
su efk -c "./metricbeat -e &" 
#sudo ./metricbeat run &



echo '*************  Connect to server IP for outside tests ******************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo "************************  http://`curl ifconfig.co`:5601****************************************"
echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'


echo '************************************ Ssh config (Permit PasswordAuth) **************************'
echo 'Permit ssh login with password after deployment to fine tune configuration'
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo '************************************************************************************************'


acho 'END SERVER CONFIG'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo ' CAP GEMINI '
echo '**************************************   All rights reserved by Capgemini. Copyright © 2020 ****'
echo '************************************************************************************************'
echo '************************************************************************************************'
echo '************************************************************************************************'
