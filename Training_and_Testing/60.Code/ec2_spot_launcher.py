#!/usr/bin/python

from string import Template

# import boto.ec2
import sys
import boto3
import json, ast

# PUPPET_SOURCE = 'https://bitbucket.org/rimey/hello-ec2-puppetboot.git'

# PUPPET_SOURCE = 'git@bitbucket.org:jeffscott2/mindgrapes/wc-puppet.git'
PUPPET_SOURCE = 'git@bitbucket.org:mindgrapes/wc-puppet.git'
code="60.Code/"

# CRIME="assault"
# MODEL_I=2
# DRIVER="trainModel_assault_model_2_blob_ALL_noweather.pbs"

def get_script(crime, model_i, filename=code+'ec2_init_script.sh'):

    driver="trainModel_"+crime+"_model_"+model_i+"_blob_ALL_weather.pbs"

    template = open(filename).read()
    script = Template(template).substitute(
        puppet_source=PUPPET_SOURCE,
        vcs_known_hosts=open(code+'vcs_keys/known_hosts').read().strip(),
        vcs_deploy_public=open(code+'vcs_keys/id_rsa.pub').read().strip(),
        vcs_deploy_private=open(code+'vcs_keys/id_rsa').read().strip(),
        crime=crime,
        model_i=model_i,
        driver=driver,
    )
    print script
    return script

def request_spot_instance(crime, model_i):
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
    
    instances = client.request_spot_instances(
            DryRun=False,
            SpotPrice='0.11',
            BlockDurationMinutes=180,	# must be a multiple of 60
            LaunchSpecification={
            	'ImageId':'ami-91ae41f1',
            	'KeyName':'jeff-mbp',
            	'SecurityGroups':['launch-wizard-1'],
            	'UserData':get_script(crime, model_i),
            	'InstanceType':'r3.large',	# robbery	- testing
            	'IamInstanceProfile':{
                	'Name': 'ec2-trainer'
                }
            
            }
            )
    
    print "1"
    print instances
    print "2"
    print instances['SpotInstanceRequests']
    print "3"
    print instances['SpotInstanceRequests'][0]['Status']
    print "4"
    print instances['SpotInstanceRequests'][0]['SpotInstanceRequestId']
    print "5"
    requestId=instances['SpotInstanceRequests'][0]['SpotInstanceRequestId']
    
    client.create_tags(
        DryRun=False,
        Resources=[requestId],
        Tags=[{'Key':'Name','Value': crime +' - '+ model_i}]
    )
    return instances           
    

if __name__ == '__main__':
    crime	=	sys.argv[1]
    model_i	=	sys.argv[2]
    instance = request_spot_instance(crime, model_i)
    print instance
