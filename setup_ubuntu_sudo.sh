#!/bin/bash

# Ubuntu用户提权到管理组自动化脚本
# 目标服务器: 192.168.241.128
# 用户: ubuntu, 密码: 2014

set -e  # 遇到错误立即退出

echo "=== Ubuntu用户提权配置脚本 ==="
echo "目标服务器: 192.168.241.128"
echo "用户: ubuntu"
echo

# 检查是否为root用户运行
if [ "$EUID" -eq 0 ]; then
    echo "请不要以root用户运行此脚本"
    exit 1
fi

# 检查当前用户
CURRENT_USER=$(whoami)
echo "当前用户: $CURRENT_USER"

# 如果已经是ubuntu用户且在sudo组中，直接配置免密码
if [ "$CURRENT_USER" = "ubuntu" ] && groups $CURRENT_USER | grep -q "sudo"; then
    echo "检测到用户ubuntu已在sudo组中，配置免密码sudo..."

    # 备份原sudoers文件
    sudo cp /etc/sudoers /etc/sudoers.backup.$(date +%Y%m%d_%H%M%S)

    # 检查是否已存在免密码配置
    if ! sudo grep -q "$CURRENT_USER.*NOPASSWD" /etc/sudoers; then
        echo "添加免密码sudo配置..."
        echo "$CURRENT_USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
    else
        echo "免密码sudo配置已存在"
    fi

    echo "配置完成！测试免密码sudo..."
    sudo whoami
    echo "成功！"
    exit 0
fi

# 如果不是ubuntu用户，尝试添加到sudo组
echo "将用户 $CURRENT_USER 添加到sudo组..."

# 检查用户是否已在sudo组中
if groups $CURRENT_USER | grep -q "sudo"; then
    echo "用户 $CURRENT_USER 已在sudo组中"
else
    # 尝试添加用户到sudo组
    if command -v sudo &> /dev/null; then
        echo "使用sudo添加用户到sudo组..."
        echo "需要输入当前用户密码..."

        # 方法1: 尝试使用sudo
        if sudo usermod -aG sudo $CURRENT_USER 2>/dev/null; then
            echo "成功将用户添加到sudo组"
        else
            echo "无法使用sudo，尝试其他方法..."
            exit 1
        fi
    else
        echo "当前系统没有sudo命令或用户无权限"
        exit 1
    fi
fi

# 配置免密码sudo
echo "配置免密码sudo..."

# 备份sudoers文件
sudo cp /etc/sudoers /etc/sudoers.backup.$(date +%Y%m%d_%H%M%S)

# 检查语法并添加配置
echo "$CURRENT_USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# 验证sudoers文件语法
if sudo visudo -c; then
    echo "sudoers配置语法正确"
else
    echo "sudoers配置语法错误，恢复备份..."
    sudo mv /etc/sudoers.backup.$(date +%Y%m%d_%H%M%S) /etc/sudoers
    exit 1
fi

echo
echo "=== 配置完成 ==="
echo "用户 $CURRENT_USER 已添加到sudo组"
echo "已配置免密码sudo"
echo
echo "请重新登录以使权限生效:"
echo "  exit"
echo "  ssh ubuntu@192.168.241.128"
echo
echo "然后测试:"
echo "  sudo whoami"
echo "  sudo apt update"