#!/usr/local/bin/python
import sys
import boto3
import os

s3 = boto3.client('s3')

# for bucket in s3.buckets.all():
#        print(bucket.name)

if len(sys.argv) < 3:
    raise ValueError('You must pass in the s3 filename as well as where to put it')


bucket="cs-training-data"
#path=sys.argv[1]
#filename=os.path.basename(path)
s3_filename=sys.argv[1]
out_filename=sys.argv[2]

print 'Downloading from S3: ' + s3_filename

#s3.Bucket(bucket).put_object(Key=filename, Body=data)
s3.download_file(bucket, s3_filename, out_filename)
