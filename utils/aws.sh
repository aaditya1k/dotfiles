aws_instances() {
  readonly profile=${1:?"The profile must be specified."}

  aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].[PublicIpAddress, Tags[?Key=='Name'].Value|[0]]" \
    --output text \
    --profile "$profile"
}