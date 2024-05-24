#!/bin/bash

# Check if the script has execute permission
if [ ! -x "$0" ]; then
    echo "Error: Script does not have execute permission. (Pls execute: chmod +x script.sh)"
    exit 1
fi

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root" 
    exit 1
fi

# Function to exit the script
exit_script() {
    echo "Forcefully exiting from the installation."
    exit 0
}

# Function to log installation details
log_installation_details() {
    echo "======= Installation Details =======" > script_log.txt
    echo "Date: $(date)" >> script_log.txt
    echo >> script_log.txt
}

# Function to check system information
check_system_info() {
    echo "======== System Information ========"
    DISTRO=$(lsb_release -is)
    VERSION=$(lsb_release -rs)
    OSARCH=$(uname -m)
    DISTROARCH=$(dpkg --print-architecture)
    TIME=$(date)
    USERNAME=$(echo $USER)

    echo "Distribution: $DISTRO"
    echo "Version: $VERSION"
    echo "OS Arch: $OSARCH"
    echo "Distro Arch: $DISTROARCH"
    echo "Script initiated at: $TIME"
    echo "Script initiated by: $USERNAME"
    echo
}

# Function to install required dependency packages
install_dependencies() {
    echo "======= Installing Required Dependency Packages ======="
    apt-get update
    apt-get install -y curl wget net-tools openssh-server unzip
    echo
}

# Function to display software options
display_software_options() {
    echo "======= All softwares available for installation! ======="
    echo "1. Docker"
    echo "2. Helm"
    echo "3. AWS CLI"
    echo "4. Azure CLI"
    echo "5. Git"
    echo "6. Python"
    echo "7. Java 21"
    echo "8. Node.js LTS"
    echo "9. K9s"
    echo "10. Wireshark (latest)"
    echo "11. Go Lang"
    echo "12. 7-Zip (latest)"
    echo "0. Exit"
    echo
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
}

# Function to get the location of package binaries
get_package_location() {
    which "$1" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Binary Location: $(which $1)"
    else
        echo "Binary Location: Not found"
    fi
}

# Function to install Docker
install_docker() {
    echo "=== Installing Docker ==="
    if is_package_installed docker-ce; then
        echo "Docker is already installed. Skipping..."
        return
    fi

    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$DISTROARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Log installation details
    echo "Docker installed version: $(docker --version)" >> script_log.txt
    echo "Docker daemon service status:" >> script_log.txt
    systemctl status docker >> script_log.txt
    get_package_location docker >> script_log.txt
    echo
}

# Function to install Helm
install_helm() {
    echo "=== Installing Helm ==="
    if is_package_installed helm; then
        echo "Helm is already installed. Skipping..."
        return
    fi

    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    apt-get update
    apt-get install -y helm

    # Log installation details
    echo "Helm installed version: $(helm version)" >> script_log.txt
    get_package_location helm >> script_log.txt
    echo
}

# Function to install AWS CLI
install_aws_cli() {
    echo "=== Installing AWS CLI ==="
    if is_package_installed aws-cli; then
        echo "AWS CLI is already installed. Skipping..."
        return
    fi

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm awscliv2.zip
    rm -rf aws

    # Log installation details
    echo "AWS CLI installed version: $(aws --version)" >> script_log.txt
    get_package_location aws >> script_log.txt
    echo
}

# Function to install Azure CLI
install_azure_cli() {
    echo "=== Installing Azure CLI ==="
    if is_package_installed azure-cli; then
        echo "Azure CLI is already installed. Skipping..."
        return
    fi

    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    # Log installation details
    echo "Azure CLI installed version: $(az --version)" >> script_log.txt
    get_package_location az >> script_log.txt
    echo
}

# Function to install Git
install_git() {
    echo "=== Installing Git ==="
    if is_package_installed git; then
        echo "Git is already installed. Skipping..."
        return
    fi

    apt-get install -y git

    # Log installation details
    echo "Git installed version: $(git --version)" >> script_log.txt
    get_package_location git >> script_log.txt
    echo
}

