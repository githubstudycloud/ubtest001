# Ubuntu操作指南文档库

## 🔐 安全配置说明

**重要**: 本项目使用环境变量管理敏感信息。请在使用前完成配置：

```bash
# 1. 复制配置模板
cp .env.example .env

# 2. 编辑配置文件，填入实际值
nano .env

# 3. 确保.env文件不被提交到Git（已在.gitignore中配置）
```

## 📚 文档目录

### 🗂️ 目录结构
```
ubuntu_docs/
├── README.md                                    # 文档索引（当前文件）
├── 001-ubuntu-basic-system-configuration.md    # 基础系统配置指南
├── completion-summary.md                       # 项目完成总结
├── tmp/                                         # 临时/历史文档
│   ├── ubuntu_sudo_setup_guide.md
│   ├── ssh_troubleshooting_report.md
│   ├── ssh_solution_with_existing_key.md
│   ├── connection_test_results.md
│   └── sudo_configuration_success_report.md
└── scripts/                                     # 自动化脚本
    └── setup-ubuntu-server.sh                  # 一键配置脚本
```

### ⚙️ 配置文件
- `.env.example` - 配置文件模板（安全）
- `.env` - 实际配置文件（敏感，不提交到Git）
- `.gitignore` - Git忽略文件配置

### 📖 文档说明

#### 主要文档

| 编号 | 文档名称 | 描述 | 状态 |
|------|----------|------|------|
| 001 | Ubuntu基础系统配置指南 | SSH安装配置、网络工具、电源管理、软件源配置 | ✅ 已完成 |

#### 历史文档 (tmp/)

| 文档名称 | 描述 | 备注 |
|----------|------|------|
| ubuntu_sudo_setup_guide.md | 详细的sudo配置操作指南 | 历史文档，内容已整合到001 |
| ssh_troubleshooting_report.md | SSH连接问题诊断报告 | 问题分析记录 |
| ssh_solution_with_existing_key.md | 使用现有RSA密钥的SSH解决方案 | 解决方案记录 |
| connection_test_results.md | SSH连接测试结果报告 | 测试结果记录 |
| sudo_configuration_success_report.md | sudo配置成功报告 | 任务完成总结 |

### 🎯 快速开始

#### 1. 新系统首次配置
如果你刚安装好Ubuntu服务器，请按以下步骤操作：

```bash
# 1. 配置环境变量（首次使用）
cp .env.example .env
nano .env  # 填入服务器IP、用户名、密码等信息

# 2. 使用自动化脚本（推荐）
cd ubuntu_docs/scripts
chmod +x setup-ubuntu-server.sh
./setup-ubuntu-server.sh

# 3. 或手动按照文档配置
cat 001-ubuntu-basic-system-configuration.md
```

#### 2. SSH连接问题排查
如果遇到SSH连接问题，参考历史文档：

```bash
# 查看SSH问题诊断
cat tmp/ssh_troubleshooting_report.md

# 查看解决方案
cat tmp/ssh_solution_with_existing_key.md
```

#### 3. sudo权限配置
如果需要配置sudo权限，参考：

```bash
# 查看sudo配置成功报告
cat tmp/sudo_configuration_success_report.md
```

### 🔧 当前服务器状态

#### 服务器信息
- **IP地址**: `${UBUNTU_SERVER_IP}` (定义在.env文件中)
- **用户**: `${UBUNTU_SERVER_USER}` (默认ubuntu)
- **SSH连接**: 使用 `${SSH_KEX_ALGORITHM}` 算法
- **连接方式**:
  ```bash
  ssh -o KexAlgorithms=${SSH_KEX_ALGORITHM} ${UBUNTU_SERVER_USER}@${UBUNTU_SERVER_IP}
  ```

#### 已完成的配置
- ✅ SSH服务配置（兼容性算法）
- ✅ ubuntu用户sudo免密码权限
- ✅ MCP工具连接正常
- ⏳ 基础系统配置（待执行）

### 🚀 下一步计划

#### 待创建的文档

| 编号 | 计划主题 | 优先级 |
|------|----------|--------|
| 002 | Docker容器配置 | 高 |
| 003 | Web服务器配置(Nginx/Apache) | 中 |
| 004 | 数据库配置(MySQL/PostgreSQL) | 中 |
| 005 | 防火墙安全配置 | 高 |
| 006 | 备份策略配置 | 中 |
| 007 | 监控系统配置 | 低 |

#### 自动化脚本

计划创建以下自动化脚本：

1. **setup-ubuntu-server.sh** - 一键服务器初始化
2. **install-docker.sh** - Docker环境安装
3. **setup-firewall.sh** - 防火墙配置脚本
4. **backup-system.sh** - 系统备份脚本

### 📋 使用建议

#### 文档使用流程
1. **新系统**: 阅读并执行001号文档
2. **问题排查**: 参考tmp目录中的历史文档
3. **日常维护**: 按照001号文档中的维护章节执行

#### MCP工具使用
当前MCP工具已配置完成，可直接使用：

```bash
# 执行系统命令
mcp__mcp-ubuntu__exec "sudo <command>"

# 查看系统状态
mcp__mcp-ubuntu__exec "systemctl status <service>"

# 安装软件包
mcp__mcp-ubuntu__exec "sudo apt install <package>"
```

#### 文档更新规则
- 每个配置完成后更新对应验证清单
- 遇到问题时创建新的排查记录到tmp目录
- 定期整理tmp目录，将有用内容整合到主要文档

### 🔗 相关链接

#### 官方文档
- [Ubuntu官方文档](https://help.ubuntu.com/)
- [OpenSSH配置指南](https://www.ssh.com/ssh/config/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

#### 工具文档
- [MCP工具使用指南](https://docs.claude.com/)
- [VMware网络配置](https://docs.vmware.com/)

---

**文档库版本**: 1.0
**最后更新**: 2025-11-05
**维护者**: 系统管理员

## 💡 贡献指南

如果你有改进建议或发现文档错误：

1. 在对应文档中添加改进建议
2. 创建新的测试记录
3. 更新README索引

所有改进都应该：
- 保持命令的完整性和可复制性
- 包含详细的验证步骤
- 添加故障排除指南