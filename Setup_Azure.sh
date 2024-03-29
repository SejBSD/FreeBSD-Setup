#!/bin/sh

sh ./Internal_Update.sh

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Setting up Azure...                    ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

echo ""
read -p " ## Install VSCode with extensions? (yes/empty) " _installVscode;

if [ "$_installVscode" != "" ]
then
    sudo pkg install -y vscode

    sh ./Internal_Common_VSCode_Azure.sh
fi
