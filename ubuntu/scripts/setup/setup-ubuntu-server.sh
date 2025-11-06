#!/bin/bash

# Ubuntu服务器基础配置自动化脚本
# 基于文档001: Ubuntu基础系统配置指南
#
# 使用方法:
#   1. 复制 .env.example 为 .env 并配置实际值
#   2. chmod +x setup-ubuntu-server.sh
#   3. ./setup-ubuntu-server.sh

set -e  # 遇到错误立即退出

# 加载环境变量配置
if [ -f "../../../.env" ]; then
    source "../../../.env"
else
    echo "错误: 未找到 .env 配置文件，请从 .env.example 复制并配置"
    exit 1
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否以root权限运行
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_info "检查sudo权限..."
        if ! sudo -n true 2>/dev/null; then
            log_info "需要sudo权限，请输入密码"
        fi
    else
        log_warning "检测到以root用户运行，建议使用普通用户"
    fi
}

# 1. SSH服务安装与配置
setup_ssh() {
    log_info "开始SSH服务配置..."

    # 检查SSH服务状态
    if systemctl is-active --quiet ssh; then
        log_info "SSH服务已在运行"
    else
        log_info "启动SSH服务..."
        sudo systemctl start ssh
    fi

    # 设置SSH开机自启
    if ! systemctl is-enabled --quiet ssh; then
        log_info "设置SSH服务开机自启..."
        sudo systemctl enable ssh
    fi

    # 备份SSH配置文件
    if [ ! -f /etc/ssh/sshd_config.backup ]; then
        log_info "备份SSH配置文件..."
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    fi

    # 优化SSH配置（添加兼容性算法）
    log_info "优化SSH配置以提高兼容性..."
    sudo tee -a /etc/ssh/sshd_config > /dev/null << 'EOF'

# 兼容性配置（自动添加）
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,diffie-hellman-group-exchange-sha256
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com
MACs hmac-sha2-256,hmac-sha2-512,umac-128@openssh.com
EOF

    # 验证SSH配置语法
    if sudo sshd -t; then
        log_success "SSH配置语法正确"
        sudo systemctl reload ssh
    else
        log_error "SSH配置语法错误，跳过重载"
        return 1
    fi

    log_success "SSH服务配置完成"
}

# 2. 网络工具安装
setup_network_tools() {
    log_info "开始安装网络工具..."

    # 更新包列表
    log_info "更新软件包列表..."
    sudo apt update

    # 安装基础网络工具
    log_info "安装net-tools（包含ifconfig）..."
    sudo apt install -y net-tools

    # 安装完整的网络工具集
    log_info "安装完整���络工具集..."
    sudo apt install -y \
        iproute2 \
        inetutils-traceroute \
        dnsutils \
        curl \
        wget

    # 验证ifconfig命令
    if command -v ifconfig &> /dev/null; then
        log_success "ifconfig命令安装成功"
        log_info "网络接口信息:"
        ifconfig -a | head -n 20
    else
        log_error "ifconfig命令安装失败"
        return 1
    fi

    log_success "网络工具安装完成"
}

# 3. 电源管理与屏幕配置
setup_power_management() {
    log_info "开始配置电源管理..."

    # 安装电源管理工具
    log_info "安装电源管理工具..."
    sudo apt install -y tlp tlp-rdw powertop

    # 启动TLP服务
    sudo systemctl enable tlp
    sudo systemctl start tlp

    # 禁用系统自动睡眠（服务器环境）
    log_info "配置系统不自动睡眠..."
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true

    # 配置systemd-logind
    if [ -f /etc/systemd/logind.conf ]; then
        log_info "配置systemd-logind..."
        sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
        sudo sed -i 's/#HandleLidSwitchDocked=suspend/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf
        sudo systemctl restart systemd-logind
    fi

    log_success "电源管理配置完成"
}

