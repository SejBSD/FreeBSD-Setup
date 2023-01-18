#!/bin/sh

sh ./Internal_Update.sh

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Setting up Games...                    ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

echo ""
echo "## Installing minetest..."
sudo pkg install -y minetest

echo ""
echo "## Installing wine..."
sudo pkg install -y wine wine-gecko wine-mono

echo ""
read -p "Setup wine mesa drivers? (yes/no) " _setupWineMesa;

if [ "$_setupWineMesa" = "yes" ]
then
    /usr/local/share/wine/pkg32.sh install wine mesa-dri
fi

echo ""
echo "## Installing wine-proton..."
sudo pkg install -y wine-proton

echo ""
echo "## Installing winetricks..."
sudo pkg install -y winetricks
