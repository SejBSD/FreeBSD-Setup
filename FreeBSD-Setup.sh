##############################################################################
##  Source: https://github.com/Sejoslaw/FreeBSD-Setup
##
##
##  FreeBSD Configuration Script by Krzysztof "Sejoslaw" Dobrzynski
##
##
##  Current script will allows you to setup: 
##      - basic graphical environment (GNOME, KDE, XFCE) - core or full
##      - common services
##      - core tools (console + graphical)
##      - optional tools (music, video, web browser, etc.)
##############################################################################

# Core / Static variables

_sudoersFilePath=/usr/local/etc/sudoers
_bootloaderConfFilePath=/boot/loader.conf
_etcRcConfFilePath=/etc/rc.conf
_videoDriverFileDir=/usr/local/etc/X11/xorg.conf.d/
_etcFsbatFilePath=/etc/fstab

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##              Welcome to FreeBSD-Setup Script               ##"
echo "##                                                            ##"
echo "##  During setup you will be promped for some user-specific   ##"
echo "##  configuration to make the system most optimized for you.  ##"
echo "##  Make sure the script is run directly after a fresh        ##"
echo "##  installation of FreeBSD.                                  ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

sleep 7

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                       Updating OS...                       ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

freebsd-update fetch && freebsd-update install

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                      Setting up pkg...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

pkg update && pkg upgrade -y

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Setting up sudo...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

pkg install sudo -y

echo "" >> $_sudoersFilePath
echo "# Added by FreeBSD-Setup script (\"Setting up sudo...\" phase)" >> $_sudoersFilePath

echo "%wheel ALL=(ALL:ALL) ALL" >> $_sudoersFilePath
echo "%sudo	ALL=(ALL:ALL) ALL" >> $_sudoersFilePath

read -p "Setup sudo for (username - or - blank for none/skip): " _username;

if [ "$_username" != "" ]
then
    pw usermod $_username -G wheel,sudo

    echo "$_username ALL=(ALL:ALL) ALL" >> $_sudoersFilePath
else fi

echo "# End Added by FreeBSD-Setup script" >> $_sudoersFilePath

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Setting up Xorg...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

pkg install xorg -y

read -p "Setup xorg for (username - or - blank for none/skip): " _username;

if [ "$_username" != "" ]
then
    pw groupmod video -m $_username
else fi

echo "" >> $_bootloaderConfFilePath
echo "# Added by FreeBSD-Setup script (\"Setting up Xorg...\" phase)" >> $_bootloaderConfFilePath
echo "kern.vty=vt" >> $_bootloaderConfFilePath
echo "# End Added by FreeBSD-Setup script" >> $_bootloaderConfFilePath

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                  Setting up Video Card...                  ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

echo "Choose your video card to configure: "
echo "  - i915kms -> Intel KMS Driver"
echo "  - radeonkms -> Older Radeon KMS Driver"
echo "  - amdgpu -> Newer AMD KMS Driver"
echo "  - intel -> Intel graphics up to Ivy Bridge (HD Graphics 2500, 4000, and P4000), Iron Lake (HD Graphics), Sandy Bridge (HD Graphics 2000)"
echo "  - radeon -> Radeon cards up to and including the HD6000 series"
echo "  - nvidia -> nVidia [W.I.P.] - do not use yet" # TODO: Add support for nVidia (nvidia-driver, etc.)

read -p "Which one: " _videoDriver;

if ["$_videoDriver" = "nvidia"]
    echo "nVidia is currently not yet supported, sorry" # TODO: Add support for nVidia (nvidia-driver, etc.)

    sleep 3
then
else
    pkg install drm-kmod -y

    echo "" >> $_etcRcConfFilePath
    echo "# Added by FreeBSD-Setup script (\"$_videoDriver\" video card driver)" >> $_etcRcConfFilePath

    sysrc -f $_etcRcConfFilePath kld_list+=$_videoDriver

    read -p "Install legacy Intel driver? (yes/no): " _shouldInstallLegacyIntelDriver;

    if [ "$_shouldInstallLegacyIntelDriver" = "yes" ]
    then
        pkg install xf86-video-intel -y
    else fi
fi

read -p "Setup video driver in file (use \"no\" for VM)? (yes/no): " _shouldSetupVideoDriverFile;

if [ "$_shouldSetupVideoDriverFile" = "yes" ]
then
    echo "Choose driver to setup (intel/radeon/vesa/scfb)."
    echo "This will create a file in \"$_videoDriverFileDir\"."

    read -p "Which driver: " _videoDriverInFileName;

    _videoDriverFilePath=$_videoDriverFileDir"driver-"$_videoDriverInFileName".conf";

    echo "# Added by FreeBSD-Setup script (\"Setting up video card...\" phase)" >> $_videoDriverFilePath

    echo "Section \"Device\"" >> $_videoDriverFilePath
    echo "  Identifier \"Card0\"" >> $_videoDriverFilePath
    echo "  Driver     \"$_videoDriverInFileName\"" >> $_videoDriverFilePath
    echo "EndSection" >> $_videoDriverFilePath

    echo "# End Added by FreeBSD-Setup script" >> $_videoDriverFilePath
else fi

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##               Setting up Display Manager...                ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

echo "Currently there are a couple of supported Display Managers:"
echo "  - gdm -> GNOME Display Manager"
echo "  - sddm -> Simple Desktop Display Manager"
echo "  - slim -> Simple Login Manager"

read -p "Which one: " _displayManager;

pkg install $_displayManager -y

echo "" >> $_etcRcConfFilePath
echo "# Added by FreeBSD-Setup script (\"Setting up Display Manager...\" phase)" >> $_etcRcConfFilePath

echo "dbus_enable=\"YES\"" >> $_etcRcConfFilePath
echo "hald_enable=\"YES\"" >> $_etcRcConfFilePath
echo "${_displayManager}_enable=\"YES\"" >> $_etcRcConfFilePath

echo "# End Added by FreeBSD-Setup script" >> $_etcRcConfFilePath

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##             Setting up Desktop Environment...              ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

echo "Currently there are a couple of supported Desktop Environments:"
echo "  - gnome-shell -> Core GNOME components"
echo "  - gnome -> Full GNOME environment"
echo "  - plasma5-plasma -> Core KDE components"
echo "  - kde5 -> Full KDE environment"
echo "  - xfce -> XFCE environment"

read -p "Which one: " _desktopEnv;

pkg install $_desktopEnv -y

echo ""
echo "# Added by FreeBSD-Setup script (\"Setting up Desktop Environment...\" phase)" >> $_etcFsbatFilePath
echo "proc           /proc       procfs  rw  0   0" >> $_etcFsbatFilePath
echo "# End Added by FreeBSD-Setup script" >> $_etcFsbatFilePath

if [ "$_desktopEnv" = "gnome-shell" || "$_desktopEnv" = "gnome" ]
then
    echo "" >> $_etcRcConfFilePath
    echo "# Added by FreeBSD-Setup script (\"Setting up Desktop Environment...\" phase)" >> $_etcRcConfFilePath
    echo "gnome_enable=\"YES\"" >> $_etcRcConfFilePath
    echo "# End Added by FreeBSD-Setup script" >> $_etcRcConfFilePath
else fi
