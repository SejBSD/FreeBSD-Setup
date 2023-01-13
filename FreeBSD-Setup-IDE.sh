echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Update packages...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

sudo pkg update && sudo pkg upgrade

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##            Setting up Development Environment...           ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

_etcFsbatFilePath=/etc/fstab

read -p "Choose language (java): " _language;

if [ "$_language" = "java" ]
then
    sudo pkg install openjdk8 openjdk11 openjdk17 openjdk18 openjdk19 maven gradle

    read -p "OpenJDK implementation requires fdescfs(5) mounted on /dev/fd. Mount? (yes/no) " _mountFdescfs;

    if [ "$_mountFdescfs" = "yes" ]
    then
        echo "fdesc /dev/fd fdescfs rw 0 0" | sudo tee -a $_etcFsbatFilePath
    else fi

    read -p "OpenJDK implementation requires procfs(5) mounted on /proc. Mount? (yes/no) " _mountProcfs;

    if [ "$_mountProcfs" = "yes" ]
    then
        echo "proc /proc procfs rw 0 0" | sudo tee -a $_etcFsbatFilePath
    else fi

    read -p "Choose IDE (intellij, eclipse, netbeans): " _ide;

    if [ "$_ide" != "" ]
    then
        sudo pkg install $_ide
    else fi
else fi