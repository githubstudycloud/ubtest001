# Ubuntu项目目录结构映射向导

## 📁 项目根目录结构

```
ubuntu/
├── README.md                    # 项目总览和快速开始
├── DIRECTORY_MAPPING.md         # 目录映射向导（当前文件）
├── .env.example                 # 配置文件模板
├── .gitignore                   # Git忽略规则
├── docs/                        # 📚 文档目录
├── scripts/                     # 🔧 脚本目录
├── config/                      # ⚙️ 配置模板目录
├── templates/                   # �� 模板文件目录
├── history/                     # 📜 历史记录目录
├── examples/                    # 💡 示例和演示目录
└── tools/                       # 🛠️ 工具和辅助程序目录
```

## 📚 docs/ - 文档目录

### 🗂️ 文档分类结构
```
docs/
├── README.md                    # 文档索引和导航
├── basics/                      # 🎯 基础配置文档
│   ├── 001-ubuntu-basic-system-configuration.md
│   ├── 002-initial-setup.md
│   └── 003-user-management.md
├── network/                     # 🌐 网络配置文档
│   ├── 010-ssh-configuration.md
│   ├── 011-network-tools.md
│   └── 012-firewall-setup.md
├── security/                    # 🔒 安全配置文档
│   ├── 020-sudo-configuration.md
│   ├── 021-user-permissions.md
│   └── 022-security-hardening.md
├── backup/                      # 💾 备份相关文档
│   ├── 030-backup-strategies.md
│   └── 031-recovery-procedures.md
├── monitoring/                  # 📊 监控相关文档
│   ├── 040-system-monitoring.md
│   └── 041-log-analysis.md
├── automation/                  # 🤖 自动化文档
│   ├── 050-cron-jobs.md
│   └── 051-scripting-best-practices.md
└── troubleshooting/             # 🔧 故障排除文档
    ├── 090-common-issues.md
    ├── 091-ssh-problems.md
    └── 092-network-troubleshooting.md
```

### 📖 文档命名规范

- **编号系统**: 使用三位数字编号 (001, 002, 003...)
- **分类标识**: 按功能模块分组
- **命名规则**: `编号-简短描述.md`
- **语言要求**: 使用中文描述，英文文件名

## 🔧 scripts/ - 脚本目录

### 📂 脚本分类结构
```
scripts/
├── README.md                    # 脚本使用说明
├── setup/                       # 🚀 安装配置脚本
│   ├── setup-ubuntu-server.sh
│   ├── remote-setup.sh
│   └── install-essentials.sh
├── maintenance/                 # 🔧 维护脚本
│   ├── system-update.sh
│   ├── cleanup.sh
│   └── health-check.sh
├── security/                    # 🔒 安全相关脚本
│   ├── setup-ubuntu-sudo.sh
│   ├── verify-sudo-config.sh
│   └── security-audit.sh
└── deployment/                  # 🚀 部署相关脚本
    ├── deploy-application.sh
    └── rollback.sh
```

### 📝 脚本命名规范

- **功能前缀**: setup-, maintenance-, security-, deployment-
- **描述性名称**: 清楚表达脚本功能
- **统一扩展名**: `.sh` (bash脚本)
- **可执行权限**: 默认包含 `chmod +x` 说明

## ⚙️ config/ - 配置模板目录

### 📋 配置文件结构
```
config/
├── README.md                    # 配置说明
├── ssh/                         # SSH配置模板
│   ├── sshd_config.template
│   └── ssh_config.template
├── network/                     # 网络配置模板
│   ├── interfaces.template
│   └── netplan.template
├── security/                    # 安全配置模板
│   ├── sudoers.template
│   └── ufw.rules.template
└── system/                      # 系统配置模板
    ├── systemd.template
    └── cron.template
```

## 📄 templates/ - 模板文件目录

### 📋 模板文件结构
```
templates/
├── README.md                    # 模板使用说明
├── documents/                   # 文档模板
│   ├── operation-guide.md.template
│   └── troubleshooting-report.md.template
├── scripts/                     # 脚本模板
│   ├── basic-script.sh.template
│   └── service-script.sh.template
└── configs/                     # 配置模板
    ├── nginx.conf.template
    └── docker-compose.yml.template
```

## 📜 history/ - 历史记录目录

### 📚 历史文档结构
```
history/
├── README.md                    # 历史记录说明
├── 2024/                        # 按年份归档
│   ├── 11-november/
│   │   ├── ssh-troubleshooting-report.md
│   │   ├── connection-test-results.md
│   │   └── sudo-configuration-success-report.md
│   └── archives/
└── legacy/                      # 遗留文档
    ├── ubuntu-sudo-setup-guide.md
    └── ssh-solution-with-existing-key.md
```

