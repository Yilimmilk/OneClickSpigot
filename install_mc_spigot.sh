#!/bin/bash

project_info = "
#================================================
# Project:  OneClickInstallMcSpigotServer
# Platform: --Debian --CentOS --Ubuntu
# Branch:   --master
# Version:  1.0.0
# Author:   Yilimmilk
# Blog:     https://blog.moz.moe
# Github:   https://github.com/Yilimmilk
# Note:     啊哈，感谢你使用我写的脚本哈 ^_^
#================================================
"

Green_font="\033[32m" && Yellow_font="\033[33m" && Red_font="\033[31m" && Blue_font="\033[34m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Warn="${Yellow_font}[Warn]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"

echo -e "${Green_font}${project_info}${Font_suffix}"

root_need() {
  if [[ "${PM}" = "yum" ]]; then
    yum update
    yum install sudo
  elif [[ "${PM}" = "apt" ]]; then
    apt update
    apt install sudo
  else
    echo -e "${Error} 未知的数据，请提交issues反馈!" && exit 1
  fi
  if [[ $EUID -ne 0 ]]; then
    echo -e "${Error}噫，貌似我没有权限来执行这个脚本，咱必须得要有root权限才行撒"
    echo -e "${Error}我觉得,你要不试试'sudo $0'?" 1>&2
    exit 1
  fi
}

check_system() {
  if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    DISTRO='CentOS'
    PM='yum'
  elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
    DISTRO='RHEL'
    PM='yum'
  elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
    DISTRO='Aliyun'
    PM='yum'
  elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
    DISTRO='Fedora'
    PM='yum'
  elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
    DISTRO='Debian'
    PM='apt'
  elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
    DISTRO='Ubuntu'
    PM='apt'
  elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
    DISTRO='Raspbian'
    PM='apt'
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${Error}嘛，虽然你的系统好像是Mac OS(Darwin),但是并不支持:${detectSys}" && exit 1
  elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo -e "${Error}嘛，虽然你的系统好像是FreeBSD,但是并不支持:${detectSys}" && exit 1
  else
    DISTRO='unknow'
    echo -e "${Error}嘛，我也不知道这是什么系统，反正好像并不支持" && exit 1
  fi
  echo -e "${Info}首先，咱们检测一下系统:${DISTRO}"
  echo -e "${Info}你的系统的软件包管理为:${PM}"
}

install_lib() {
  echo "================================================"
  echo -e "${Info}现在，我要安装一些必要的库，请耐心等待一下哈"
  if [[ "${PM}" = "yum" ]]; then
    yum install -y wget zip unzip openssl curl screen
  elif [[ "${PM}" = "apt" ]]; then
    apt-get install -y wget zip unzip openssl curl screen
  else
    echo -e "${Error} 未知的数据，请提交issues反馈!" && exit 1
  fi
  currentDirec=$(pwd)
  echo "当前目录:${currentDirec}"
  echo "================================================"
  echo -e "${Info}然后，我开始安装java"
  if [ ! -f "jre-8u241-linux-x64.tar.gz" ]; then
    echo -e "${Info}此下载过程可能耗时较长，不要急"
    wget https://mozmoe.oss-cn-hangzhou.aliyuncs.com/source/jre-8u241-linux-x64.tar.gz --no-check-certificate
  else
    echo -e "${Warn}喔唷，看样子你已经下载过了这个文件，那么我就跳过下载这一步了哈"
  fi

  echo -e "${Info}那我就默认将java装在这个目录下了哈:/usr/lib/java8"
  mkdir /usr/lib/java8
  tar -zxvf jre-8u241-linux-x64.tar.gz -C /usr/lib/java8
  echo "export JAVA_HOME=/usr/lib/java8/jre1.8.0_241" >~/.bashrc
  echo "export CLASSPATH=.:${JAVA_HOME}/lib" >~/.bashrc
  echo "export PATH=${JAVA_HOME}/bin:$PATH" >~/.bashrc
  source ~/.bashrc
  echo -e "${Info}好了,Java安装完毕"
  cd /root
}