# Function to install Python
install_python() {
    echo "=== Installing Python ==="
    if is_package_installed python3; then
        echo "Python is already installed. Skipping..."
        return
    fi

    apt-get install -y python3

    # Log installation details
    echo "Python installed version: $(python3 --version)" >> script_log.txt
    get_package_location python3 >> script_log.txt
    echo
}

# Function to install Java 21
install_java_21() {
    echo "=== Installing Java 17 ==="
    if is_package_installed openjdk-17-jdk; then
        echo "Java is already installed. Skipping..."
        return
    fi

    apt-get install -y openjdk-17-jdk

    # Set Java environment variables
    echo "export JAVA_HOME=/usr/lib/jvm/java-16-openjdk-$DISTROARCH" >> ~/.bashrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    # Log installation details
    echo "Java installed version: $(java --version)" >> script_log.txt
    get_package_location java >> script_log.txt
    echo
}

# Function to install Node.js LTS
install_nodejs_lts() {
    echo "=== Installing Node.js LTS ==="
    if is_package_installed nodejs; then
        echo "Node.js LTS is already installed. Skipping..."
        return
    fi

    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    apt-get install -y nodejs

    # Log installation details
    echo "Node.js LTS installed version: $(node --version)" >> script_log.txt
    get_package_location node >> script_log.txt
    echo
}

# Function to install K9s
install_k9s() {
    echo "=== Installing K9s ==="
    if is_package_installed k9s; then
        echo "K9s is already installed. Skipping..."
        return
    fi

    curl -sS https://webi.sh/k9s | sh
    source ~/.config/envman/PATH.env

    # Log installation details
    echo "K9s installed version: $(k9s version)" >> script_log.txt
    get_package_location k9s >> script_log.txt
    echo
}

# Function to install Wireshark
install_wireshark() {
    echo "=== Installing Wireshark ==="
    if is_package_installed wireshark; then
        echo "Wireshark is already installed. Skipping..."
        return
    fi

    apt-get install -y wireshark

    # Log installation details
    echo "Wireshark installed version: $(wireshark --version)" >> script_log.txt
    get_package_location wireshark >> script_log.txt
    echo
}

# Function to install Go Lang
install_go_lang() {
    echo "=== Installing Go Lang ==="
    if is_package_installed golang-go; then
        echo "Go Lang is already installed. Skipping..."
        return
    fi

    apt-get install -y golang-go

    # Log installation details
    echo "Go Lang installed version: $(go version)" >> script_log.txt
    get_package_location go >> script_log.txt
    echo
}

# Function to install 7-Zip
install_7zip() {
    echo "=== Installing 7-Zip ==="
    if is_package_installed p7zip-full; then
        echo "7-Zip is already installed. Skipping..."
        return
    fi

    apt-get install -y p7zip-full

    # Log installation details
    echo "7-Zip installed version: $(7z --help)" >> script_log.txt
    get_package_location 7z >> script_log.txt
    echo
}

# Function to process the user's choices
install_selected_software() {
    for choice in "${choices[@]}"
    do
        case $choice in
            0)
                exit_script
                ;;
            1)
                install_docker
                ;;
            2)
                install_helm
                ;;
            3)
                install_aws_cli
                ;;
            4)
                install_azure_cli
                ;;
            5)
                install_git
                ;;
            6)
                install_python
                ;;
            7)
                install_java_21
                ;;
            8)
                install_nodejs_lts
                ;;
            9)
                install_k9s
                ;;
            10)
                install_wireshark
                ;;
            11)
                install_go_lang
                ;;
            12)
                install_7zip
                ;;
            *)
                echo "Invalid choice: $choice"
                ;;
        esac
    done
}

# Main script execution
log_installation_details
check_system_info
display_software_options

echo "================================================================"
echo "Mention the software number that you wanna install,(e.g., 1 3 5):"
echo "================================================================"
read -a choices

install_selected_software

# Install dependencies after software installation
install_dependencies

echo "================================================================"
echo "Installation completed. Details logged in script_log.txt"
echo "================================================================"
