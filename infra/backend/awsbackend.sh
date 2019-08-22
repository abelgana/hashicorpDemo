#! /bin/bash

source /Users/i870045/.secret/azure
source /Users/i870045/.secret/aws
source /Users/i870045/.secret/aectl
aws s3api create-bucket --bucket terraform-backend-store-test \\n    --region eu-west-1 \\n    --create-bucket-configuration \\n    LocationConstraint=eu-west-1
aws s3api put-bucket-encryption --bucket terraform-backend-store-test "--server-side-encryption-configuration={\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}"
aws iam create-user --user-name terraform-provisioner
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --user-name terraform-provisioner
cat <<-EOF >> {
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::283842097881:user/terraform-provisioner"
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::terraform-backend-store-test"
        }
    ]
}
EOF
aws s3api put-bucket-policy --bucket terraform-backend-store-test --policy file://policy.json
aws s3api put-bucket-versioning --bucket terraform-backend-store-test --versioning-configuration Status=Enabled