# 4. 软件包源配置
setup_package_sources() {
    log_info "开始配置软件包源..."

    # 检测Ubuntu版本
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        CODENAME=$VERSION_CODENAME
        log_info "检测到Ubuntu版本: $PRETTY_NAME ($CODENAME)"
    else
        log_error "无法检测Ubuntu版本"
        return 1
    fi

    # 备份原始源配置
    if [ ! -f /etc/apt/sources.list.backup ]; then
        log_info "备份原始软件源配置..."
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
    fi

    # 配置阿里云镜像源
    log_info "配置阿里云镜像源..."
    sudo tee /etc/apt/sources.list > /dev/null << EOF
# 阿里云镜像源 - Ubuntu $CODENAME
deb https://mirrors.aliyun.com/ubuntu/ $CODENAME main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME-updates main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME-backports main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ $CODENAME-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ $CODENAME-security main restricted universe multiverse
EOF

    # 更新软件包缓存
    log_info "更新软件包缓存..."
    sudo apt update

    # 升级系统包
    log_info "升级系统包..."
    sudo apt upgrade -y

    log_success "软件包源配置完成"
}

# 5. 基础安全配置
setup_security() {
    log_info "开始基础安全配置..."

    # 安装并配置UFW防火墙
    if command -v ufw &> /dev/null; then
        log_info "配置UFW防火墙..."

        # 设置默认策略
        sudo ufw --force reset
        sudo ufw default deny incoming
        sudo ufw default allow outgoing

        # 允许SSH连接
        sudo ufw allow ssh
        sudo ufw allow ${SSH_PORT}/tcp

        # 启用防火墙
        sudo ufw --force enable

        log_success "UFW防火墙配置完成"
        sudo ufw status verbose
    else
        log_warning "UFW未安装，跳过防火墙配置"
    fi

    log_success "基础安全配置完成"
}

# 6. 创建系统维护脚本
create_maintenance_script() {
    log_info "创建系统维护脚本..."

    cat > /home/ubuntu/system_maintenance.sh << 'EOF'
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

    chmod +x /home/${UBUNTU_SERVER_USER}/system_maintenance.sh
    chown ${UBUNTU_SERVER_USER}:${UBUNTU_SERVER_USER} /home/${UBUNTU_SERVER_USER}/system_maintenance.sh

    log_success "系统维护脚本创建完成: /home/${UBUNTU_SERVER_USER}/system_maintenance.sh"
}

# 7. 验证配置
verify_configuration() {
    log_info "开始验证配置..."

    # 验证SSH服务
    if systemctl is-active --quiet ssh; then
        log_success "✅ SSH服务运行正常"
    else
        log_error "❌ SSH服务未运行"
    fi

    # 验证网络工具
    if command -v ifconfig &> /dev/null; then
        log_success "✅ ifconfig命令可用"
    else
        log_error "❌ ifconfig命令不可用"
    fi

    # 验证防火墙
    if command -v ufw &> /dev/null && sudo ufw status | grep -q "Status: active"; then
        log_success "✅ UFW防火墙已启用"
    else
        log_warning "⚠️  UFW防火墙未启用或未安装"
    fi

    # 验证sudo权限
    if sudo -n true 2>/dev/null || echo "${UBUNTU_SERVER_PASSWORD}" | sudo -S true &>/dev/null; then
        log_success "✅ sudo权限正常"
    else
        log_error "❌ sudo权限配置有问题"
    fi

    log_success "配置验证完成"
}

# 主函数
main() {
    log_info "开始Ubuntu服务器基础配置..."
    log_info "脚本版本: 1.0"
    log_info "基于文档: 001-ubuntu-basic-system-configuration.md"
    echo

    # 检查权限
    check_root

    # 执行配置步骤
    setup_ssh
    echo
    setup_network_tools
    echo
    setup_power_management
    echo
    setup_package_sources
    echo
    setup_security
    echo
    create_maintenance_script
    echo
    verify_configuration
    echo

    log_success "🎉 Ubuntu服务器基础配置完成！"
    echo
    log_info "配置摘要:"
    log_info "- SSH服务: 已配置并启用"
    log_info "- 网络工具: ifconfig等工具已安装"
    log_info "- 电源管理: 服务器模式配置"
    log_info "- 软件源: 阿里云镜像源"
    log_info "- 安全配置: UFW防火墙已启用"
    log_info "- 维护脚本: /home/${UBUNTU_SERVER_USER}/system_maintenance.sh"
    echo
    log_info "建议后续操作:"
    log_info "1. 重启服务器确保所有配置生效"
    log_info "2. 定期运行维护脚本: /home/${UBUNTU_SERVER_USER}/system_maintenance.sh"
    log_info "3. 查看详细文档: ubuntu_docs/001-ubuntu-basic-system-configuration.md"
}

# 检查是否直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi