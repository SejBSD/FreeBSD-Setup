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
sudo pkg install bastille

echo ""
echo "## Installing buildah... ##"
sudo pkg install buildah

echo ""
echo "## Installing kubectl... ##"
sudo pkg install kubectl

echo ""
echo "## Installing helm... ##"
sudo pkg install helm

echo ""
echo "## Installing containerd..."
sudo pkg install containerd

echo ""
echo "## Installing podman..."
sudo pkg install podman

echo ""
echo "## Installing minikube..."
sudo pkg install minikube

echo ""
echo "## Installing vm-bhyve..."
sudo pkg install vm-bhyve

echo ""
read -p "## Install VSCode? (yes/no) " _installVscode;

if [ "$_installVscode" = "yes" ]
then
    sudo pkg install vscode

    echo ""
    read -p "## Install extensions? (yes/no) " _installVscodeExtensions;

    if [ "$_installVscodeExtensions" = "yes" ]
    then
        sh ./Internal_Common_VSCode_Extensions.sh

        vscode --install-extension ms-kubernetes-tools.vscode-kubernetes-tools  # https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools
    fi
fi
