#!/bin/bash

# 验证sudo配置的脚本
# 用于测试ubuntu用户的sudo权限

echo "=== Ubuntu用户sudo权限验证脚本 ==="
echo

# 检查当前环境
echo "1. 检查当前用户环境"
echo "   当前用户: $(whoami)"
echo "   主机名: $(hostname)"
echo "   用户ID: $(id -u)"
echo "   用户组: $(groups)"
echo

# 检查sudo命令是否可用
echo "2. 检查sudo命令"
if command -v sudo &> /dev/null; then
    echo "   ✓ sudo命令已安装"
    echo "   sudo版本: $(sudo --version | head -n1)"
else
    echo "   ✗ sudo命令未安装"
    exit 1
fi
echo

# 检查用户是否在sudo组中
echo "3. 检查sudo组成员"
if groups $(whoami) | grep -q "sudo"; then
    echo "   ✓ 当前用户在sudo组中"
else
    echo "   ✗ 当前用户不在sudo组中"
    echo "   请先运行: sudo usermod -aG sudo $(whoami)"
fi
echo

# 检查sudoers配置
echo "4. 检查sudoers配置"
if sudo grep -q "$(whoami).*NOPASSWD" /etc/sudoers 2>/dev/null; then
    echo "   ✓ 发现免密码sudo配置"
    echo "   配置行: $(sudo grep "$(whoami).*NOPASSWD" /etc/sudoers)"
else
    echo "   - 未发现免密码sudo配置（需要密码）"
fi
echo

# 测试sudo权限
echo "5. 测试sudo权限"

echo "   测试基本sudo命令..."
if timeout 10 sudo whoami &>/dev/null; then
    SUDO_USER=$(sudo whoami)
    if [ "$SUDO_USER" = "root" ]; then
        echo "   ✓ 基本sudo命令成功 (sudo whoami = root)"
    else
        echo "   ✗ sudo命令异常 (返回: $SUDO_USER)"
    fi
else
    echo "   ✗ 基本sudo命令失败"
    echo "   可能原因:"
    echo "     - 用户不在sudo组中"
    echo "     - 需要输入密码"
    echo "     - sudo配置错误"
fi

echo "   测试免密码sudo..."
if timeout 10 -S sudo whoami < /dev/null &>/dev/null; then
    NOPASSWD_USER=$(timeout 10 -S sudo whoami < /dev/null)
    if [ "$NOPASSWD_USER" = "root" ]; then
        echo "   ✓ 免密码sudo成功"
    else
        echo "   ✗ 免密码sudo异常 (返回: $NOPASSWD_USER)"
    fi
else
    echo "   - 免密码sudo未配置或失败（需要密码）"
fi
echo

# 测试常用管理员命令
echo "6. 测试常用管理员命令"

commands=("apt --version" "systemctl --version" "docker --version" "ls /root")

for cmd in "${commands[@]}"; do
    echo "   测试: sudo $cmd"
    if timeout 10 sudo bash -c "$cmd" &>/dev/null; then
        echo "   ✓ 成功"
    else
        echo "   - 失败或命令不存在"
    fi
done
echo

# 检查sudo日志
echo "7. 检查sudo日志"
if [ -f /var/log/auth.log ]; then
    echo "   检查最近的sudo使用记录..."
    recent_sudo=$(sudo grep "sudo:" /var/log/auth.log | tail -n 3 2>/dev/null || echo "无记录或权限不足")
    echo "   最近记录: $recent_sudo"
elif [ -f /var/log/secure ]; then
    echo "   检查最近的sudo使用记录..."
    recent_sudo=$(sudo grep "sudo:" /var/log/secure | tail -n 3 2>/dev/null || echo "无记录或权限不足")
    echo "   最近记录: $recent_sudo"
else
    echo "   - 未找到sudo日志文件"
fi
echo

# 总结
echo "=== 验证总结 ==="

# 统计成功项目
success_count=0
total_tests=7

if groups $(whoami) | grep -q "sudo"; then
    ((success_count++))
fi

if sudo grep -q "$(whoami).*NOPASSWD" /etc/sudoers 2>/dev/null; then
    ((success_count++))
fi

if timeout 10 sudo whoami &>/dev/null; then
    ((success_count++))
fi

if timeout 10 -S sudo whoami < /dev/null &>/dev/null; then
    ((success_count++))
fi

echo "测试通过: $success_count/$total_tests"
echo

if [ $success_count -ge 3 ]; then
    echo "✓ sudo配置基本正常"
    if [ $success_count -eq 4 ]; then
        echo "✓ 免密码sudo配置完美"
    else
        echo "- 建议配置免密码sudo以提高便利性"
    fi
else
    echo "✗ sudo配置存在问题，请检查:"
    echo "  1. 用户是否在sudo组中"
    echo "  2. sudoers文件配置是否正确"
    echo "  3. 是否需要重新登录"
fi

echo
echo "推荐的修复命令:"
echo "  sudo usermod -aG sudo \$(whoami)     # 添加到sudo组"
echo "  sudo visudo                          # 编辑sudoers文件"
echo "  newgrp sudo                          # 刷新用户组权限"
echo "  exit && ssh ubuntu@192.168.241.128  # 重新登录"