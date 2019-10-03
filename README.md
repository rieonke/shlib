# shlib
Shell 模块化开发构建尝试

## 安装
### 先决条件
- cmake
- gcc
- glib 2
```bash
# macOS
brew install cmake
brew install gcc  #可选，可以使用Xcode 自带的工具链
brew install glib

# Ubuntu & Debian
sudo apt install cmake
sudo apt install build-essential
sudo apt install libglib2.0-dev

# RedHat & CentOS
sudo yum -y install cmake
sudo yum -y install make gcc glibc-devel
sudo yum -y install glib2-devel

# Fedora
sudo dnf install cmake
sudo dnf install make gcc glibc-devel
sudo dnf install glib2-devel

```
### 开始安装
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rieonke/shlib/master/install.sh)"
```

## 使用
### 基本介绍
#### 项目结构
```
.
├── bin           #构建工具
│   ├── loader.sh #开发时调试需引入loader
│   └── shlib     #构建工具
├── lib           #默认库搜索路径，可在 shlib.ini 中配置
│   ├─── core     #常用库依赖
|   └─── xxx      #其他库依赖库
├── main.sh       #用户代码
└── shlib.ini     #配置文件

```

#### 依赖管理方式

通过伪She-Bang `#!require`引入

```bash
#!require core.array.print   #命名依赖
#!require ./demo_lib.sh      #相对路径依赖
#!require /opt/lib/demo.sh   #绝对路径依赖
#!require $(pwd)/demo_lib.sh #计算值依赖，可以是一条shell语句

arr=(hello world shlib)

core::array::print_in_comma ${arr[@]}
```

#### 构建
bin/shlib 是项目构建工具，可以将所依赖的所有脚本打包成一个单独的文件，所有的依赖项都包含在输出文件中。
```bash
./bin/shlib -o build.out.sh main.sh
```

使用帮助
```bash
> ./bin/shlib --help
Usage: ./bin/shlib [-hlv] [--version] [-O <n>] [-C config file] [-o output file] [<file>]
shlib build tool 

  -h, --help                display this help and exit
  -l, --lib                 print required lib only
  --version                 display version info and exit
  -O, --optimize=<n>        optimize level [ 0 - 1 ], default 0
  -v, --verbose             verbose output
  -C, --config=config file  configure file
  -o, --out=output file     compiled output file, default: build.out.sh
  <file>                    input entry point file
```

### 开始使用
#### 使用脚手架创建项目
```bash

# 下载脚手架工具
wget -c https://raw.githubusercontent.com/rieonke/shlib/master/slcreator.sh
chmod +x ./slcreator.sh

# 创建项目
./slcreator.sh hello_world

```


### TODO
- 环形依赖 （在新的构建工具中尚未支持）
- 输出文件优化&压缩
- 更多的核心库
