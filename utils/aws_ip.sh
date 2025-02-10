#!/bin/zsh

# -- Add these vars in $HOME/.aws/aws_ip_config
# AWS_IP_FOLDER="/configs/aws"
#
# -- Add these vars in config: /configs/aws/aws_ip_groups
# AWS_DESCRIPTION="Aaditya_auto"
# AWS_PROFILES=(profile0 profile1 profile2)
# AWS_PORTS=(22 21)
# declare -A AWS_SG_IDS
# AWS_SG_IDS[0]="<security-group-id of profile0> <security-group-id of profile0>"
# AWS_SG_IDS[0]="<security-group-id of profile1>"
#
# -- Create empty /configs/aws/aws_ips

source $HOME/.aws/aws_ip_config

source $AWS_IP_FOLDER/aws_ip_groups
AWS_IP_FILE=$AWS_IP_FOLDER/aws_ips

if [ ! -f "$AWS_IP_FILE" ]; then
    echo "${AWS_IP_FILE} doesn't exists."
    exit 1
fi

ip=$(curl --silent https://checkip.amazonaws.com)
old_ip=$(tail -1 ${AWS_IP_FILE})

if [[ "$ip" == "" ]]; then
    echo "Unable to fetch new ip"
    exit 1
fi
if [[ "$ip" == "$old_ip" ]]; then
    echo "IP is same ${old_ip}. All good."
    exit 1
fi

echo "Updating security groups"
echo "New ip: $ip"
echo "Old ip: $old_ip"

profile_index=0
for profile in ${AWS_PROFILES[@]}
do
    echo "\n\n$(expr $profile_index + 1)/${#AWS_PROFILES[@]} Running profile: $profile"
    security_group_index=1
    security_groups=($(echo "$AWS_SG_IDS[$profile_index]"))
    for sg_id in $security_groups
    do
        delete_execute="aws ec2 revoke-security-group-ingress \
            --group-id ${sg_id} \
            --ip-permissions "
        add_execute="aws ec2 authorize-security-group-ingress \
            --group-id ${sg_id} \
            --ip-permissions "
        for port in ${AWS_PORTS[@]}
        do
            delete_execute="${delete_execute} IpProtocol=tcp,FromPort="${port}",ToPort="${port}",IpRanges=\"[{CidrIp="${old_ip}/32"}]\""
            add_execute="${add_execute} IpProtocol=tcp,FromPort="${port}",ToPort="${port}",IpRanges=\"[{CidrIp="${ip}/32",Description='${AWS_DESCRIPTION}'}]\""

            #echo "\nUpdating group $sg_id, port $port"
            # aws ec2 revoke-security-group-ingress \
            #     --group-id "$sg_id" \
            #     --protocol tcp \
            #     --port "$port" \
            #     --cidr "$old_ip/32" \
            #     --output text \
            #     --profile "$profile"

            #echo "Adding new ip sg:$sg_id, port: $port, ip:$ip/32, profile:$profile"
            #aws ec2 authorize-security-group-ingress \
            #    --group-id "$sg_id" \
            #    --protocol tcp \
            #    --port "$port" \
            #    --cidr "$ip/32" \
            #    --output yaml \
            #    --profile "$profile"
        done
        delete_execute="${delete_execute} --profile ${profile}"
        add_execute="${add_execute} --profile ${profile} --output yaml"

        echo "Revoking old ip for sg:$sg_id | ${security_group_index}/${#security_groups[@]}"
        eval ${delete_execute}

        echo "Adding new ip for sg:$sg_id | ${security_group_index}/${#security_groups[@]}"
        eval ${add_execute}
        security_group_index=$(expr $security_group_index + 1)
    done
    echo "\n"
    profile_index=$(expr $profile_index + 1)
done
echo "$ip" >> ${AWS_IP_FILE}
