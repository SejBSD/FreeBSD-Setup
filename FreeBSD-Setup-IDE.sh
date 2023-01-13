echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Update packages...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

pkg update && pkg upgrade

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##            Setting up Development Environment...           ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Choose language (java): " _language;

if [ "$_language" = "java" ]
then
    pkg install openjdk8 openjdk11 openjdk17 openjdk18 openjdk19 maven gradle

    read -p "Choose IDE (intellij, eclipse, netbeans): " _ide;

    if [ "$_ide" != "" ]
    then
        pkg install _ide
    else fi
else fi