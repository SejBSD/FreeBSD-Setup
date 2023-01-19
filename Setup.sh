#!/bin/sh

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
_etcFstabFilePath=/etc/fstab
_etcDevfsRulesFilePath=/etc/devfs.rules
_etcPkgFConf=/etc/pkg/FreeBSD.conf

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
echo "##                   Setting up pkg URLs...                   ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Change pkg URLs to latest? (yes/no) " _pkgLatest;

if [ "$_pkgLatest" = "yes" ]
then
    sed -i 'orig' 's/quarterly/latest/' $_etcPkgFConf
    grep url $_etcPkgFConf
fi

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
echo "##                     Setting up User...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Specify username for which to configure your OS? (username) " _user;

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Setting up sudo...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

pkg install -y sudo

echo "" >> $_sudoersFilePath
echo "# Added by FreeBSD-Setup script (\"Setting up sudo...\" phase)" >> $_sudoersFilePath

echo "%wheel ALL=(ALL:ALL) ALL" >> $_sudoersFilePath
echo "%sudo	ALL=(ALL:ALL) ALL" >> $_sudoersFilePath

if [ "$_user" != "" ]
then
    pw usermod $_user -G wheel,sudo

    echo "$_user ALL=(ALL:ALL) ALL" >> $_sudoersFilePath
fi

echo "# End Added by FreeBSD-Setup script" >> $_sudoersFilePath

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                     Setting up Xorg...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

pkg install -y xorg

if [ "$_user" != "" ]
then
    pw groupmod video -m $_user
fi

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
echo "  - nvidia -> nVidia - do not use yet" # TODO: Add support for nVidia (nvidia-driver, etc.)

read -p "Which one: " _videoDriver;

if [ "$_videoDriver" = "nvidia" ]
then
    echo "nVidia is currently not yet supported, sorry" # TODO: Add support for nVidia (nvidia-driver, etc.)

    sleep 3
else
    pkg install -y drm-kmod

    echo "" >> $_etcRcConfFilePath
    echo "# Added by FreeBSD-Setup script (\"$_videoDriver\" video card driver)" >> $_etcRcConfFilePath

    sysrc -f $_etcRcConfFilePath kld_list+=$_videoDriver

    read -p "Install legacy Intel driver? (yes/no): " _shouldInstallLegacyIntelDriver;

    if [ "$_shouldInstallLegacyIntelDriver" = "yes" ]
    then
        pkg install -y xf86-video-intel
    fi
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
fi

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

pkg install -y $_displayManager

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

pkg install -y $_desktopEnv

echo ""
echo "# Added by FreeBSD-Setup script (\"Setting up Desktop Environment...\" phase)" >> $_etcFstabFilePath
echo "proc           /proc       procfs  rw  0   0" >> $_etcFstabFilePath
echo "# End Added by FreeBSD-Setup script" >> $_etcFstabFilePath

if [ "$_desktopEnv" = "gnome-shell" ] || [ "$_desktopEnv" = "gnome" ]
then
    echo "" >> $_etcRcConfFilePath
    echo "# Added by FreeBSD-Setup script (\"Setting up Desktop Environment...\" phase)" >> $_etcRcConfFilePath
    echo "gnome_enable=\"YES\"" >> $_etcRcConfFilePath
    echo "# End Added by FreeBSD-Setup script" >> $_etcRcConfFilePath
fi

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                    Setting up Wi-Fi...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

pkg install -y networkmgr wifimgr

echo "" >> $_etcRcConfFilePath
echo "# Added by FreeBSD-Setup script (\"Setting up Wi-Fi...\" phase)" >> $_etcRcConfFilePath

echo "wlans_iwm0=\"wlan0\"" >> $_etcRcConfFilePath
echo "ifconfig_wlan0=\"WPA DHCP\"" >> $_etcRcConfFilePath

echo "# End Added by FreeBSD-Setup script" >> $_etcRcConfFilePath

_userAutostartDir=/home/$_user/.config/autostart
mkdir -p $_userAutostartDir

_networkmgrEntry=networkmgr.desktop

echo "[Desktop Entry]" >> $_networkmgrEntry
echo "Type=Application" >> $_networkmgrEntry
echo "Name=Network Manager" >> $_networkmgrEntry
echo "Comment=Network Manager" >> $_networkmgrEntry
echo "Exec=networkmgr" >> $_networkmgrEntry

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                    Setting up Tools...                     ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Install core tools (nano, htop, neofetch)? (yes/no): " _shouldInstallCoreTools;

