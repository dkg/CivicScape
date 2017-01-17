#!/usr/local/bin/python
import sys
import boto3
import os

s3 = boto3.resource('s3')

# for bucket in s3.buckets.all():
#        print(bucket.name)

if len(sys.argv) < 2:
    raise ValueError('You must pass in the filename to upload')


bucket="cs-training-data"
path=sys.argv[1]
if len(sys.argv) >= 3:
    filename=sys.argv[2]
else:
    filename=os.path.basename(path)

print 'Uploading to S3: ' + path
print '  Storing @ ' + filename


s3.meta.client.upload_file(path, bucket, filename)
