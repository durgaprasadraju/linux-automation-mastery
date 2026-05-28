import boto3
from botocore.exceptions import ClientError
import time

REGION = "us-east-1"

ROLE_NAME = "go-web-role"
INSTANCE_PROFILE = "go-web-profile"
SECURITY_GROUP_NAME = "go-web-sg"

ec2 = boto3.client("ec2", region_name=REGION)
iam = boto3.client("iam")


def terminate_ec2_instances():
    print("Finding EC2 instances...")

    reservations = ec2.describe_instances()["Reservations"]

    for reservation in reservations:
        for instance in reservation["Instances"]:
            instance_id = instance["InstanceId"]
            state = instance["State"]["Name"]

            if state != "terminated":
                print(f"Terminating instance: {instance_id}")

                ec2.terminate_instances(
                    InstanceIds=[instance_id]
                )

    print("Waiting for instances to terminate...")
    time.sleep(30)


def delete_instance_profile():
    try:
        print(f"Removing role from instance profile: {INSTANCE_PROFILE}")

        iam.remove_role_from_instance_profile(
            InstanceProfileName=INSTANCE_PROFILE,
            RoleName=ROLE_NAME
        )

    except ClientError as e:
        print(e)

    try:
        print(f"Deleting instance profile: {INSTANCE_PROFILE}")

        iam.delete_instance_profile(
            InstanceProfileName=INSTANCE_PROFILE
        )

    except ClientError as e:
        print(e)


def delete_inline_policies():
    try:
        policies = iam.list_role_policies(
            RoleName=ROLE_NAME
        )["PolicyNames"]

        for policy in policies:
            print(f"Deleting inline policy: {policy}")

            iam.delete_role_policy(
                RoleName=ROLE_NAME,
                PolicyName=policy
            )

    except ClientError as e:
        print(e)


def delete_role():
    try:
        print(f"Deleting IAM role: {ROLE_NAME}")

        iam.delete_role(
            RoleName=ROLE_NAME
        )

    except ClientError as e:
        print(e)


def delete_security_group():
    try:
        response = ec2.describe_security_groups(
            Filters=[
                {
                    "Name": "group-name",
                    "Values": [SECURITY_GROUP_NAME]
                }
            ]
        )

        groups = response["SecurityGroups"]

        for sg in groups:
            sg_id = sg["GroupId"]

            print(f"Deleting Security Group: {sg_id}")

            ec2.delete_security_group(
                GroupId=sg_id
            )

    except ClientError as e:
        print(e)


if __name__ == "__main__":
    terminate_ec2_instances()
    delete_instance_profile()
    delete_inline_policies()
    delete_role()
    delete_security_group()

    print("Cleanup completed.")

