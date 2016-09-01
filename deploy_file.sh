
if [ "$Environment" = 'beta' ]; then
#!/bin/bash
export AWS_DEFAULT_REGION="us-east-1"
export APP_NAME="ws_test"
export ENV_NAME="wstest-beta-new"
export S3_BUCKET="kingandpartners-eb-builds"
export APP_VERSION=`git rev-parse --short HEAD`
git clean -fd
zip -x *.git* -r "${APP_NAME}-${APP_VERSION}.zip" .
aws elasticbeanstalk delete-application-version --application-name "${APP_NAME}" --version-label "${APP_VERSION}"  --delete-source-bundle
aws s3 cp ${APP_NAME}-${APP_VERSION}.zip s3://${S3_BUCKET}/${APP_NAME}-${APP_VERSION}.zip
aws elasticbeanstalk create-application-version --application-name "${APP_NAME}" --version-label "${APP_VERSION}" --source-bundle S3Bucket="${S3_BUCKET}",S3Key="${APP_NAME}-${APP_VERSION}.zip"
aws elasticbeanstalk update-environment --environment-name "${ENV_NAME}" --version-label "${APP_VERSION}"

start_time=$(aws elasticbeanstalk describe-environments --environment-name "${ENV_NAME}" --region "${AWS_DEFAULT_REGION}" --query Environments[*].[DateUpdated] --output text)
count=1

echo "Deployment STATUS :: "

while [[ $count -le 5 ]]
do
status=$(aws elasticbeanstalk describe-events  --environment-name "${ENV_NAME}" --start-time "${start_time}" --query Events[*].[Severity,Message] --region "${AWS_DEFAULT_REGION}" --output text)

if [ ! -z "$status" -a "$status" != " " ]
then
    if  [[ "$status" = *"ERROR"* ]] && ( [[ "$status" = *"Update environment operation is complete, but with errors"* ]] || [[ "$status" = *"Failed"* ]] || [[ "$status" = *"Environment update completed successfully"* ]] )
    then
         echo "$status"
         echo "Deployment Failed, Please check the logs for more information"
         exit 1; 
    elif [[ "$status" = *"INFO"* ]] && [[ "$status" = *"Environment update completed successfully"* ]] && [[ "$status" != *"Failed"*  ]]
    then
         echo "$status"
         echo "Deployment is SUCCESS"
         exit 0;  
    else
        if  [[ "$status" = *"INFO"* ]]
        then
          echo "$status"
          sleep 40s
        else
          if [[ "$status" = *"ERROR"* ]]
          then
             echo "$status"
             sleep 40s
          fi
       fi
    fi
    count=$((count+1))
    echo "Deployment in Progress......"
    sleep 1m 
      
else
count=$((count+1))
echo "Deployment in Progress......"
sleep 1m
fi
done


elif [ "$Environment" = 'prod' ]; then
export AWS_DEFAULT_REGION="us-east-1"
export APP_NAME="ws_test"
export ENV_NAME="wstest-prod"
export S3_BUCKET="kingandpartners-eb-builds"
export APP_VERSION=`git rev-parse --short HEAD`
git clean -fd
zip -x *.git* -r "${APP_NAME}-${APP_VERSION}.zip" .
aws elasticbeanstalk delete-application-version --application-name "${APP_NAME}" --version-label "${APP_VERSION}"  --delete-source-bundle
aws s3 cp ${APP_NAME}-${APP_VERSION}.zip s3://${S3_BUCKET}/${APP_NAME}-${APP_VERSION}.zip
aws elasticbeanstalk create-application-version --application-name "${APP_NAME}" --version-label "${APP_VERSION}" --source-bundle S3Bucket="${S3_BUCKET}",S3Key="${APP_NAME}-${APP_VERSION}.zip"
aws elasticbeanstalk update-environment --environment-name "${ENV_NAME}" --version-label "${APP_VERSION}"
start_time=$(aws elasticbeanstalk describe-environments --environment-name "${ENV_NAME}" --region "${AWS_DEFAULT_REGION}" --query Environments[*].[DateUpdated] --output text)
count=1

echo "Deployment STATUS :: "

while [[ $count -le 5 ]]
do
status=$(aws elasticbeanstalk describe-events  --environment-name "${ENV_NAME}" --start-time "${start_time}" --query Events[*].[Severity,Message] --region "${AWS_DEFAULT_REGION}" --output text)

if [ ! -z "$status" -a "$status" != " " ]
then
    if  [[ "$status" = *"ERROR"* ]] && ( [[ "$status" = *"Update environment operation is complete, but with errors"* ]] || [[ "$status" = *"Failed"* ]] || [[ "$status" = *"Environment update completed successfully"* ]] )
    then
         echo "$status"
         echo "Deployment Failed, Please check the logs for more information"
         exit 1; 
    elif [[ "$status" = *"INFO"* ]] && [[ "$status" = *"Environment update completed successfully"* ]] && [[ "$status" != *"Failed"*  ]]
    then
         echo "$status"
         echo "Deployment is SUCCESS"
         exit 0;  
    else
        if  [[ "$status" = *"INFO"* ]]
        then
          echo "$status"
          sleep 40s
        else
          if [[ "$status" = *"ERROR"* ]]
          then
             echo "$status"
             sleep 40s
          fi
       fi
    fi
    count=$((count+1))
    echo "Deployment in Progress......"
    sleep 1m 
      
else
count=$((count+1))
echo "Deployment in Progress......"
sleep 1m
fi
done
else 
exit 0;

fi
