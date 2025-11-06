# Ubuntu自动化脚本中心

## 🔧 脚本概览

本目录包含Ubuntu服务器管理的各种自动化脚本，按照功能用途进行分类组织。

## 🗂️ 脚本分类

### 🚀 安装配置 ([setup/](setup/))
服务器安装和基础配置相关脚本。

**可用脚本**:
- [setup-ubuntu-server.sh](setup/setup-ubuntu-server.sh) - 主配置脚本
- [remote-setup.sh](setup/remote-setup.sh) - 远程配置脚本

**使用方法**:
```bash
cd setup/
chmod +x setup-ubuntu-server.sh
./setup-ubuntu-server.sh
```

### 🔒 安全配置 ([security/](security/))
系统安全和权限管理相关脚本。

**可用脚本**:
- [setup-ubuntu-sudo.sh](security/setup-ubuntu-sudo.sh) - sudo权限配置
- [verify-sudo-config.sh](security/verify-sudo-config.sh) - sudo配置验证

**使用方法**:
```bash
cd security/
chmod +x setup-ubuntu-sudo.sh
./setup-ubuntu-sudo.sh
```

### 🔧 系统维护 ([maintenance/](maintenance/))
系统日常维护和优化脚本。

**计划脚本**:
- 系统更新脚本
- 日志清理脚本
- 性能优化脚本
- 健康检查脚本

### 🚀 部署脚本 ([deployment/](deployment/))
应用部署和服务管理脚本。

**计划脚本**:
- 应用部署脚本
- 服务管理脚本
- 回滚脚本

## 📖 脚本使用指南

### 🔐 安全配置

所有脚本都使用环境变量管理敏感信息：

```bash
# 确保已配置环境变量
if [ -f "../../../.env" ]; then
    source "../../../.env"
fi
```

### 🚀 执行权限

```bash
# 为脚本添加执行权限
chmod +x script-name.sh

# 执行脚本
./script-name.sh
```

### 📝 脚本规范

- **命名规则**: `功能-描述.sh`
- **环境变量**: 必须检查.env文件是否存在
- **错误处理**: 使用 `set -e` 遇到错误立即退出
- **日志输出**: 使用彩色输出区分不同类型的消息
- **配置验证**: 包含配置验证和错误提示

### 🔄 脚本模板

```bash
#!/bin/bash

# 脚本描述
# 作者: [作者名]
# 创建时间: [日期]

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 主函数
main() {
    log_info "开始执行脚本..."
    # 脚本逻辑
    log_success "脚本执行完成！"
}

# 检查是否直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 🔗 相关链接

- [项目首页](../README.md) - 项目总览
- [文档中心](../docs/) - 详细文档
- [配置模板](../config/) - 配置文件模板
- [使用示例](../examples/) - 使用案例

## 📊 脚本统计

| 分类 | 脚本数量 | 状态 | 描述 |
|------|----------|------|------|
| 安装配置 | 2 | ✅ 完成 | 服务器初始化和配置 |
| 安全配置 | 2 | ✅ 完成 | 权限和安全配置 |
| 系统维护 | 0 | 📝 计划中 | 日常维护脚本 |
| 部署脚本 | 0 | 📝 计划中 | 应用部署管理 |

## 🛡️ 安全注意事项

### ⚠️ 重要提醒

1. **环境变量**: 所有脚本都必须加载.env文件
2. **权限检查**: 脚本执行前检查必要权限
3. **备份配置**: 重要操作前自动备份配置文件
4. **错误处理**: 包含完整的错误处理和回滚机制

### 🔒 安全检查清单

- [ ] 环境变量加载检查
- [ ] 必要权限验证
- [ ] 配置文件备份
- [ ] 错误处理机制
- [ ] 日志记录功能

## 🤝 贡献指南

### 添加新脚本

1. **确定分类**: 选择合适的子目录
2. **遵循规范**: 使用标准模板和命名规则
3. **安全检查**: 确保环境变量和权限管理
4. **测试验证**: 在测试环境验证脚本功能
5. **文档更新**: 更新相关说明文档

### 脚本维护

- 定期更新脚本内容
- 修复发现的bug和问题
- 优化脚本性能和可读性
- 添加新的功能和选项

---

**脚本中心版本**: 1.0
**最后更新**: 2025-11-05
**维护状态**: ✅ 活跃维护中

**需要帮助？** 查看 [故障排除](../docs/troubleshooting/) 或 [历史记录](../history/)