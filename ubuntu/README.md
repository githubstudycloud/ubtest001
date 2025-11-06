# Ubuntu服务器操作指南

## 🎯 项目概述

这是一个完整的Ubuntu服务器管理指南，包含系统配置、安全设置、网络配置、自动化脚本等全方位内容。项目采用模块化设计，支持不同环境和配置需求。

## 🔐 快速开始

### 1. 环境配置
```bash
# 复制配置模板
cp .env.example .env

# 编辑配置文件（填入实际的服务器信息）
nano .env
```

### 2. 一键配置（推荐）
```bash
# 使用自动化脚本配置新服务器
cd scripts/setup/
chmod +x setup-ubuntu-server.sh
./setup-ubuntu-server.sh
```

### 3. 手动配置
```bash
# 按照文档逐步配置
cat docs/basics/001-ubuntu-basic-system-configuration.md
```

## 📚 文档导航

### 🎯 基础配置 (docs/basics/)
- [001-ubuntu-basic-system-configuration.md](docs/basics/001-ubuntu-basic-system-configuration.md) - 系统基础配置指南

### 🌐 网络配置 (docs/network/)
- [010-ssh-configuration.md](docs/network/010-ssh-configuration.md) - SSH服务配置 (计划中)
- [011-network-tools.md](docs/network/011-network-tools.md) - 网络工具安装 (计划中)

### 🔒 安全配置 (docs/security/)
- [020-sudo-configuration.md](docs/security/020-sudo-configuration.md) - sudo权限配置 (计划中)

### 🔧 脚本工具 (scripts/)
- [setup/](scripts/setup/) - 安装配置脚本
- [security/](scripts/security/) - 安全相关脚本
- [maintenance/](scripts/maintenance/) - 系统维护脚本

### 📜 历史记录 (history/)
- [2024/11-november/](history/2024/11-november/) - 近期问题排查记录

## 🗂️ 目录结构

```
ubuntu/
├── README.md                    # 项目总览
├── DIRECTORY_MAPPING.md         # 目录映射向导
├── .env.example                 # 配置模板 ⚠️
├── .gitignore                   # Git忽略规则
├── docs/                        # 📚 文档
│   ├── basics/                  # 基础配置
│   ├── network/                 # 网络配置
│   ├── security/                # 安全配置
│   └── troubleshooting/          # 故障排除
├── scripts/                     # 🔧 自动化脚本
│   ├── setup/                   # 安装配置
│   ├── security/                # 安全脚本
│   └── maintenance/             # 维护脚本
├── config/                      # ⚙️ 配置模板
├── examples/                    # 💡 使用示例
├── history/                     # 📜 历史记录
└── tools/                       # 🛠️ 辅助工具
```

## 🚀 快速命令参考

### SSH连接
```bash
# 使用环境变量配置连接
ssh -o KexAlgorithms=${SSH_KEX_ALGORITHM} ${UBUNTU_SERVER_USER}@${UBUNTU_SERVER_IP}

# 具体示例（需要先配置.env文件）
ssh -o KexAlgorithms=curve25519-sha256@libssh.org ubuntu@192.168.241.128
```

### MCP工具使用
```bash
# 执行服务器命令
mcp__mcp-ubuntu__exec "sudo <command>"

# 查看系统状态
mcp__mcp-ubuntu__exec "systemctl status ssh"
```

### 脚本执行
```bash
# 主配置脚本
cd scripts/setup/
./setup-ubuntu-server.sh

# 安全配置脚本
cd scripts/security/
./setup-ubuntu-sudo.sh

# 验证配置
./verify-sudo-config.sh
```

## 📊 项目状态

### ✅ 已完成配置

| 功能 | 状态 | 描述 |
|------|------|------|
| SSH服务配置 | ✅ 完成 | 兼容性算法配置，开机自启 |
| sudo权限配置 | ✅ 完成 | 免密码sudo权限 |
| 网络工具安装 | ✅ 完成 | ifconfig等基础网络工具 |
| 基础安全配置 | ✅ 完成 | UFW防火墙基础配置 |
| 环境变量管理 | ✅ 完成 | 安全配置管理系统 |

### 🔄 进行中

| 任务 | 状态 | 负责人 |
|------|------|--------|
| 文档结构重组 | ✅ 完成 | 系统 |
| 脚本路径更新 | ✅ 完成 | 系统 |
| 目录映射向导 | ✅ 完成 | 系统 |

### 📅 计划中

| 任务 | 优先级 | 预计完成 |
|------|--------|----------|
| Docker配置 | 高 | 2024-12 |
| Web服务器配置 | 中 | 2025-01 |
| 数据库配置 | 中 | 2025-01 |
| 监控系统 | 低 | 2025-02 |

## 🔧 故障排查

### 常见问题

**Q: SSH连接失败**
A: 参考 [历史故障记录](history/2024/11-november/ssh-troubleshooting-report.md)

**Q: sudo权限问题**
A: 运行 [验证脚本](scripts/security/verify-sudo-config.sh)

**Q: 脚本执行错误**
A: 检查环境变量配置和文件权限

### 获取帮助

1. 查看 [目录映射向导](DIRECTORY_MAPPING.md) 了解文件结构
2. 检查 [历史记录](history/) 查看类似问题
3. 使用 [示例文件](examples/) 作为参考

## 🛡️ 安全说明

⚠️ **重要安全提醒**:

- ✅ 所有敏感信息使用环境变量管理
- ✅ `.env` 文件已在 `.gitignore` 中配置，不会被提交
- ✅ 脚本中无硬编码密码或IP地址
- ✅ 配置文件使用模板，避免敏感信息泄露

### 安全检查清单
- [ ] 确认 `.env` 文件不被Git跟踪
- [ ] 验证脚本中的环境变量使用
- [ ] 检查配置文件中的敏感信息处理

## 🤝 贡献指南

### 添加新内容

1. **确定分类**: 根据 [目录映射向导](DIRECTORY_MAPPING.md) 选择合适位置
2. **遵循规范**: 使用统一的命名和格���规范
3. **更新索引**: 在相关README中添加链接
4. **测试验证**: 确保所有链接和脚本正常工作

### 文档规范

- 使用Markdown格式
- 中文描述，英文文件名
- 包含使用示例和故障排除
- 保持与现有风格一致

## 📞 联系方式

### 维护信息

- **项目负责人**: 系统管理员
- **创建时间**: 2025-11-05
- **最后更新**: 2025-11-05
- **版本**: 1.0

### 技术支持

- 📖 文档问题: 检查相关目录下的README文件
- 🔧 脚本问题: 查看 `scripts/` 目录下的使用说明
- 🐛 Bug报告: 检查 `history/` 目录下的类似问题

---

## 📄 许可证

本项目采用开源许可证，详情请查看 LICENSE 文件。

---

**感谢使用Ubuntu服务器操作指南！** 🚀

*如果您觉得这个项目有用，请给个Star支持一下！*