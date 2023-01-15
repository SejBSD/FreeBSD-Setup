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
read -p " ## Install VSCode with extensions? (yes/no) " _installVscode;

if [ "$_installVscode" = "yes" ]
then
    sudo pkg install vscode

    sh ./Internal_Common_VSCode_Azure.sh
fi
