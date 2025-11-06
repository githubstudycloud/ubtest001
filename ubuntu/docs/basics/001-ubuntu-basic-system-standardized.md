# Ubuntu基础系统配置指南

## 文档信息
- **文档编号**: 001
- **版本**: 2.0
- **状态**: ✅ 已完成
- **创建日期**: 2025-11-05
- **最后更新**: 2025-11-05
- **作者**: 系统管理员
- **目标系统**: Ubuntu 20.04/22.04/25.04 LTS
- **适用场景**: 新安装Ubuntu服务器的基础配置
- **预计耗时**: 30-60分钟
- **难度等级**: 初级

## 目录
1. [概述](#概述)
2. [前置条件](#前置条件)
3. [SSH服务安装与配置](#ssh服务安装与配置)
4. [网络工具安装](#网络工具安装)
5. [电源管理与屏幕配置](#电源管理与屏幕配置)
6. [软件包源配置](#软件包源配置)
7. [基础安全配置](#基础安全配置)
8. [系统更新与维护](#系统更新与维护)
9. [验证清单](#验证清单)
10. [故障排除](#故障排除)
11. [相关链接](#相关链接)
12. [版本历史](#版本历史)

## 概述

本文档提供了Ubuntu服务器的基础配置指南，包括SSH服务配置、网络工具安装、电源管理、软件源配置、基础安全设置等内容。适用于新安装的Ubuntu服务器初始化配置。

## 前置条件

### 系统要求
- Ubuntu 20.04/22.04/25.04 LTS
- 至少2GB内存
- 至少20GB可用磁盘空间
- 网络连接（用于下载软件包）

### 权限要求
- 具有sudo权限的用户账户
- 能够以root权限执行命令

### 依赖项
- 网络连接正常
- 基础命令行操作经验

## SSH服务安装与配置

### 1. 安装SSH服务

#### 检查SSH服务状态
```bash
# 检查是否已安装SSH
sudo systemctl status ssh

# 检查SSH包是否安装
dpkg -l | grep openssh-server
```

#### 安装SSH服务
```bash
# 更新包列表
sudo apt update

# 安装OpenSSH服务器
sudo apt install openssh-server -y

# 验证安装
sudo systemctl status ssh
```

### 2. SSH基础配置

#### 编辑SSH配置文件
```bash
# 备份原始配置
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 编辑配置文件
sudo nano /etc/ssh/sshd_config
```

#### 推荐配置选项
```bash
# 端口配置（可选，提高安全性）
Port 22

# 禁用root登录（推荐）
PermitRootLogin no

# 启用公钥认证
PubkeyAuthentication yes

# 启用密码认证
PasswordAuthentication yes

# 禁用空密码
PermitEmptyPasswords no

# 配置密钥交换算法（提高兼容性）
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,diffie-hellman-group-exchange-sha256

# 配置加密算法
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com

# 配置MAC算法
MACs hmac-sha2-256,hmac-sha2-512,umac-128@openssh.com
```

### 3. 启动SSH服务并设置开机自启

#### 启动SSH服务
```bash
# 启动SSH服务
sudo systemctl start ssh

# 检查服务状态
sudo systemctl status ssh

# 检查SSH端口监听
sudo netstat -tlnp | grep :22
```

#### 设置开机自启
```bash
# 启用SSH服务开机自启
sudo systemctl enable ssh

# 验证开机自启配置
sudo systemctl is-enabled ssh

# 检查服务启动顺序
systemctl list-unit-files | grep ssh
```

#### 重启SSH服务应用配置
```bash
# 重启SSH服务
sudo systemctl restart ssh

# 重新加载配置（无需重启服务）
sudo systemctl reload ssh

# 检查配置文件语法
sudo sshd -t
```

### 4. SSH连接测试

#### 本地测试
```bash
# 测试SSH服务
ssh ubuntu@localhost

# 测试免密码sudo
sudo whoami
```

#### 远程连接测试
```bash
# 从其他机器连接
ssh -o KexAlgorithms=curve25519-sha256@libssh.org ubuntu@<服务器IP>

# 使用密码认证
ssh -o PreferredAuthentications=password ubuntu@<服务器IP>
```

## 网络工具安装

### 1. 基础网络工具包

#### 安装net-tools（包含ifconfig）
```bash
# 安装net-tools包
sudo apt install net-tools -y

# 验证ifconfig命令
ifconfig --version

# 查看网络接口
ifconfig -a
```

#### 安装网络诊断工具
```bash
# 安装完整的网络工具集
sudo apt install -y \
    net-tools \
    iproute2 \
    inetutils-traceroute \
    dnsutils \
    curl \
    wget \
    nmap \
    tcpdump

# 验证安装
ip addr show
traceroute google.com
nslookup google.com
```

### 2. 网络配置检查

#### 查看网络接口信息
```bash
# 使用ip命令（推荐）
ip addr show
ip route show

# 使用ifconfig命令
ifconfig

# 查看网络统计
ip -s link
```

#### 测试网络连通性
```bash
# 测试本地网络
ping -c 4 192.168.241.1

# 测试外网连接
ping -c 4 8.8.8.8
ping -c 4 google.com

# 测试DNS解析
nslookup google.com
dig google.com
```

### 3. 网络服务配置

#### 配置静态IP（可选）
```bash
# 查看当前网络配置
ip addr show

# 编辑网络配置文件（Ubuntu 18.04+使用netplan）
sudo nano /etc/netplan/01-netcfg.yaml

# 示例配置
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: no
      addresses: [192.168.241.128/24]
      gateway4: 192.168.241.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]

# 应用配置
sudo netplan apply
```

## 电源管理与屏幕配置

### 1. 电源管理设置

#### 查看当前电源状态
```bash
# 查看电源管理信息
upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null || echo "未检测到电池"

# 查看CPU频率调节器
cpupower frequency-info 2>/dev/null || echo "需要安装cpupower工具"

# 查看系统睡眠状态
systemctl status sleep.target suspend.target hibernate.target
```

#### 配置电源管理
```bash
# 安装电源管理工具
sudo apt install -y \
    tlp \
    tlp-rdw \
    powertop

# 启动TLP电源管理
sudo systemctl enable tlp
sudo systemctl start tlp

# 检查TLP状态
sudo tlp-stat
```

### 2. 屏幕省电配置

#### 配置屏幕关闭时间（服务器环境）
```bash
# 方法1: 使用systemd-logind配置
sudo nano /etc/systemd/logind.conf

# 修改以下配置
[Login]
# 空闲15分钟后进入睡眠状态
IdleAction=suspend
IdleActionSec=15min

# 不因盖子关闭而休眠（服务器环境）
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore

# 重启logind服务
sudo systemctl restart systemd-logind
```

#### 配置屏幕关闭（桌面环境）
```bash
# 安装屏幕管理工具（用于桌面环境）
sudo apt install -y x11-xserver-utils

# 使用xset配置屏幕超时（需要在X环境中执行）
xset s 60        # 60秒后屏幕保护
xset dpms 60 0 0 # 60秒后关闭屏幕
```

#### 禁用自动睡眠（服务器推荐）
```bash
# 禁用系统自动睡眠
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# 或者修改systemd配置
sudo nano /etc/systemd/sleep.conf

[Sleep]
# 禁用睡眠
AllowSuspend=no
AllowHibernate=no
AllowSuspendThenHibernate=no
```

### 3. 省电模式优化

#### CPU性能模式设置
```bash
# 安装CPU频率工具
sudo apt install -y cpufrequtils

# 设置性能模式（禁用省电）
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

# 立即应用
sudo systemctl restart cpufrequtils

# 查看当前频率调节器
cpufreq-info
```

#### 禁用不必要的省电功能
```bash
# 禁用USB自动挂起
echo 'USB_AUTOSUSPEND=0' | sudo tee -a /etc/default/tlp

# 禁用无线网卡省电（如果需要）
sudo iwconfig wlan0 power off 2>/dev/null || echo "无线网卡不存在或已关闭"

# 重启TLP应用配置
sudo systemctl restart tlp
```

## 软件包源配置

### 1. 备份原始源配置

#### 备份sources.list
```bash
# 备份原始源列表
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# 备份源目录
sudo cp -r /etc/apt/sources.list.d /etc/apt/sources.list.d.backup

# 查看当前源配置
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/
```

### 2. 配置国内镜像源

#### 检查系统版本
```bash
# 查看Ubuntu版本
lsb_release -a

# 查看codename
lsb_release -cs

# 查看系统信息
uname -a
```

#### 配置阿里云镜像源（推荐）
```bash
# 替换为阿里云源（适用于Ubuntu 20.04 focal）
sudo tee /etc/apt/sources.list > /dev/null << 'EOF'
# 阿里云镜像源
deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
EOF
```

#### 配置清华大学镜像源
```bash
# 清华大学镜像源（备选）
sudo tee /etc/apt/sources.list > /dev/null << 'EOF'
# 清华大学镜像源
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
EOF
```

### 3. 更新软件包缓存

#### 清理并更新
```bash
# 清理旧缓存
sudo apt clean

# 更新包列表
sudo apt update

# 升级已安装的包
sudo apt upgrade -y

# 全系统升级（包括内核）
sudo apt full-upgrade -y
```

#### 验证源配置
```bash
# 检查源是否正常
apt-cache policy

# 测试下载速度
apt-get --print-uris upgrade | head -n 5

# 查看可用包数量
apt list --upgradable | wc -l
```

### 4. 配置自动更新（可选）

#### 安装自动更新工具
```bash
# 安装自动更新
sudo apt install -y unattended-upgrades

# 配置自动更新
sudo dpkg-reconfigure unattended-upgrades

# 手动编辑配置
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

#### 自动更新配置示例
```bash
# 在配置文件中启用以下选项
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
```

## 基础安全配置

### 1. 防火墙配置

#### 安装并启用UFW
```bash
# 安装UFW（通常已预装）
sudo apt install ufw -y

# 查看UFW状态
sudo ufw status verbose

# 设置默认策略
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 允许SSH连接
sudo ufw allow ssh
sudo ufw allow 22/tcp

# 启用防火墙
sudo ufw enable

# 检查防火墙状态
sudo ufw status numbered
```

### 2. 用户安全配置

#### 创建普通用户
```bash
# 创建新用户（如果还没有）
sudo adduser newusername

# 添加到sudo组
sudo usermod -aG sudo newusername

# 查看用户组
groups newusername
```

#### SSH密钥认证配置
```bash
# 创建.ssh目录
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 生成SSH密钥对
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 复制公钥到授权文件
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# 设置正确的权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## 系统更新与维护

### 1. 定期更新脚本

#### 创建维护脚本
```bash
# 创建系统维护脚本
cat > ~/system_maintenance.sh << 'EOF'
#!/bin/bash

# 系统维护脚本
echo "开始系统维护 - $(date)"

# 更新包列表
echo "更新软件包列表..."
sudo apt update

# 升级系统包
echo "升级系统包..."
sudo apt upgrade -y

# 清理不需要的包
echo "清理系统..."
sudo apt autoremove -y
sudo apt autoclean

# 检查磁盘使用
echo "磁盘使用情况:"
df -h

# 检查系统负载
echo "系统负载:"
uptime

echo "系统维护完成 - $(date)"
EOF

# 使脚本可执行
chmod +x ~/system_maintenance.sh

# 测试运行
./system_maintenance.sh
```

### 2. 设置定时任务

#### 配置cron任务
```bash
# 编辑当前用户的crontab
crontab -e

# 添加以下行（每周日凌晨2点自动维护）
0 2 * * 0 /home/ubuntu/system_maintenance.sh >> /var/log/system_maintenance.log 2>&1

# 查看当前crontab
crontab -l
```

## 验证清单

### ✅ SSH服务配置
- [ ] SSH服务安装完成
- [ ] SSH服务正常运行
- [ ] SSH服务开机自启
- [ ] SSH配置文件语法正确
- [ ] SSH密钥交换算法优化
- [ ] 远程连接测试通过

### ✅ 网络工具配置
- [ ] net-tools安装完成（ifconfig可用）
- [ ] 基础网络工具集安装完成
- [ ] 网络接口状态正常
- [ ] DNS解析功能正常
- [ ] 外网连接测试通过

### ✅ 电源管理配置
- [ ] TLP电源管理工具安装
- [ ] 系统自动休眠禁用（服务器环境）
- [ ] systemd-logind配置优化
- [ ] CPU性能模式设置

### ✅ 软件包源配置
- [ ] 原始软件源已备份
- [ ] 国内镜像源配置完成
- [ ] 软件包缓存更新成功
- [ ] 系统包升级完成
- [ ] 软件源下载速度正常

### ✅ 基础安全配置
- [ ] UFW防火墙安装完成
- [ ] 防火墙基础规则配置
- [ ] SSH端口访问已允许
- [ ] 防火墙状态检查正常

### ✅ 系统维护配置
- [ ] 系统维护脚本创建完成
- [ ] 脚本权限配置正确
- [ ] cron定时任务配置（可选）

## 故障排除

### SSH连接问题
```bash
# 检查SSH服务状态
sudo systemctl status ssh

# 检查SSH配置语法
sudo sshd -t

# 查看SSH日志
sudo tail -f /var/log/auth.log

# 重启SSH服务
sudo systemctl restart ssh
```

### 网络问题
```bash
# 检查网络接口
ip addr show

# 检查路由表
ip route show

# 测试DNS
nslookup google.com

# 重启网络服务
sudo systemctl restart networking
```

### 软件源问题
```bash
# 恢复备份源
sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list

# 清理并重新更新
sudo apt clean
sudo apt update

# 修复损坏的包
sudo apt --fix-broken install
```

## 相关链接

### 📚 相关文档
- [002-Docker和Jenkins环境配置](../automation/100-docker-jenkins-dev-env.md)
- [900-SSH连接问题排查](../troubleshooting/900-ssh-connection-issues.md)
- [200-SSH安全加固](../security/200-ssh-hardening.md)

### 🔧 相关脚本
- [001-基础配置脚本](../../scripts/setup/001-basic-setup.sh)
- [系统维护脚本](../../scripts/maintenance/system-update.sh)

### 📖 学习资源
- [Ubuntu官方文档](https://help.ubuntu.com/)
- [OpenSSH配置指南](https://www.ssh.com/ssh/config/)
- [UFW防火墙指南](https://help.ubuntu.com/community/UFW)

## 版本历史

| 版本 | 日期 | 更新内容 | 更新人 |
|------|------|----------|--------|
| 1.0 | 2025-11-05 | 初始版本，包含基础配置步骤 | 系统管理员 |
| 2.0 | 2025-11-05 | 按照规范标准化文档结构，添加验证清单、相关链接、版本历史 | 系统管理员 |

---

**文档状态**: ✅ 已完成
**最后更新**: 2025-11-05
**维护人员**: 系统管理员
**文档质量**: ✅ 已通过质量检查