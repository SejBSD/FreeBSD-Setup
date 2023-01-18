#!/bin/sh

sh ./Internal_Update.sh

install_llvm() {
    sudo pkg install -y llvm
}

install_npm() {
    sudo pkg install -y npm
}

install_typescript() {
    sudo npm install -g typescript
}

install_gcc() {
    echo ""
    read -p "## Do you want to install gcc? (yes/no) " _installGcc;

    if [ "$_installGcc" = "yes" ]
    then
        sudo pkg install -y gcc
    fi
}

install_ide() {
    if [ "$0" != "" ]
    then
        sudo pkg install -y $1
    fi
}

install_common_vscode_extensions() {
    sh ./Internal_Common_VSCode_Extensions.sh
}

install_common_vscode_npm_extensions() {
    vscode --install-extension dbaeumer.vscode-eslint               # https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint
    vscode --install-extension eg2.vscode-npm-script                # https://marketplace.visualstudio.com/items?itemName=eg2.vscode-npm-script
    vscode --install-extension rbbit.typescript-hero                # https://marketplace.visualstudio.com/items?itemName=rbbit.typescript-hero
    vscode --install-extension pmneo.tsimporter                     # https://marketplace.visualstudio.com/items?itemName=pmneo.tsimporter
    vscode --install-extension Wscats.eno                           # https://marketplace.visualstudio.com/items?itemName=Wscats.eno
    vscode --install-extension christian-kohler.npm-intellisense    # https://marketplace.visualstudio.com/items?itemName=christian-kohler.npm-intellisense
    vscode --install-extension Orta.vscode-jest                     # https://marketplace.visualstudio.com/items?itemName=Orta.vscode-jest
    vscode --install-extension leizongmin.node-module-intellisense  # https://marketplace.visualstudio.com/items?itemName=leizongmin.node-module-intellisense
}

echo ""
echo "################################################################"
echo "##                                                            ##"
echo "##            Setting up Development Environment...           ##"
echo "##                                                            ##"
echo "################################################################"
echo ""

_etcFsbatFilePath=/etc/fstab

echo ""
read -p "## Choose language (shell, java, rust, sql, cpp, python, go, dotnet-mono, angular, react, vue, lua): " _language;

