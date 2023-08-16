# awsS3-multipart-upload-script
## Upload multipart files to AWS S3 using the AWS s3api tool.

[The total volume of data and number of objects you can store in Amazon S3](https://aws.amazon.com/s3/faqs/) is unlimited. Individual Amazon S3 objects can range in size from a minimum of 0 bytes to a maximum of 5 TB. The largest object that can be uploaded in a single PUT is 5 GB. For objects larger than 100 MB, customers should consider using the multipart upload capability.

To test this, I've created a 100GB file in Linux, and timed each upload from different EC2 instances (in the same region as the S3 bucket) of type [r5n](https://aws.amazon.com/ec2/instance-types/r5) - which has 50Gbps of network bandwidth - and on average it took just under 6 minutes to upload a large 100GB file.

```
ec2-user@ip-172-31-36-108 ~]$ time aws s3 cp 100GBFile s3://mytestbucket
upload: ./100GBFile to s3://mytestbucket/100GBFile
 
real        5m44.163s
user       9m50.626s
sys          4m52.425s
 
 
[ec2-user@ip-172-31-40-61 ~]$ time aws s3 cp 100GBFile2 s3://mytestbucket
upload: ./100GBFile2 to s3://mytestbucket/100GBFile2
 
real        5m35.630s
user       9m38.756s
sys          4m42.815s

```

However, if we want to make uploads of large files (larger than 100MB each) to S3 faster, we can use [Multipart upload](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpuoverview.html). This is a also nice [overview](https://www.linkedin.com/pulse/aws-s3-multipart-upload-using-cli-ravindra-singh/). Multipart upload consists of these [steps](https://aws.amazon.com/blogs/compute/uploading-large-objects-to-amazon-s3-using-multipart-upload-and-transfer-acceleration/)

1.    Initiate the multipart upload and obtain an upload id via the CreateMultipartUpload API call.

2.    Divide the large object into multiple parts, get a presigned URL for each part, and upload the parts of a large object in parallel via the UploadPart API call.

3.    Complete the upload by calling the CompleteMultipartUpload API call.
 

When uploading a very large file to AWS S3 (> 100GB) from a server/instance/VM, you should split the file and then upload its parts in parallel using the [Multipart file Upload](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part.html) tool provided by AWS. That way, if you lose connection for a reason, you'll be able to resume the upload with no problems. Also, using the prefix `--content-md5`, you can check the content of the uploaded file and compare it with your local file.

### Steps to use this script

1. Create a large 100GB file in Linux, e.g `truncate --size 100G 100GBFile`
2. Split it into 100MB parts with `split -b 100M 100GBFile` - this will create lots of 100MB files each with names that begin with `x`
3. Set permissions: `chmod +x multipart-file-upload-s3.sh`
4. Create the `logs` directory: `cd awsS3-multipart-upload-script && mkdir logs`
5. Run: `time ./multipartupload.sh 100GBFile mybucket 10` - See **variables** below for more information.
   
The script will start reading your current directory for files with names that begin with `x`, will take the MD5 checksum of them and parse it to the S3 API as the `--content-md5` parameter, and then it will start uploading each file to the specified `bucket`.
It uploads parts/files in parallel, set by the value `N`. So if set to 10, it will upload 10 parts at a time. 
When completed it
The outputs will be sent to a log file.
Make sure to save that log file, you'll need the `ETag` output later on.

An example of the output of the script:

<code>{
    "ETag": "\"e868e0f4719e394144ef36531ee6824c\""
}</code>

The script will send the output to another file and format it to be compatible with the AWS requirements for the `complete-multipart-upload` command.

AWS `complete-multipart-upload` output example:

<code>{
  "Parts": [
    {
      "ETag": "e868e0f4719e394144ef36531ee6824c",
      "PartNumber": 1
    },
    {
      "ETag": "6bb2b12753d66fe86da4998aa33fffb0",
      "PartNumber": 2
    },
    {
      "ETag": "d0a0112e841abec9c9ec83406f0159c8",
      "PartNumber": 3
    }
  ]
}</code>

More information about the `split` command for Linux [here](https://www.linuxtechi.com/split-command-examples-for-linux-unix/).

### **Variables:**

`key` = Original large (un-splitted) object key for which the multipart upload has been initiated.

`bucket` = Your S3 bucket name.

`N` = number of parallel parts to uploads simultaneously

`upload_id` = retrievable when executing `create-multipart-upload`