if [ "$_shouldInstallCoreTools" = "yes" ]
then
    pkg install -y nano htop neofetch

    if [ "$_user" != "" ]
    then
        _shrcFilePath=/home/$_user/.shrc

        echo "" >> $_shrcFilePath
        echo "# Added by FreeBSD-Setup script (Enable Neofetch on terminal open)" >> $_shrcFilePath
        echo "neofetch" >> $_shrcFilePath
        echo "# End Added by FreeBSD-Setup script" >> $_shrcFilePath
    fi
fi

read -p "Install terminal, file manager, baobab (disk usage scanner) (GNOME)? (yes/no): " _shouldInstallGnomeCoreTools;

if [ "$_shouldInstallGnomeCoreTools" = "yes" ]
then
    pkg install -y gnome-terminal nautilus baobab
fi

read -p "Install common tools (vscode, flameshot, dconf-editor, inkscape, Virtual Machine Manager (virt-manager))? (yes/no): " _shouldInstallCommonTools;

if [ "$_shouldInstallCommonTools" = "yes" ]
then
    pkg install -y vscode flameshot dconf-editor inkscape virt-manager
fi

read -p "Install Web Browser (firefox/chromium)? (empty for none): " _webBrowser;

if [ "$_webBrowser" != "" ]
then
    pkg install -y $_webBrowser
fi

read -p "Install and configure VirtualBox? (yes/no): " _shouldInstallVBox;

if [ "$_shouldInstallVBox" = "yes" ]
then
    pkg install -y virtualbox-ose virtualbox-ose-additions

    echo "" >> $_bootloaderConfFilePath
    echo "# Added by FreeBSD-Setup script (Install VirtualBox)" >> $_bootloaderConfFilePath
    echo "vboxdrv_load=\"YES\"" >> $_bootloaderConfFilePath
    echo "# End Added by FreeBSD-Setup script" >> $_bootloaderConfFilePath

    echo "" >> $_etcRcConfFilePath
    echo "# Added by FreeBSD-Setup script (Install VirtualBox)" >> $_etcRcConfFilePath
    echo "vboxnet_enable=\"YES\"" >> $_etcRcConfFilePath
    echo "vboxguest_enable=\"YES\"" >> $_etcRcConfFilePath
    echo "vboxservice_enable=\"YES\"" >> $_etcRcConfFilePath
    echo "devfs_system_ruleset=\"system"\" >> $_etcRcConfFilePath
    echo "# End Added by FreeBSD-Setup script" >> $_etcRcConfFilePath

    pw groupmod vboxusers -m $_user
    pw groupmod operator -m $_user

    echo "" >> $_etcDevfsRulesFilePath
    echo "# Added by FreeBSD-Setup script (Install VirtualBox)" >> $_etcDevfsRulesFilePath
    echo "[system=10]" >> $_etcDevfsRulesFilePath
    echo "add path 'usb/*' mode 0660 group operator" >> $_etcDevfsRulesFilePath
    echo "# End Added by FreeBSD-Setup script" >> $_etcDevfsRulesFilePath
fi

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                  Setting up Quick Boot...                  ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Enable quick boot / mute boot? (yes/no): " _shouldEnableQuickBoot;

if [ "$_shouldEnableQuickBoot" = "yes" ]
then
    echo "" >> $_bootloaderConfFilePath
    echo "# Added by FreeBSD-Setup script (\"Setting up Quick Boot...\" phase)" >> $_bootloaderConfFilePath
    echo "autoboot_delay=\"0\"" >> $_bootloaderConfFilePath
    echo "boot_mute=\"YES\"" >> $_bootloaderConfFilePath
    echo "# End Added by FreeBSD-Setup script" >> $_bootloaderConfFilePath
fi

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                 Setting up Screen Saver...                 ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Disable screen saver? (yes/no): " _shouldDisableScreenSaver;

if [ "$_shouldDisableScreenSaver" = "yes" ] && [ "$_user" != "" ]
then
    _xprofileFilePath=/home/$_user/.xprofile

    echo "" >> $_xprofileFilePath
    echo "# Added by FreeBSD-Setup script (\"Setting up Screen Saver...\" phase)" >> $_xprofileFilePath
    echo "xset s 0" >> $_xprofileFilePath
    echo "xset s off" >> $_xprofileFilePath
    echo "xset s noexpose" >> $_xprofileFilePath
    echo "xset s noblank" >> $_xprofileFilePath
    echo "# End Added by FreeBSD-Setup script" >> $_xprofileFilePath
fi

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##          Setting up Linux Binary Compatibility...          ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Enable Linux Binary Compatibility? (yes/no) " _enableLinux;

