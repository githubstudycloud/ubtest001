# Ubuntu服务器操作指南

## 文档信息
- **项目名称**: Ubuntu服务器操作指南
- **版本**: 2.0
- **状态**: ✅ 已完成
- **创建日期**: 2025-11-05
- **最后更新**: 2025-11-05
- **作者**: 系统管理员
- **适用环境**: Ubuntu 20.04/22.04/25.04 LTS
- **文档数量**: 15+
- **维护状态**: ✅ 活跃维护

## 🎯 项目概述

这是一个完整的Ubuntu服务器管理指南，采用模块化设计，包含系统配置、自动化部署、安全设置、开发环境配置、故障排除等全方位内容。项目遵循专业的文档编写规范，提供清晰的结构导航和标准化的内容格式。

## 🔐 安全配置

**重要**: 本项目使用环境变量管理敏感信息。请在使用前完成配置：

```bash
# 1. 复制配置模板
cp .env.example .env

# 2. 编辑配置文件（填入实际的服务器信息）
nano .env

# 3. 确保.env文件不被提交到Git（已在.gitignore中配置）
```

## 🚀 快速开始

### 1. 环境配置
```bash
# 复制环境变量配置
cp .env.example .env

# 编辑配置文件，填入实际值
nano .env
```

### 2. 一键配置（推荐）
```bash
# 使用自动化脚本配置新服务器
cd scripts/setup/
chmod +x 001-basic-setup.sh
./001-basic-setup.sh
```

### 3. 手动配置
```bash
# 按照文档逐步配置
cat docs/basics/001-ubuntu-basic-system-standardized.md
```

## 📚 文档导航

### 🎯 基础配置 (docs/basics/) - 服务器初始化

| 编号 | 文档名称 | 描述 | 状态 | 预计耗时 |
|------|----------|------|------|----------|
| 001 | Ubuntu基础系统配置指南 | SSH、网络、电源管理、软件源、安全配置 | ✅ 完成 | 30-60分钟 |
| 002 | 用户和权限管理 | 用户创建、sudo配置、权限管理 | 📝 计划中 | 15-30分钟 |
| 003 | 网络高级配置 | 静态IP、DNS配置、高级网络设置 | 📝 计划中 | 20-40分钟 |

**导航链接**: [基础配置文档中心](docs/basics/README.md)

### 🤖 自动化配置 (docs/automation/) - 容器化和CI/CD

| 编号 | 文档名称 | 描述 | 状态 | 预计耗时 |
|------|----------|------|------|----------|
| 100 | Docker和Jenkins环境配置 | Docker、Jenkins、Python、Go、Java、Node.js | ✅ 完成 | 60-90分钟 |
| 101 | Docker容器管理 | Docker Compose、Swarm、容器编排 | 📝 计划中 | 30-45分钟 |
| 102 | Kubernetes入门 | K8s基础、Pod管理、Service配置 | 📝 计划中 | 45-60分钟 |

**导航链接**: [自动化配置文档中心](docs/automation/README.md)

### 🔧 故障排除 (docs/troubleshooting/) - 问题诊断与解决

| 编号 | 文档名称 | 描述 | 状态 | 难度 |
|------|----------|------|------|------|
| 900 | SSH连接问题排查 | SSH连接失败、认证问题、网络问题 | ✅ 完成 | 中级 |
| 901 | Docker问题诊断 | Docker安装、运行、网络问题 | 📝 计划中 | 中级 |
| 902 | 网络连接故障排查 | 网络配置、DNS、防火墙问题 | 📝 计划中 | 初级 |

**导航链接**: [故障排除文档中心](docs/troubleshooting/README.md)

### 📖 指南和规范 (docs/guides/) - 写作规范和最佳实践

| 文档名称 | 描述 | 状态 | 用途 |
|----------|------|------|------|
| Markdown编写规范指南 | 完整的文档编写规范 | ✅ 完成 | 文档编写标准 |
| 文档重构计划 | 解决文件散乱问题的计划 | ✅ 完成 | 项目结构优化 |
| 快速参考卡片 | Markdown语法速查 | ✅ 完成 | 快速查阅 |

### 🔧 脚本工具 (scripts/)

#### 安装配置脚本 (scripts/setup/)
- [001-basic-setup.sh](scripts/setup/001-basic-setup.sh) - 基础系统配置脚本
- [100-docker-jenkins-dev-env.sh](scripts/setup/100-docker-jenkins-dev-env.sh) - Docker和开发环境配置

#### 系统维护脚本 (scripts/maintenance/)
- [system-update.sh](scripts/maintenance/system-update.sh) - 系统更新和维护

#### 安全脚本 (scripts/security/)
- [ssh-setup.sh](scripts/security/ssh-setup.sh) - SSH安全配置
- [firewall-setup.sh](scripts/security/firewall-setup.sh) - 防火墙配置

### 💡 使用示例 (examples/)

- [快速开始](examples/quick-start/) - 新用户入门示例
- [使用场景](examples/use-cases/) - 具体应用场景
- [模板文件](examples/templates/) - 配置文件模板

### 📜 历史记录 (history/)

- [2024/11-november/](history/2024/11-november/) - 最近的配置和问题记录

## 🗂️ 目录结构

