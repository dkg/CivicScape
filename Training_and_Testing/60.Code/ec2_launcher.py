#!/usr/bin/python

from string import Template

# import boto.ec2
import sys
import boto3
# PUPPET_SOURCE = 'https://bitbucket.org/rimey/hello-ec2-puppetboot.git'

# PUPPET_SOURCE = 'git@bitbucket.org:jeffscott2/mindgrapes/wc-puppet.git'
PUPPET_SOURCE = 'git@bitbucket.org:mindgrapes/wc-puppet.git'
code="60.Code/"

# CRIME="assault"
# MODEL_I=2
# DRIVER="trainModel_assault_model_2_blob_ALL_noweather.pbs"

def get_script(job_name, city, crime, model_i, filename=code+'ec2_init_script.sh'):

    driver="trainModel_model_"+model_i+"_blob_ALL_weather.pbs"

    template = open(filename).read()
    script = Template(template).substitute(
        puppet_source=PUPPET_SOURCE,
        vcs_known_hosts=open(code+'vcs_keys/known_hosts').read().strip(),
        vcs_deploy_public=open(code+'vcs_keys/id_rsa.pub').read().strip(),
        vcs_deploy_private=open(code+'vcs_keys/id_rsa').read().strip(),
        job_name=job_name,
        city=city,
        crime=crime,
        model_i=model_i,
        driver=driver,
    )
    #print script
    return script

def getInstanceSize(city, crime):
# 't2.micro' 1G - seattle assault, robbery
#InstanceType='t2.small',	# 2G
#InstanceType='t2.medium',	# 4G 
#InstanceType='t2.large',	# 8G 
#InstanceType='r3.large',	# 15G
    print "Allocating for " + city + " - " + crime
    size = 't2.small'
    
    if city == 'philadelphia_pa':
        size = 'r3.large'

    elif city == 'chicago_il': 
        size = 'r3.large'

    else: 't2.large'
        
    print("Spawning " + size)
    return size
    
def launch(job_name, city, crime, model_i):
    # connection = boto.ec2.connect_to_region('us-east-1')
#    return connection.run_instances(
#        image_id = 'ami-6ba27502',  # us-east-1 oneiric i386 ebs 20120108
#        instance_type = 't1.micro',
#        key_name = 'awskey',
#        security_groups = ['default'],
#        user_data=get_script(),
#    )
    client = boto3.client('ec2')
    ec2 = boto3.resource('ec2')
    instances = ec2.create_instances(
            DryRun=False,
            ImageId='ami-91ae41f1',
            MinCount=1, MaxCount=1,
            KeyName='jeff-mbp',
            SecurityGroups=['launch-wizard-1'],
            InstanceType=getInstanceSize(city,crime),
            InstanceInitiatedShutdownBehavior='terminate',
            UserData=get_script(job_name, city, crime, model_i),
            IamInstanceProfile={
                'Name': 'ec2-trainer'
                }
            )
    client.create_tags(
        DryRun=False,
        Resources=[instances[0].id],
        Tags=[{'Key':'Name','Value': city + ' - ' + crime +' - '+ model_i}]
    )
    return instances           
    

if __name__ == '__main__':
    job_name= 	sys.argv[1]
    city 	= 	sys.argv[2]
    crime	=	sys.argv[3]
    model_i	=	sys.argv[4]
    instance = launch(job_name, city, crime, model_i)
    print instance
