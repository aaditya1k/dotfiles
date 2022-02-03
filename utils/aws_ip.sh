#!/bin/zsh
source $HOME/.aws/aws_ip_groups

# ADD these VARS in $HOME/.aws/aws_ip_groups
## AWS_PROFILES=(profile1 profile2)
## AWS_PORTS=(22 21)
## typeset -A AWS_SG_IDS
## AWS_SG_IDS[0]="<security-group-id of profile1> <security-group-id of profile1>"
## AWS_SG_IDS[1]="<security-group-id of profile2>"

ip=$(curl --silent https://checkip.amazonaws.com)
old_ip=$(head -1 $HOME/.aws/aws_ips.txt)

if [[ "$ip" == "$old_ip" ]] ;then
    echo "IP is same. All good."
else
    echo "Updating security groups. New IP: $ip"

    profile_index=0
    for profile in ${AWS_PROFILES[@]}
    do
        echo "Running profile: $profile"
        for sg_id in $(echo "$AWS_SG_IDS[$profile_index]")
        do
            for port in ${AWS_PORTS[@]}
            do
                echo "Updating group $sg_id, port $port"

                echo "Revoking old ip"
                aws ec2 revoke-security-group-ingress \
                    --group-id "$sg_id" \
                    --protocol tcp \
                    --port "$port" \
                    --cidr "$old_ip/32" \
                    --output text \
                    --profile "$profile"

                echo "Adding new ip"
                aws ec2 authorize-security-group-ingress \
                    --group-id "$sg_id" \
                    --protocol tcp \
                    --port "$port" \
                    --cidr "$ip/32" \
                    --output yaml \
                    --profile "$profile"
            done
        done
        echo "\n\n"
        profile_index=$(expr $profile_index + 1)
    done
    echo "$ip" >> $HOME/.aws/aws_ips.txt
fi