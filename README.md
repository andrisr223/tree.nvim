# Tree.nvim - File explorer powered by C++.

[![Build Status](https://circleci.com/gh/zgpio/tree.nvim.svg?style=svg)](https://circleci.com/gh/zgpio/tree.nvim)
[![Build Status](https://travis-ci.org/zgpio/tree.nvim.svg?branch=master)](https://travis-ci.org/zgpio/tree.nvim)
[![Build status](https://ci.appveyor.com/api/projects/status/v0tb04id681b49xx/branch/master?svg=true)](https://ci.appveyor.com/project/zgpio/tree-nvim/branch/master)

🎉: `QT` dependencies removed (2020-03-21)

## Requirements
- [NeoVim nightly](https://github.com/neovim/neovim/releases/tag/nightly)

## Features
- Support Linux/MacOS/Windows
- NeoVim line-based highlight (`conceal` free)
- High performance
- Defx's UI/API (minor revision)
- For more information refer to [doc](runtime/doc/tree.txt)

## Usage
![Demo](https://user-images.githubusercontent.com/19503791/86912092-f3326f00-c14e-11ea-9d98-b65563c1bd6c.png)
![Demo](https://github.com/zgpio/demo/blob/master/tree_demo.gif)

### Config
#### Step 1
```sh
mkdir tree.nvim && cd tree.nvim
# via wget or curl
sh -c "$(wget -O- https://raw.githubusercontent.com/zgpio/tree.nvim/master/install.sh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zgpio/tree.nvim/master/install.sh)"
```
#### Step 2
```vim
" Add tree.nvim to runtime path
set rtp+=/path/to/tree.nvim/
" Start user configuration
" ...
```
User configuration ref to [config.vim](src/app/dev.vim).

## Build
### macos
```sh
brew install boost
git clone https://github.com/zgpio/tree.nvim

cmake -DCMAKE_INSTALL_PREFIX=./INSTALL -DBoost_USE_STATIC_LIBS=ON -DCMAKE_BUILD_TYPE=Release -S tree.nvim/ -B tree.nvim/build
make -C tree.nvim/build/ install
```
### ubuntu1804
```sh
# cmake 3.10  boost 1.65
sudo apt install cmake libboost-filesystem-dev
git clone https://github.com/zgpio/tree.nvim.git
cd tree.nvim
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=./INSTALL -DBoost_USE_STATIC_LIBS=ON -DCMAKE_BUILD_TYPE=Release  ..
make install
```
