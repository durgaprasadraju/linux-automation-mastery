import boto3
from botocore.exceptions import ClientError

def onboard_user(username):
    iam = boto3.client('iam')
    s3 = boto3.client('s3')

    try:
        # 1. Create IAM User
        print(f"Creating user: {username}...")
        iam.create_user(UserName=username)

        # 2. Create a dedicated S3 Bucket for the user's logs
        bucket_name = f"user-logs-{username}"
        print(f"Creating bucket: {bucket_name}...")
        s3.create_bucket(Bucket=bucket_name)

        print(f"Successfully onboarded {username}")

    except ClientError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    new_user = input("Enter username to onboard: ")
    onboard_user(new_user)