```
ubuntu/
├── README.md                    # 项目总览（当前文件）
├── README-standardized.md       # 标准化项目总览
├── DIRECTORY_MAPPING.md         # 目录映射向导
├── .env.example                 # 配置文件模板
├── .gitignore                   # Git忽略规则
├── CHANGELOG.md                  # 变更日志
├── docs/                        # 📚 文档主目录
│   ├── guides/                  # 📖 指南和规范
│   ├── basics/                  # 🎯 基础配置 (001-099)
│   ├── automation/              # 🤖 自动化 (100-199)
│   ├── security/               # 🔒 安全配置 (200-299)
│   ├── troubleshooting/          # 🔧 故障排除 (900-999)
│   └── summaries/               # 📊 总结报告
├── scripts/                     # 🔧 脚本目录
│   ├── setup/                   # 🚀 安装配置
│   ├── maintenance/             # 🔧 维护脚本
│   ├── security/                # 🔒 安全脚本
│   └── utils/                   # 🛠️ 实用工具
├── examples/                    # 💡 示例和演示
│   ├── quick-start/             # 快速开始
│   ├── use-cases/               # 使用场景
│   └── templates/               # 模板文件
└── history/                     # 📜 历史记录
    └── 2024/11-november/        # 按月份归档
```

## 🛠️ 脚本工具使用指南

### 配置脚本使用

```bash
# 基础系统配置
cd scripts/setup/
chmod +x 001-basic-setup.sh
./001-basic-setup.sh

# Docker和开发环境配置
cd scripts/setup/
chmod +x 100-docker-jenkins-dev-env.sh
./100-docker-jenkins-dev-env.sh
```

### MCP工具使用

```bash
# 执行服务器命令
mcp__mcp-ubuntu__exec "sudo <command>"

# 查看系统状态
mcp__mcp-ubuntu__exec "systemctl status <service>"

# 安装软件包
mcp__mcp-ubuntu__exec "sudo apt install <package>"
```

## 📊 项目状态

### ✅ 已完成配置

| 功能 | 状态 | 描述 |
|------|------|------|
| 文档结构重组 | ✅ 完成 | 按功能分类的清晰结构 |
| 编写规范制定 | ✅ 完成 | 统一的文档编写标准 |
| 环境变量管理 | ✅ 完成 | 安全的敏感信息管理 |
| SSH服务配置 | ✅ 完成 | 兼容性算法配置 |
| Docker环境配置 | ✅ 完成 | 容器化开发环境 |
| 开发工具配置 | ✅ 完成 | Python、Go、Java、Node.js |

### 🔄 进行中的工作

| 任务 | 状态 | 负责人 |
|------|------|--------|
| 剩余文档更新 | 📝 进行中 | 系统管理员 |
| 脚本链接更新 | 📝 进行中 | 系统管理员 |
| 文档结构验证 | 📝 进行中 | 系统管理员 |

### 📅 计划中的功能

| 功能 | 优先级 | 预计完成时间 |
|------|--------|--------------|
| 安全配置文档 | 高 | 2025-12 |
| 高级网络配置 | 中 | 2026-01 |
| 监控系统配置 | 中 | 2026-01 |
| 备份策略配置 | 低 | 2026-02 |

## 🔧 验证清单

### ✅ 已验证项目

- [x] 文档结构合理化
- [x] 编写规范制定
- [x] 环境变量配置
- [x] SSH基础配置
- [x] Docker环境配置
- [x] 开发工具配置
- [x] 脚本工具创建

### 📝 待验证项目

- [ ] 所有链接有效性
- [ ] 脚本执行正确性
- [ ] 文档格式一致性
- [ ] 用户使用体验

## 🔗 相关链接

### 项目资源
- [项目总览](README.md)
- [目录映射向导](DIRECTORY_MAPPING.md)
- [变更日志](CHANGELOG.md)

### 文档中心
- [基础配置](docs/basics/) - 服务器初始化
- [自动化配置](docs/automation/) - 容器和CI/CD
- [故障排除](docs/troubleshooting/) - 问题解决方案
- [写作指南](docs/guides/) - 文档编写规范

### 外部资源
- [Ubuntu官方文档](https://help.ubuntu.com/)
- [Docker官方文档](https://docs.docker.com/)
- [Jenkins官方文档](https://www.jenkins.io/doc/)

## 🤝 贡献指南

### 添加新内容

1. **遵循规范**: 使用[Markdown编写规范](docs/guides/markdown-writing-standards.md)
2. **确定编号**: 按功能分类选择合适的三位数字编号
3. **测试验证**: 确保所有命令和配置可执行
4. **更新索引**: 在相应目录的README中添加文档信息

### 文档质量标准

- **准确性**: 技术信息正确无误
- **完整性**: 包含前置条件、操作步骤、验证方法
- **可用性**: 命令可直接复制执行
- **一致性**: 遵循统一的格式和风格

## 📞 技术支持

### 获取帮助

1. **查看文档**: 首先查看相关文档目录
2. **检查故障排除**: 查看[故障排除](docs/troubleshooting/)目录
3. **参考历史**: 查看[历史记录](history/)中的类似问题
4. **使用快速参考**: 参考[快速参考卡片](docs/guides/markdown-quick-reference.md)

### 联系信息

- **维护人员**: 系统管理员
- **项目版本**: 2.0
- **文档版本**: 遵循各文档内版本信息

## 📈 版本历史

| 版本 | 日期 | 主要更新 | 更新人 |
|------|------|----------|--------|
| 1.0 | 2025-11-05 | 初始版本，基础功能 | 系统管理员 |
| 2.0 | 2025-11-05 | 文档结构重组、编写规范、内容标准化 | 系统管理员 |

---

**项目状态**: ✅ 已完成重构
**最后更新**: 2025-11-05
**维护人员**: 系统管理员
**文档质量**: ✅ 已通过质量检查

**感谢您使用Ubuntu服务器操作指南！** 🚀