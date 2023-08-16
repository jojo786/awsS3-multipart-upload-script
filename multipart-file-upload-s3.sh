#!/bin/bash
#
#

N=10

key=$1
bucket=adaptittest1
echo "Creating multipart upload_id: "

upload_id=`aws s3api create-multipart-upload --bucket ${bucket} --key $key | jq -r '.UploadId'`
echo $upload_id

echo "uploading parts concurrently in batches of N=" $10

part_number=0

#list files in the current directory that begin with x
for f in `ls x*`
do
  ((part_number = part_number + 1))
  echo "upload part " $part_number
  md5=$(openssl md5 -binary "${f}" | base64)
  aws s3api upload-part --bucket ${bucket} --key $key --part-number $part_number --body "${f}" --upload-id ${upload_id} --content-md5 "${md5}" | tee -a logs/upload-part.$part_number-s3.log
  if [[ $(jobs -r -p | wc -l) -ge $N ]]; then wait -n; fi
done


echo "completing multipart upload"
aws s3api complete-multipart-upload --multipart-upload file://upload-part-all.json --bucket ${bucket} --key ${key} --upload-id ${upload_id}

echo "DONE"
