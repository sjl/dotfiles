function sssh {
    ssh -i ~/.ec2/id_rsa-gsg-keypair ubuntu@$1
}