if [ "$_language" = "shell" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                     Setting up Shell...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    echo ""
    read -p "## Choose IDE (vscode): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        sudo pkg install -y hs-ShellCheck

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

    sudo pkg install -y openjdk8 openjdk11 openjdk17 openjdk18 openjdk19 maven gradle

    echo ""
    read -p "## OpenJDK implementation requires fdescfs(5) mounted on /dev/fd. Mount? (yes/no) " _mountFdescfs;

    if [ "$_mountFdescfs" = "yes" ]
    then
        echo "fdesc /dev/fd fdescfs rw 0 0" | sudo tee -a $_etcFsbatFilePath
    fi

    echo ""
    read -p "## OpenJDK implementation requires procfs(5) mounted on /proc. Mount? (yes/no) " _mountProcfs;

    if [ "$_mountProcfs" = "yes" ]
    then
        echo "proc /proc procfs rw 0 0" | sudo tee -a $_etcFsbatFilePath
    fi

    echo ""
    read -p "## Choose IDE (intellij, eclipse, netbeans, vscode): " _ide;

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

    echo ""
    read -p "## Setup rustup? (yes/no) " _setupRustup;

    if [ "$_setupRustup" = "yes" ]
    then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi

    echo ""
    echo "## You may need to logout for rust toolchain binaries to be found ##"
    echo ""
    sleep 7

    echo ""
    read -p "## Choose IDE (vscode, intellij): " _ide;

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

    echo ""
    read -p "## Choose IDE (vscode): " _ide;

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

if [ "$_language" = "cpp" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                     Setting up C/C++...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    install_llvm

    echo ""
    read -p "## Choose IDE (vscode, codeblocks, anjuta, upp (TheIDE), eclipse-cdt, kdevelop, qtcreator, jucipp, jetbrains-clion): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions

        vscode --install-extension llvm-vs-code-extensions.vscode-clangd    # https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd
        vscode --install-extension ms-vscode.cmake-tools                    # https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
        vscode --install-extension webfreak.debug                           # https://marketplace.visualstudio.com/items?itemName=webfreak.debug
        vscode --install-extension danielpinto8zz6.c-cpp-project-generator  # https://marketplace.visualstudio.com/items?itemName=danielpinto8zz6.c-cpp-project-generator
        vscode --install-extension cschlosser.doxdocgen                     # https://marketplace.visualstudio.com/items?itemName=cschlosser.doxdocgen
        vscode --install-extension ms-vscode.makefile-tools                 # https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools
        vscode --install-extension austin.code-gnu-global                   # https://marketplace.visualstudio.com/items?itemName=austin.code-gnu-global
    fi

    install_gcc
fi

if [ "$_language" = "python" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                    Setting up Python...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    sudo pkg install -y python py39-pip

    echo ""
    read -p "## Choose IDE (vscode, pycharm-ce, pycharm-pro, spyder, py-spyder, eric6-qt5-py39, eclipse-pydev): " _ide;

    install_ide $_ide

    if [ "$_ide" = "spyder" ] || [ "$_ide" = "py-spyder" ]
    then
        sudo pkg install -y py39-docstring-to-markdown
    fi

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions

        vscode --install-extension ms-python.python                         # https://marketplace.visualstudio.com/items?itemName=ms-python.python
        vscode --install-extension batisteo.vscode-django                   # https://marketplace.visualstudio.com/items?itemName=batisteo.vscode-django
        vscode --install-extension wholroyd.jinja                           # https://marketplace.visualstudio.com/items?itemName=wholroyd.jinja
        vscode --install-extension njpwerner.autodocstring                  # https://marketplace.visualstudio.com/items?itemName=njpwerner.autodocstring
        vscode --install-extension KevinRose.vsc-python-indent              # https://marketplace.visualstudio.com/items?itemName=KevinRose.vsc-python-indent
        vscode --install-extension donjayamanne.python-environment-manager  # https://marketplace.visualstudio.com/items?itemName=donjayamanne.python-environment-manager
    fi
fi

if [ "$_language" = "go" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                    Setting up Golang...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    sudo pkg install -y go gpm gobuffalo

    echo ""
    read -p "## Choose IDE (vscode, liteide): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions

        vscode --install-extension golang.Go    # https://marketplace.visualstudio.com/items?itemName=golang.Go
    fi
fi

if [ "$_language" = "dotnet-mono" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                    Setting up C# Mono...                   ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    sudo pkg install -y mono msbuild

    echo ""
    read -p "## Choose IDE (vscode): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions

        vscode --install-extension ms-dotnettools.csharp        # https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp
        vscode --install-extension k--kato.docomment            # https://marketplace.visualstudio.com/items?itemName=k--kato.docomment
        vscode --install-extension Fudge.auto-using             # https://marketplace.visualstudio.com/items?itemName=Fudge.auto-using
        vscode --install-extension adrianwilczynski.namespace   # https://marketplace.visualstudio.com/items?itemName=adrianwilczynski.namespace
    fi
fi

if [ "$_language" = "angular" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                    Setting up Angular...                   ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    install_npm
    install_typescript
    
    sudo npm install -g @angular/cli

    echo ""
    read -p "## Choose IDE (vscode, jetbrains-webstorm): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions
        install_common_vscode_npm_extensions

        vscode --install-extension Angular.ng-template              # https://marketplace.visualstudio.com/items?itemName=Angular.ng-template
        vscode --install-extension cyrilletuzi.angular-schematics   # https://marketplace.visualstudio.com/items?itemName=cyrilletuzi.angular-schematics
        vscode --install-extension segerdekort.angular-cli          # https://marketplace.visualstudio.com/items?itemName=segerdekort.angular-cli
    fi
fi

if [ "$_language" = "react" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                     Setting up React...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    install_npm
    install_typescript

    sudo npm install -g create-react-app react redux react-redux

    echo ""
    read -p "## Choose IDE (vscode, jetbrains-webstorm): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions
        install_common_vscode_npm_extensions

        vscode --install-extension dsznajder.es7-react-js-snippets      # https://marketplace.visualstudio.com/items?itemName=dsznajder.es7-react-js-snippets
        vscode --install-extension msjsdiag.vscode-react-native         # https://marketplace.visualstudio.com/items?itemName=msjsdiag.vscode-react-native
        vscode --install-extension burkeholland.simple-react-snippets   # https://marketplace.visualstudio.com/items?itemName=burkeholland.simple-react-snippets
        vscode --install-extension EQuimper.react-native-react-redux    # https://marketplace.visualstudio.com/items?itemName=EQuimper.react-native-react-redux
        vscode --install-extension jingkaizhao.vscode-redux-devtools    # https://marketplace.visualstudio.com/items?itemName=jingkaizhao.vscode-redux-devtools
    fi
fi

if [ "$_language" = "vue" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                    Setting up Vue.js...                    ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    install_npm
    install_typescript
    
    sudo npm install -g @vue/cli

    echo ""
    read -p "## Choose IDE (vscode, jetbrains-webstorm): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        install_common_vscode_extensions
        install_common_vscode_npm_extensions

        vscode --install-extension Vue.volar                        # https://marketplace.visualstudio.com/items?itemName=Vue.volar
        vscode --install-extension Vue.vscode-typescript-vue-plugin # https://marketplace.visualstudio.com/items?itemName=Vue.vscode-typescript-vue-plugin
        vscode --install-extension hollowtree.vue-snippets          # https://marketplace.visualstudio.com/items?itemName=hollowtree.vue-snippets
    fi
fi

if [ "$_language" = "lua" ]
then
    echo ""
    echo "################################################################"
    echo "##                                                            ##"
    echo "##                      Setting up Lua...                     ##"
    echo "##                                                            ##"
    echo "################################################################"
    echo ""

    echo ""
    read -p "## Choose IDE (vscode): " _ide;

    install_ide $_ide

    if [ "$_ide" = "vscode" ]
    then
        sudo pkg install -y lua-language-server lua51 lua52 lua53 lua54

        install_common_vscode_extensions sumneko.lua    # https://marketplace.visualstudio.com/items?itemName=sumneko.lua
    fi
fi

# TODO Idea: Perl

# TODO Idea: Ruby

# TODO Idea: PHP