select_directory() {
  currentDirec=$(pwd)
  echo "当前目录:${currentDirec}"
  echo "================================================"
  echo -e "那么，现在到你选择的时候了:"
  echo "请选择你要安装的位置"
  echo "1.当前目录:${currentDirec}(默认)"
  echo "2./root 目录"
  echo "================================================"
  read -p "来，做出你的选择吧:" selectDirec
  [[ -z "${selectDirec}" ]] && selectDirec=1
  while [[ ! "${selectDirec}" =~ ^[1-2]$ ]]; do
    echo -e "${Error}你输入的好像有点问题，咱们重新来一次吧"
    echo -e "${Info} 请重新选择" && read -p "输入数字以选择:" selectDirec
  done
  if [[ "${selectDirec}" == "2" ]]; then
    cd /root
    serverDirec="/root/spigot_server"
  else
    serverDirec="${currentDirec}/spigot_server"
  fi
}

start_install() {
  clear
  currentDirec=$(pwd)
  echo "当前目录:${currentDirec}"
  echo "================================================"
  echo -e "现在，选个你想安装的版本咯:"
  echo "请选择你要安装的版本,以下是几个常用版本"
  echo "1.--1.15.2--"
  echo "2.--1.14.4--"
  echo "3.--1.13.2--"
  echo "4.--1.12.2--"
  echo "5.--1.11.2--"
  echo "6.--1.10.2--"
  echo "7.--1.9.4--"
  echo "8.--1.9--"
  echo "9.--1.8.8--"
  echo "10.--1.8--"
  echo "11.--1.7.10--"
  echo "12.手动输入下载地址"
  echo "备注:官网下载页面地址:https://getbukkit.org/download/spigot"
  echo "================================================"
  read -p "来，做出你的选择吧:" selectVersion
  while [[ ! "${selectVersion}" =~ ^[1-9][0-2]$ ]]; do
    echo -e "${Error}你输入的好像有点问题，咱们重新来一次吧"
    echo -e "${Info} 请重新选择" && read -p "输入数字以选择:" selectVersion
  done

  case ${selectVersion} in
  1)
    echo -e "${Info} 开始从官方下载1.15.2版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.15.2.jar --no-check-certificate
    ;;

  2)
    echo -e "${Info} 开始从官方下载1.14.4版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.14.4.jar --no-check-certificate
    ;;

  3)
    echo -e "${Info} 开始从官方下载1.13.2版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.13.2.jar --no-check-certificate
    ;;

  4)
    echo -e "${Info} 开始从官方下载1.12.2版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.12.2.jar --no-check-certificate
    ;;

  5)
    echo -e "${Info} 开始从官方下载1.11.2版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.11.2.jar --no-check-certificate
    ;;

  6)
    echo -e "${Info} 开始从官方下载1.10.2版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.10.2-R0.1-SNAPSHOT-latest.jar --no-check-certificate
    ;;

  7)
    echo -e "${Info} 开始从官方下载1.9.4版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.9.4-R0.1-SNAPSHOT-latest.jar --no-check-certificate
    ;;

  8)
    echo -e "${Info} 开始从官方下载1.9版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.9-R0.1-SNAPSHOT-latest.jar --no-check-certificate
    ;;

  9)
    echo -e "${Info} 开始从官方下载1.8.8版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.8.8-R0.1-SNAPSHOT-latest.jar --no-check-certificate
    ;;

  10)
    echo -e "${Info} 开始从官方下载1.8版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.8-R0.1-SNAPSHOT-latest.jar --no-check-certificate
    ;;

  11)
    echo -e "${Info} 开始从官方下载1.7.10版本，由于服务器远在海外，速度不保证哈"
    wget https://cdn.getbukkit.org/spigot/spigot-1.7.10-SNAPSHOT-b1657.jar --no-check-certificate
    ;;

  12)
    echo -e "${Info} 嘛，既然你选择了手动输入，那就开始吧:"
    read -p "输入你的下载链接:" DownloadLink
    wget ${DownloadLink} --no-check-certificate
    ;;

  esac
}

##########################################################################################

check_system
root_need
install_lib
select_directory
mkdir spigot_server
cd spigot_server
start_install
java -Xms512M -Xmx2048M -jar spigot-1.8-R0.1-SNAPSHOT-latest.jar nogui
