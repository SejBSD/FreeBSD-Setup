#!/bin/sh

install_llvm() {
    sudo pkg install llvm
}

install_ide() {
    if [ "$0" != "" ]
    then
        sudo pkg install $1
    fi
}

install_common_vscode_extensions() {
    vscode --install-extension mhutchie.git-graph               # https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph
    vscode --install-extension eamodio.gitlens                  # https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens
    vscode --install-extension formulahendry.auto-close-tag     # https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-close-tag
    vscode --install-extension formulahendry.auto-rename-tag    # https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-rename-tag
    vscode --install-extension formulahendry.code-runner        # https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner
    vscode --install-extension GrapeCity.gc-excelviewer         # https://marketplace.visualstudio.com/items?itemName=GrapeCity.gc-excelviewer
    vscode --install-extension esbenp.prettier-vscode           # https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode
    vscode --install-extension mechatroner.rainbow-csv          # https://marketplace.visualstudio.com/items?itemName=mechatroner.rainbow-csv
    vscode --install-extension Gruntfuggly.todo-tree            # https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree
    vscode --install-extension wayou.vscode-todo-highlight      # https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight
    vscode --install-extension redhat.vscode-xml                # https://marketplace.visualstudio.com/items?itemName=redhat.vscode-xml
    vscode --install-extension redhat.vscode-yaml               # https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
    vscode --install-extension 2gua.rainbow-brackets            # https://marketplace.visualstudio.com/items?itemName=2gua.rainbow-brackets
}

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

read -p "Choose language (shell, java, rust, sql): " _language;

if [ "$_language" = "shell" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                     Setting up Shell...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    read -p "Choose IDE (vscode): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        sudo pkg install hs-ShellCheck

        install_common_vscode_extensions

        vscode --install-extension timonwong.shellcheck     # https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck
    fi
fi

if [ "$_language" = "java" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                     Setting up Java...                     ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    sudo pkg install openjdk8 openjdk11 openjdk17 openjdk18 openjdk19 maven gradle

    read -p "OpenJDK implementation requires fdescfs(5) mounted on /dev/fd. Mount? (yes/no) " _mountFdescfs;

    if [ "$_mountFdescfs" = "yes" ]
    then
        echo "fdesc /dev/fd fdescfs rw 0 0" | sudo tee -a $_etcFsbatFilePath
    fi

    read -p "OpenJDK implementation requires procfs(5) mounted on /proc. Mount? (yes/no) " _mountProcfs;

    if [ "$_mountProcfs" = "yes" ]
    then
        echo "proc /proc procfs rw 0 0" | sudo tee -a $_etcFsbatFilePath
    fi

    read -p "Choose IDE (intellij, eclipse, netbeans, vscode): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions
        
        vscode --install-extension vscjava.vscode-java-pack     # https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack
        vscode --install-extension vscjava.vscode-lombok        # https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-lombok
        vscode --install-extension pivotal.vscode-boot-dev-pack # https://marketplace.visualstudio.com/items?itemName=pivotal.vscode-boot-dev-pack
        vscode --install-extension vscjava.vscode-gradle        # https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle
    fi
fi

if [ "$_language" = "rust" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                      Setting up Rust...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    install_llvm

    read -p "Setup rustup? (yes/no) " _setupRustup;

    if [ "$_setupRustup" = "yes" ]
    then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi

    echo ""
    echo "## You may need to logout for rust toolchain binaries to be found ##"
    echo ""
    sleep 7

    read -p "Choose IDE (vscode, intellij): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions

        vscode --install-extension rust-lang.rust-analyzer              # https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer
        vscode --install-extension swellaby.vscode-rust-test-adapter    # https://marketplace.visualstudio.com/items?itemName=swellaby.vscode-rust-test-adapter
        vscode --install-extension serayuzgur.crates                    # https://marketplace.visualstudio.com/items?itemName=serayuzgur.crates
        vscode --install-extension panicbit.cargo                       # https://marketplace.visualstudio.com/items?itemName=panicbit.cargo
        vscode --install-extension better-toml                          # https://marketplace.visualstudio.com/items?itemName=bungcip.better-toml
        vscode --install-extension vadimcn.vscode-lldb                  # https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb
        vscode --install-extension webfreak.debug                       # https://marketplace.visualstudio.com/items?itemName=webfreak.debug
    fi

    echo ""
    echo "## Run in empty project directory: cargo init ##"
    echo ""
    sleep 7
fi

if [ "$_language" = "sql" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                      Setting up SQL...                     ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    read -p "Choose IDE (vscode): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions

        vscode --install-extension ms-mssql.mssql                           # https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql
        vscode --install-extension formulahendry.vscode-mysql               # https://marketplace.visualstudio.com/items?itemName=formulahendry.vscode-mysql
        vscode --install-extension alexcvzz.vscode-sqlite                   # https://marketplace.visualstudio.com/items?itemName=alexcvzz.vscode-sqlite
        vscode --install-extension ms-ossdata.vscode-postgresql             # https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-postgresql

        vscode --install-extension mtxr.sqltools                            # https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools
        vscode --install-extension mtxr.sqltools-driver-mysql               # https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-mysql
        vscode --install-extension mtxr.sqltools-driver-pg                  # https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-pg
        vscode --install-extension mtxr.sqltools-driver-sqlite              # https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-sqlite
        vscode --install-extension mtxr.sqltools-driver-mssql               # https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-mssql
        vscode --install-extension koszti.snowflake-driver-for-sqltools     # https://marketplace.visualstudio.com/items?itemName=koszti.snowflake-driver-for-sqltools
        vscode --install-extension databricks.sqltools-databricks-driver    # https://marketplace.visualstudio.com/items?itemName=databricks.sqltools-databricks-driver
        vscode --install-extension JordanHury.sqltools-cassandra            # https://marketplace.visualstudio.com/items?itemName=JordanHury.sqltools-cassandra
    fi
fi

# TODO: C/C++

# TODO: C# ?

# TODO: Python

# TODO: Go

# TODO: Perl

# TODO: Lua

# TODO: Ruby