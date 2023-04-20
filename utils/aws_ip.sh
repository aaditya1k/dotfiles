#!/bin/zsh
source $HOME/.aws/aws_ip_groups

# ADD these VARS in $HOME/.aws/aws_ip_groups
## AWS_DESCRIPTION="Aaditya"
## AWS_IP_FILE="<absolute path of ips file>"
## AWS_PROFILES=(profile0 profile1 profile2)
## AWS_PORTS=(22 21)
## declare -A AWS_SG_IDS
## AWS_SG_IDS[0]="<security-group-id of profile0> <security-group-id of profile0>"
## AWS_SG_IDS[0]="<security-group-id of profile1>"

if [ ! -f "$AWS_IP_FILE" ]; then
    echo "${AWS_IP_FILE} doesn't exists."
    exit 1
fi

ip=$(curl --silent https://checkip.amazonaws.com)
old_ip=$(tail -1 ${AWS_IP_FILE})

if [[ "$ip" == "$old_ip" ]] ;then
    echo "IP is same ${old_ip}. All good."
else
    echo "Updating security groups. New IP: $ip\n"

#     profile_index=0
#     for profile in ${AWS_PROFILES[@]}
#     do
#         echo "\n\nRunning profile: $profile"
#         for sg_id in $(echo "$AWS_SG_IDS[$profile_index]")
#         do
#             delete_execute="aws ec2 revoke-security-group-ingress \
# --group-id ${sg_id} \
# --ip-permissions "
#             add_execute="aws ec2 authorize-security-group-ingress \
# --group-id ${sg_id} \
# --ip-permissions "
#             for port in ${AWS_PORTS[@]}
#             do
#                 delete_execute="${delete_execute} IpProtocol=tcp,FromPort="${port}",ToPort="${port}",IpRanges=\"[{CidrIp="${old_ip}/32"}]\""
#                 add_execute="${add_execute} IpProtocol=tcp,FromPort="${port}",ToPort="${port}",IpRanges=\"[{CidrIp="${ip}/32",Description='${AWS_DESCRIPTION}'}]\""

#                 #echo "\nUpdating group $sg_id, port $port"
#                 # aws ec2 revoke-security-group-ingress \
#                 #     --group-id "$sg_id" \
#                 #     --protocol tcp \
#                 #     --port "$port" \
#                 #     --cidr "$old_ip/32" \
#                 #     --output text \
#                 #     --profile "$profile"

#                 #echo "Adding new ip sg:$sg_id, port: $port, ip:$ip/32, profile:$profile"
#                 #aws ec2 authorize-security-group-ingress \
#                 #    --group-id "$sg_id" \
#                 #    --protocol tcp \
#                 #    --port "$port" \
#                 #    --cidr "$ip/32" \
#                 #    --output yaml \
#                 #    --profile "$profile"
#             done
#             delete_execute="${delete_execute} --profile ${profile}"
#             add_execute="${add_execute} --profile ${profile}"

#             echo "Revoking old ip: sg:$sg_id, ip:$old_ip/32, profile:$profile"
#             eval ${delete_execute}
#             echo "Adding new ip sg:$sg_id, ip:$ip/32, profile:$profile"
#             eval ${add_execute}
#         done
#         echo "\n"
#         profile_index=$(expr $profile_index + 1)
#     done
#     echo "$ip" >> ${AWS_IP_FILE}
fi