if [ "$_enableLinux" = "yes" ]
then
    echo "" >> $_etcRcConfFilePath;
    echo "# Added by FreeBSD-Setup script (\"Setting up Linux Binary Compatibility...\" phase)" >> $_etcRcConfFilePath;
    echo "linux_enable=\"YES\"" >> $_etcRcConfFilePath;
    echo "# End Added by FreeBSD-Setup script" >> $_etcRcConfFilePath;

    echo "Starting Linux service..."
    service linux start

    pkg install -y linux_base-c7

    echo "" >> $_etcFstabFilePath;
    echo "# Added by FreeBSD-Setup script (\"Setting up Linux Binary Compatibility...\" phase)" >> $_etcFstabFilePath;
    echo "linprocfs   /compat/linux/proc  linprocfs       rw      0       0" >> $_etcFstabFilePath;
    echo "linsysfs    /compat/linux/sys   linsysfs        rw      0       0" >> $_etcFstabFilePath;
    echo "# End Added by FreeBSD-Setup script" >> $_etcFstabFilePath;

    mount /compat/linux/proc
    mount /compat/linux/sys
fi

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##                  Setting up IO support...                  ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

read -p "Enable MMC/SD card-reader support? (yes/no) " _cardReaderSupport;

if [ "$_cardReaderSupport" = "yes" ]
then
    sysrc kld_list+="mmc"
	sysrc kld_list+="mmcsd"
	sysrc kld_list+="sdhci"
fi

read -p "Enable access ATAPI devices through the CAM subsystem support? (yes/no) " _atapiSupport;

if [ "$_atapiSupport" = "yes" ]
then
    sysrc kld_list+="atapicam"
fi

read -p "Enable filesystems in userspace support? (yes/no) " _fiuSupport;

if [ "$_fiuSupport" = "yes" ]
then
	pkg install -y fusefs-lkl e2fsprogs fuse fuse-utils
	sysrc kld_list+="fusefs"
fi

read -p "Enable Intel Core thermal sensors support? (yes/no) " _intelThermalSupport;

if [ "$_intelThermalSupport" = "yes" ]
then
    sysrc kld_list+="coretemp"
fi

read -p "Enable AMD K8, K10, K11 thermal sensors support? (yes/no) " _amdThermalSupport;

if [ "$_amdThermalSupport" = "yes" ] && (sysctl -a | grep -q -i "hw.model" | grep -q AMD)
then
    amdtemp_load="YES"
fi

read -p "Enable bluetooth support? (yes/no) " _bluetoothSupport;

if [ "$_bluetoothSupport" = "yes" ]
then
    sysrc kld_list+="ng_ubt"
	sysrc hcsecd_enable="YES"
	sysrc sdpd_enable="YES"
fi

read -p "Enable ipfw firewall support? (yes/no) " _ipfwSupport;

if [ "$_ipfwSupport" = "yes" ]
then
    sysrc firewall_type="WORKSTATION"
	sysrc firewall_myservices="22/tcp"
	sysrc firewall_allowservices="any"
	sysrc firewall_enable="YES"
fi

read -p "Enable in-memory filesystems support? (yes/no) " _tmpfsSupport;

if [ "$_tmpfsSupport" = "yes" ]
then
    sysrc kld_list+="tmpfs"
fi

read -p "Enable asynchronous I/O support? (yes/no) " _asyncioSupport;

if [ "$_asyncioSupport" = "yes" ]
then
    sysrc kld_list+="aio"
fi

read -p "Enable powerd (hiadaptive on AC, adaptive on battery) support? (yes/no) " _powerdSupport;

if [ "$_powerdSupport" = "yes" ]
then
    sysrc powerd_enable="YES"
	sysrc powerd_flags="-a hiadaptive -b adaptive"
fi

read -p "Enable webcams support? (yes/no) " _webcamsSupport;

if [ "$_webcamsSupport" = "yes" ]
then
    pkg install -y webcamd
    sysrc kld_list+="cuse4bsd"
	sysrc webcamd_enable="YES"
fi

read -p "Enable CUPS (printers) support? (yes/no) " _cupsSupport;

if [ "$_cardReaderSupport" = "yes" ]
then
    pkg install -y cups
    sysrc cupsd_enable="YES"
fi

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##               Setting up 3rd Party Tools...                ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

cd /tmp || exit

read -p "Install Ubuntu (Linux Binary Compatibility)? (yes/no) " _installUbuntu;

if [ "$_installUbuntu" = "yes" ]
then
    git clone https://github.com/mrclksr/linux-browser-installer.git

    cd linux-browser-installer || exit

    ./linux-browser-installer chroot create

    read -p "Install web browser (chrome/brave/vivaldi/edge/opera - or - blank for none)? " _webBrowserName;

    if [ "$_webBrowserName" != "" ]
    then
        ./linux-browser-installer install $_webBrowserName
    fi
fi
