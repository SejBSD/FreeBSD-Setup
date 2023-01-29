#!/bin/sh

sh ./Internal_Update.sh

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                  Setting up Containers...                  ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

echo ""
echo "## Installing bastille... ##"
sudo pkg install -y bastille

echo ""
echo "## Installing buildah... ##"
sudo pkg install -y buildah

echo ""
echo "## Installing kubectl... ##"
sudo pkg install -y kubectl

echo ""
echo "## Installing helm... ##"
sudo pkg install -y helm

echo ""
echo "## Installing containerd..."
sudo pkg install -y containerd

echo ""
echo "## Installing podman..."
sudo pkg install -y podman

echo ""
echo "## Installing minikube..."
sudo pkg install -y minikube

echo ""
echo "## Installing vm-bhyve..."
sudo pkg install -y vm-bhyve

echo ""
read -p "## Install VSCode? (yes/empty) " _installVscode;

if [ "$_installVscode" != "" ]
then
    sudo pkg install -y vscode

    echo ""
    read -p "## Install extensions? (yes/empty) " _installVscodeExtensions;

    if [ "$_installVscodeExtensions" != "" ]
    then
        sh ./Internal_Common_VSCode_Extensions.sh

        vscode --install-extension ms-kubernetes-tools.vscode-kubernetes-tools  # https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools
    fi
fi
