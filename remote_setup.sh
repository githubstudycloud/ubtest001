#!/bin/bash

# 远程Ubuntu服务器提权配置脚本
# 通过SSH远程执行配置

SERVER_IP="192.168.241.128"
SERVER_USER="ubuntu"
SERVER_PASS="2014"

echo "=== 远程Ubuntu服务器提权配置 ==="
echo "服务器: $SERVER_IP"
echo "用户: $SERVER_USER"
echo

# 创建临时脚本文件
TEMP_SCRIPT="/tmp/setup_ubuntu_sudo_temp.sh"

cat > $TEMP_SCRIPT << 'EOF'
#!/bin/bash

# 远程服务器上执行的脚本
set -e

echo "在服务器 $(hostname) 上执行配置..."

# 检查当前用户
CURRENT_USER=$(whoami)
echo "当前用户: $CURRENT_USER"

# 检查是否已在sudo组中
if groups $CURRENT_USER | grep -q "sudo"; then
    echo "用户 $CURRENT_USER 已在sudo组中"
else
    echo "将用户 $CURRENT_USER 添加到sudo组..."

    # 使用当前用户的sudo权限添加自己到sudo组
    echo "需要输入用户密码..."

    # 方法1: 使用usermod
    if sudo usermod -aG sudo $CURRENT_USER; then
        echo "成功添加到sudo组"
    else
        echo "添加失败，尝试使用adduser..."
        if sudo adduser $CURRENT_USER sudo; then
            echo "成功添加到sudo组"
        else
            echo "无法添加到sudo组"
            exit 1
        fi
    fi
fi

# 验证用户组
echo "当前用户组: $(groups $CURRENT_USER)"

# 配置免密码sudo
echo "配置免密码sudo..."

# 备份sudoers文件
BACKUP_FILE="/etc/sudoers.backup.$(date +%Y%m%d_%H%M%S)"
sudo cp /etc/sudoers $BACKUP_FILE
echo "已备份sudoers文件到: $BACKUP_FILE"

# 检查是否已存在免密码配置
if ! sudo grep -q "$CURRENT_USER.*NOPASSWD" /etc/sudoers; then
    echo "添加免密码sudo配置..."
    echo "$CURRENT_USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

    # 验证语法
    if sudo visudo -c; then
        echo "sudoers配置语法正确"
    else
        echo "sudoers配置语法错误，恢复备份..."
        sudo mv $BACKUP_FILE /etc/sudoers
        exit 1
    fi
else
    echo "免密码sudo配置已存在"
fi

echo
echo "=== 配置完成 ==="
echo "测试免密码sudo..."

# 测试sudo
if sudo whoami; then
    echo "✓ 免密码sudo配置成功！"
else
    echo "✗ 免密码sudo配置失败"
    exit 1
fi

# 测试更多命令
echo "测试更多sudo命令..."
sudo apt update --quiet
echo "✓ apt update 成功"

echo
echo "所有配置已完成！"
echo "用户 $CURRENT_USER 现在具有管理员权限且免密码。"
EOF

# 使脚本可执行
chmod +x $TEMP_SCRIPT

echo "将配置脚本传输到服务器..."

# 使用scp传输脚本
if command -v sshpass &> /dev/null; then
    echo "使用sshpass传输并执行..."
    sshpass -p "$SERVER_PASS" scp -o StrictHostKeyChecking=no $TEMP_SCRIPT $SERVER_USER@$SERVER_IP:/tmp/
    sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "chmod +x /tmp/setup_ubuntu_sudo_temp.sh && /tmp/setup_ubuntu_sudo_temp.sh"
elif command -v expect &> /dev/null; then
    echo "使用expect传输并执行..."
    expect << EOF
spawn scp -o StrictHostKeyChecking=no $TEMP_SCRIPT $SERVER_USER@$SERVER_IP:/tmp/
    expect "password:"
    send "$SERVER_PASS\r"
    expect eof

spawn ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "chmod +x /tmp/setup_ubuntu_sudo_temp.sh && /tmp/setup_ubuntu_sudo_temp.sh"
    expect "password:"
    send "$SERVER_PASS\r"
    expect eof
EOF
else
    echo "请手动执行以下步骤："
    echo
    echo "1. 连接到服务器:"
    echo "   ssh $SERVER_USER@$SERVER_IP"
    echo "   密码: $SERVER_PASS"
    echo
    echo "2. 复制并执行以下脚本:"
    cat $TEMP_SCRIPT
    echo
    echo "3. 或者将脚本文件传输到服务器后执行:"
    echo "   scp $TEMP_SCRIPT $SERVER_USER@$SERVER_IP:/tmp/"
    echo "   ssh $SERVER_USER@$SERVER_IP 'chmod +x /tmp/setup_ubuntu_sudo_temp.sh && /tmp/setup_ubuntu_sudo_temp.sh'"
fi

# 清理临时文件
rm -f $TEMP_SCRIPT

echo
echo "=== 本地操作完成 ==="
echo "请检查远程服务器的执行结果。"