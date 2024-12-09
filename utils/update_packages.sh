#!/bin/sh

list_npm_packages() {
    echo "\n\n"
    npm_global_packages=( $(npm list -g --depth 0 | awk '/ /{print $2}') )
    filter_packages_list=""
    for val in "${npm_global_packages[@]}"; do
        filter_packages_list+=$(echo " $val" | tr '@' '\n' | head -1)
    done
    echo "MANUALLY RUN COMMAND TO UPDATED SELECTED PACKAGES"
    echo "npm install -g$filter_packages_list"
}

echo "==> Updating packages"

# brew
echo "\n==> Updating brew"
brew --version
brew update
echo "Updating brew packages"
brew upgrade
echo "List of brew leaves installed:"
brew leaves -r | tr '\n' ' '
echo "\nList of brew cask installed:"
brew list --cask

# deno
echo "\n==> Updating deno"
deno upgrade

# node
echo "\n==> Updating npm"
npm install -g npm
echo "NPM version:" $(npm --version)
echo "Node version:" $(node --version)
npm list -g
echo "Yarn global packages:"
yarn global list

# version checks
echo "\n==> Version checks"
git --version
echo "Typescript version: " $(tsc --version)
echo $(which python3) $(python3 --version)
rustc --version
go version
php --version

list_npm_packages