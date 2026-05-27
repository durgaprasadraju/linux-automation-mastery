import boto3

def find_ebs_waste():
    ec2 = boto3.client('ec2', region_name='us-west-2')
    volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])
    
    total_waste_size = 0
    print("--- FinOps Audit: Unattached EBS Volumes ---")
    
    for vol in volumes['Volumes']:
        v_id = vol['VolumeId']
        v_size = vol['Size']
        print(f"WASTE FOUND: Volume {v_id} is idle. Size: {v_size}GB")
        total_waste_size += v_size
    
    print(f"-------------------------------------------")
    print(f"Total Potential Savings: {total_waste_size}GB of storage.")

if __name__ == "__main__":
    find_ebs_waste()