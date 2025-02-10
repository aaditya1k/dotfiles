#!/bin/zsh
source $HOME/.aws/aws_ip_config

source $AWS_IP_FOLDER/aws_ip_groups
AWS_IP_FILE=$AWS_IP_FOLDER/aws_ips

if [ -z $1 ]; then
    echo "Missing IP.\nExample:"
    echo "./aws_remove_ip.sh 127.0.0.1"
    exit 1
fi

old_ip=$1
sleep_time=7

echo "IP: $old_ip"
echo "Will start deleting IP from security groups in $sleep_time seconds.."
sleep $sleep_time
echo "Starting.."

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
        for port in ${AWS_PORTS[@]}
        do
            delete_execute="${delete_execute} IpProtocol=tcp,FromPort="${port}",ToPort="${port}",IpRanges=\"[{CidrIp="${old_ip}/32"}]\""
        done
        delete_execute="${delete_execute} --profile ${profile}"

        echo "Revoking old ip for sg:$sg_id | ${security_group_index}/${#security_groups[@]}"
        eval ${delete_execute}

        security_group_index=$(expr $security_group_index + 1)
    done
    echo "\n"
    profile_index=$(expr $profile_index + 1)
done