## 💡 examples/ - 示例和演示目录

### 🎯 示例文件结构
```
examples/
├── README.md                    # 示例说明
├── quick-start/                 # 快速开始示例
│   ├── QUICK_START.md
│   └── first-server-setup.md
├── use-cases/                   # 使用场景示例
│   ├── web-server-setup.md
│   └── database-server.md
└── demos/                       # 演示文件
    ├── demo-script.sh
    └── demo-config.conf
```

## 🛠️ tools/ - 工具和辅助程序目录

### 🔧 工具文件结构
```
tools/
├── README.md                    # 工具使用说明
├── generators/                  # 生成器工具
│   ├── config-generator.py
│   └── script-generator.sh
├── validators/                  # 验证工具
│   ├── config-validator.sh
│   └── syntax-checker.py
└── utilities/                   # 实用工具
    ├── log-analyzer.sh
    └── backup-utility.sh
```

## 🔄 文件迁移映射表

### 原始文件 → 新位置

| 原始路径 | 新路径 | 说明 |
|----------|--------|------|
| `ubuntu_docs/001-ubuntu-basic-system-configuration.md` | `ubuntu/docs/basics/001-ubuntu-basic-system-configuration.md` | 基础配置文档 |
| `ubuntu_docs/scripts/setup-ubuntu-server.sh` | `ubuntu/scripts/setup/setup-ubuntu-server.sh` | 主配置脚本 |
| `ubuntu_docs/tmp/*` | `ubuntu/history/2024/11-november/` | 历史文档 |
| `QUICK_START.md` | `ubuntu/examples/quick-start/QUICK_START.md` | 快速开始 |
| `remote_setup.sh` | `ubuntu/scripts/setup/remote-setup.sh` | 远程配置脚本 |
| `setup_ubuntu_sudo.sh` | `ubuntu/scripts/security/setup-ubuntu-sudo.sh` | sudo配置脚本 |
| `verify_sudo_config.sh` | `ubuntu/scripts/security/verify-sudo-config.sh` | 验证脚本 |

## 🎯 使用指南

### 📖 如何快速找到文件

1. **查找配置文档**:
   ```bash
   # 基础配置
   find ubuntu/docs/basics/ -name "*.md"

   # 网络配置
   find ubuntu/docs/network/ -name "*.md"
   ```

2. **查找配置脚本**:
   ```bash
   # 安装脚本
   find ubuntu/scripts/setup/ -name "*.sh"

   # 安全脚本
   find ubuntu/scripts/security/ -name "*.sh"
   ```

3. **查找模板文件**:
   ```bash
   # SSH配置模板
   find ubuntu/config/ssh/ -name "*.template"
   ```

### 🔄 路径引用更新

当移动文件后，需要更新以下内容：

1. **脚本中的路径引用**:
   ```bash
   # 原来: source "../../.env"
   # 现在: source "../../../.env"
   ```

2. **文档中的相对链接**:
   ```markdown
   # 原来: [脚本](../scripts/setup-ubuntu-server.sh)
   # 现在: [脚本](../../scripts/setup/setup-ubuntu-server.sh)
   ```

3. **README文件中的目录结构**:
   ```markdown
   # 更新所有README.md中的目录路径
   ```

## 📋 维护建议

### 🔄 定期维护任务

1. **月度检查**:
   - 清理历史文档
   - 更新目录索引
   - 检查死链接

2. **季度整理**:
   - 归档旧文档到history目录
   - 更新模板文件
   - 优化脚本结构

3. **年度重组**:
   - 评估目录结构合理性
   - 合并或拆分类别
   - 更新命名规范

### 📝 新文件添加流程

1. **确定分类**: 根据内容选择合适的子目录
2. **遵循命名**: 使用统一的命名规范
3. **更新索引**: 在相关README中添加条目
4. **创建链接**: 在相关文档中添加交叉引用

---

## 📞 联系和维护

### 🔧 目录结构维护

- **负责人**: 系统管理员
- **更新频率**: 按需更新
- **版本控制**: Git管理所有变更
- **文档同步**: 确保所有README与实际结构同步

### 📊 使用统计

- **文档数量**: 动态统计
- **脚本数量**: 动态统计
- **模板数量**: 动态统计
- **最后更新**: 自动记录

---

**目录版本**: 1.0
**创建时间**: 2025-11-05
**维护状态**: ✅ 活跃维护中