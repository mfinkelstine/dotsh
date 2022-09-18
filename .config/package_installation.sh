1.  https://globaldatanet.com/tech-blog/terraform-helpers-we-love-at-globaldatanet
    - https://github.com/terraform-linters/tflint
    terraform-docs markdown . --output-file README.md
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
2.  https://github.com/terraform-docs/terraform-docs/
    - https://terraform-docs.io/
    curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
    tar -xzf terraform-docs.tar.gz
    chmod +x terraform-docs
    mv terraform-docs /usr/local/terraform-docs

3.  https://aquasecurity.github.io/tfsec/v1.26.0/
