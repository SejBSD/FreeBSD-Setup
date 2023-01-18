#!/bin/sh

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Update packages...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

sudo pkg update && sudo pkg upgrade -y
