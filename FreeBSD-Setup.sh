# Source: https://github.com/Sejoslaw/FreeBSD-Setup
#
# FreeBSD Configuration Script by Krzysztof "Sejoslaw" Dobrzynski

echo ""
echo "Configuring script..."
echo ""

# Get username for configure

echo ""
echo "Upgrading OS (freebsd-update fetch && install)..."
echo ""

freebsd-update fetch && freebsd-update install

echo ""
echo "Prepare pkg (pkg update && upgrade)..."
echo ""

pkg update && pkg upgrade

echo ""
echo "Setting up sudo..."
echo ""

pkg install sudo

# TODO: Add entry to sudoers

echo ""
echo "Installing core components..."
echo ""

pkg install nano