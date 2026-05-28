import boto3
from botocore.exceptions import ClientError
import time

REGION = "us-east-1"

ROLE_NAME = "go-web-role"
INSTANCE_PROFILE = "go-web-profile"
SECURITY_GROUP_NAME = "go-web-sg"

ec2 = boto3.client("ec2", region_name=REGION)
iam = boto3.client("iam")


# -----------------------------------------
# TERMINATE EC2 INSTANCES USING SECURITY GROUP
# -----------------------------------------
def terminate_ec2_instances():
    print("Finding EC2 instances...")

    response = ec2.describe_instances(
        Filters=[
            {
                "Name": "instance-state-name",
                "Values": ["pending", "running", "stopping", "stopped"]
            }
        ]
    )

    instance_ids = []

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:

            groups = instance.get("SecurityGroups", [])

            for group in groups:
                if SECURITY_GROUP_NAME == group["GroupName"]:
                    instance_ids.append(instance["InstanceId"])

    if not instance_ids:
        print("No EC2 instances found.")
        return

    print("Terminating instances:", instance_ids)

    ec2.terminate_instances(
        InstanceIds=instance_ids
    )

    waiter = ec2.get_waiter("instance_terminated")

    print("Waiting for instances to terminate...")

    waiter.wait(
        InstanceIds=instance_ids
    )

    print("Instances terminated.")


# -----------------------------------------
# DELETE INSTANCE PROFILE
# -----------------------------------------
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


# -----------------------------------------
# DELETE INLINE POLICIES
# -----------------------------------------
def delete_inline_policies():
    try:
        response = iam.list_role_policies(
            RoleName=ROLE_NAME
        )

        policies = response["PolicyNames"]

        for policy in policies:
            print(f"Deleting inline policy: {policy}")

            iam.delete_role_policy(
                RoleName=ROLE_NAME,
                PolicyName=policy
            )

    except ClientError as e:
        print(e)


# -----------------------------------------
# DETACH MANAGED POLICIES
# -----------------------------------------
def detach_managed_policies():
    try:
        response = iam.list_attached_role_policies(
            RoleName=ROLE_NAME
        )

        policies = response["AttachedPolicies"]

        for policy in policies:
            print(f"Detaching managed policy: {policy['PolicyName']}")

            iam.detach_role_policy(
                RoleName=ROLE_NAME,
                PolicyArn=policy["PolicyArn"]
            )

    except ClientError as e:
        print(e)


# -----------------------------------------
# DELETE IAM ROLE
# -----------------------------------------
def delete_role():
    try:
        print(f"Deleting IAM role: {ROLE_NAME}")

        iam.delete_role(
            RoleName=ROLE_NAME
        )

    except ClientError as e:
        print(e)


# -----------------------------------------
# DELETE SECURITY GROUP
# -----------------------------------------
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

        if not groups:
            print("Security group not found.")
            return

        for sg in groups:
            sg_id = sg["GroupId"]

            print(f"Deleting Security Group: {sg_id}")

            try:
                ec2.delete_security_group(
                    GroupId=sg_id
                )

                print("Security group deleted.")

            except ClientError as e:
                print(e)

    except ClientError as e:
        print(e)


# -----------------------------------------
# MAIN
# -----------------------------------------
if __name__ == "__main__":

    terminate_ec2_instances()

    delete_instance_profile()

    delete_inline_policies()

    detach_managed_policies()

    delete_role()

    delete_security_group()

    print("Cleanup completed.")

