#!/bin/sh
set -x

# Log to /var/log/syslog and /var/log/user-data.log
# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

s3_apps=${job_name}/apps
model_dir=model_${model_i}
s3_zip=$$s3_apps/$${model_dir}.tar.gz
zip=$${model_dir}.tar.gz

s3_model_upload_dir=${job_name}/models

home=/home/ubuntu/
wd=$$home/$${model_dir}
log=$$home/model.log

echo "ec2_init_scrip.sh"	 > $$log
echo "Uploading to $$s3_model_upload_dir" >> $$log



echo "Scheduling a shutdown in max 6 hours"	 >> $$log
echo "python $$home/upload_data_to_s3.py $$log NNmodel_${model_i}.rds.log; sudo halt" | at now + 355 minutes		>> $$log

apt-get --yes --quiet update						2>&1 >> $$log 
apt-get --yes --quiet install git puppet-common		2>&1 >> $$log 

#
# Set up ssh keys to enable git read access.
#

cat <<EOF >>/root/.ssh/known_hosts
$vcs_known_hosts
EOF

cat <<EOF >/root/.ssh/id_rsa.pub
$vcs_deploy_public
EOF

cat <<EOF >/root/.ssh/id_rsa
$vcs_deploy_private
EOF

chmod 600 /root/.ssh/id_rsa

#
# Fetch puppet configuration from public git repository.
#

mv /etc/puppet /etc/puppet.orig
git clone $puppet_source /etc/puppet				2>&1 >> $$log

#
# Run puppet.
#

puppet apply /etc/puppet/manifests/init.pp			2>&1 >> $$log


# Download work from S3

python $$home/download_data_from_s3.py $$s3_zip $$home/$$zip			2>&1 >> $$log
echo "Download finished" >> $$log

while [ ! -f $$home/$$zip ]
do
  echo "waiting for $$home/$$zip to finish downloading"	>> $$log
  sleep 1
done

# Expand zip to create the working directory, wd
echo "Found "	>> $$log
echo "tar -zxf $$home/$$zip -C $$home"
tar -zxf $$home/$$zip -C $$home				2>&1 >> $$log
echo "Expanded" >> $$log


echo "The driver has its own log in its directory" >> $$log
echo "Running $$wd/$driver" >> $$log
$$wd/$driver							2>&1 >> $$log


echo "Uploading Model" >> $$log

echo "python $$wd/upload_data_to_s3.py $$wd/NNmodel_${model_i}.rds $$s3_model_upload_dir/NNmodel_${job_name}_${model_i}.rds" >> $$log
python $$wd/upload_data_to_s3.py $$wd/NNmodel_${model_i}.rds $$s3_model_upload_dir/NNmodel_${job_name}_${model_i}.rds	2>&1 >> $$log

echo "python $$wd/upload_data_to_s3.py $$log $$s3_model_upload_dir/NNmodel_${city}_${model_i}.rds.log" >> $$log
python $$wd/upload_data_to_s3.py "$$log" "$$s3_model_upload_dir/NNmodel_${city}_${model_i}.rds.log" 				2>&1 >> $$log

echo "*** Upload Complete ***" >> $$log


halt