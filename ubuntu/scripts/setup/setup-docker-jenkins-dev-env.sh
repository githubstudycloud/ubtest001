#!/bin/bash

# Docker、Jenkins和开发环境自动化配置脚本
# 基于文档002: Docker和CI/CD环境配置
#
# 使用方法:
#   1. 确保.env文件已配置
#   2. chmod +x setup-docker-jenkins-dev-env.sh
#   3. ./setup-docker-jenkins-dev-env.sh

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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

log_command() {
    echo -e "${CYAN}[COMMAND]${NC} $1"
}

# 检查系统要求
check_system_requirements() {
    log_step "检查系统要求..."

    # 检查系统版本
    if ! lsb_release -i | grep -q "Ubuntu"; then
        log_error "当前系统不是Ubuntu，不支持的系统"
        exit 1
    fi

    # 检查系统架构
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ]; then
        log_warning "系统架构: $ARCH，某些功能可能不支持"
    fi

    # 检查内存
    MEMORY=$(free -m | awk 'NR==2{print $2}')
    if [ "$MEMORY" -lt 2048 ]; then
        log_warning "系统内存不足2GB，建议至少4GB"
    fi

    # 检查磁盘空间
    DISK=$(df / | awk 'NR==2{print $4}')
    if [ "$DISK" -lt 20480000 ]; then
        log_warning "磁盘空间不足20GB，建议至少20GB可用空间"
    fi

    log_success "系统要求检查完成"
}

# 更新系统包
update_system() {
    log_step "更新系统包..."

    log_command "sudo apt update"
    sudo apt update

    log_command "sudo apt upgrade -y"
    sudo apt upgrade -y

    log_command "sudo apt autoremove -y"
    sudo apt autoremove -y

    log_success "系统更新完成"
}

# 安装Docker
install_docker() {
    log_step "安装Docker..."

    # 卸载旧版本
    log_info "卸载旧版本Docker..."
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # 安装依赖
    log_info "安装Docker依赖..."
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # 添加Docker官方GPG密���
    log_info "添加Docker官方GPG密钥..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # 添加Docker软件源
    log_info "添加Docker软件源..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 更新包索引
    sudo apt update

    # 安装Docker Engine
    log_info "安装Docker Engine..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 配置Docker用户组
    log_info "配置Docker用户组..."
    sudo usermod -aG docker "${UBUNTU_SERVER_USER}"

    # 配置Docker守护进程
    log_info "配置Docker守护进程..."
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ],
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false
}
EOF

    # 启动并启用Docker服务
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    sudo systemctl enable docker

    # 测试Docker
    log_info "测试Docker安装..."
    if docker run --rm hello-world > /dev/null 2>&1; then
        log_success "Docker安装成功"
    else
        log_error "Docker测试失败"
        return 1
    fi
}

# 安装Docker Compose
install_docker_compose() {
    log_step "安装Docker Compose..."

    # 检查是否已经安装（Docker Compose插件）
    if docker compose version > /dev/null 2>&1; then
        log_success "Docker Compose已安装"
        docker compose version
        return
    fi

    # 获取最新版本
    log_info "获取Docker Compose最新版本..."
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

    # 下载Docker Compose
    log_info "下载Docker Compose ${DOCKER_COMPOSE_VERSION}..."
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # 添加执行权限
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

    # 验证安装
    if docker-compose --version > /dev/null 2>&1; then
        log_success "Docker Compose安装成功"
        docker-compose --version
    else
        log_error "Docker Compose安装失败"
        return 1
    fi
}

# 安装Jenkins
install_jenkins() {
    log_step "安装Jenkins..."

    # 创建Jenkins数据目录
    log_info "创建Jenkins数据目录..."
    sudo mkdir -p /var/jenkins_home
    sudo chown -R 1000:1000 /var/jenkins_home

    # 拉取Jenkins镜像
    log_info "拉取Jenkins镜像..."
    docker pull jenkins/jenkins:lts

    # 检查端口是否被占用
    if netstat -tlnp | grep -q ":8081 "; then
        log_warning "端口8081已被占用，使用端口8082"
        JENKINS_PORT=8082
    else
        JENKINS_PORT=8081
    fi

    # 创建Jenkins容器
    log_info "创建Jenkins容器..."
    docker run -d \
        --name jenkins \
        --restart=always \
        -p "${JENKINS_PORT}":8080 \
        -p 50000:50000 \
        -v /var/jenkins_home:/var/jenkins_home \
        -v "$(which docker)":/usr/bin/docker \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e JAVA_OPTS="-Xmx1024m -Xms512m" \
        jenkins/jenkins:lts

    # 等待Jenkins启动
    log_info "等待Jenkins启动..."
    sleep 30

    # 检查Jenkins是否正常运行
    if docker ps | grep -q jenkins; then
        log_success "Jenkins容器启动成功"
        log_info "Jenkins访问地址: http://localhost:${JENKINS_PORT}"

        # 获取初始密码
        log_info "获取Jenkins初始密码..."
        JENKINS_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "密码获取失败")
        if [ "$JENKINS_PASSWORD" != "密码获取失败" ]; then
            log_success "Jenkins初始密码: $JENKINS_PASSWORD"
            log_info "请访问 http://localhost:${JENKINS_PORT} 并使用上述密码进行初始配置"
        else
            log_warning "Jenkins初始密码获取失败，请稍后手动获取"
        fi
    else
        log_error "Jenkins容器启动失败"
        return 1
    fi
}

# 安装Python环境
install_python() {
    log_step "安装Python开发环境..."

    # 安装Python开发工具
    log_info "安装Python开发工具..."
    sudo apt install -y python3-dev python3-pip python3-venv python3-setuptools python3-wheel

    # 验证安装
    if python3 --version > /dev/null 2>&1 && pip3 --version > /dev/null 2>&1; then
        log_success "Python开发环境安装成功"
        log_info "Python版本: $(python3 --version)"
        log_info "pip版本: $(pip3 --version)"
    else
        log_error "Python环境安装失败"
        return 1
    fi

    # 配置pip镜像源
    log_info "配置pip国内镜像源..."
    pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

    # 安装常用包
    log_info "安装Python常用包..."
    pip3 install --user --upgrade pip
    pip3 install --user requests flask django numpy pandas jupyter notebook

    log_success "Python环境配置完成"
}

# 安装Go环境
install_go() {
    log_step "安装Go开发环境..."

    # 设置Go版本
    GO_VERSION="1.21.5"

    # 检查Go是否已安装
    if command -v go &> /dev/null; then
        INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
        log_info "检测到Go已安装，版本: $INSTALLED_GO_VERSION"

        # 如果版本符合要求，跳过安装
        if [[ "$INSTALLED_GO_VERSION" == "$GO_VERSION"* ]]; then
            log_success "Go版本符合要求，跳过安装"
        else
            log_info "Go版本不符合要求，将安装Go $GO_VERSION"
            install_go_binary
        fi
    else
        install_go_binary
    fi

    # 配置Go环境
    log_info "配置Go环境变量..."
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc

    # 创建Go目录
    mkdir -p ~/go/bin ~/go/src

    # 配置Go代理
    log_info "配置Go模块代理..."
    go env -w GOPROXY=https://goproxy.cn,direct
    go env -w GOSUMDB=sum.golang.google.cn

    log_success "Go环境配置完成"
    log_info "Go版本: $(go version)"
}

install_go_binary() {
    log_info "下载并安装Go ${GO_VERSION}..."
    cd /tmp
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"

    # 删除旧版本
    sudo rm -rf /usr/local/go

    # 解压新版本
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"

    # 清理下载文件
    rm "go${GO_VERSION}.linux-amd64.tar.gz"

    # 重新加载环境变量
    export PATH=$PATH:/usr/local/go/bin
}

# 安装Java环境
install_java() {
    log_step "安装Java开发环境..."

    # 安装OpenJDK 17
    log_info "安装OpenJDK 17..."
    sudo apt install -y openjdk-17-jdk openjdk-17-jre

    # 安装Maven
    log_info "安装Maven..."
    sudo apt install -y maven

    # 安装Gradle
    log_info "安装Gradle..."
    sudo apt install -y gradle

    # 配置JAVA_HOME
    JAVA_HOME_PATH=$(readlink -f /usr/bin/java | sed "s:bin/java::")
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.bashrc
    export JAVA_HOME="$JAVA_HOME_PATH"

    # 验证安装
    if java -version > /dev/null 2>&1 && javac -version > /dev/null 2>&1; then
        log_success "Java开发环境安装成功"
        log_info "Java版本: $(java -version 2>&1 | head -n 1)"
        log_info "Maven版本: $(mvn --version | head -n 1)"
        log_info "Gradle版本: $(gradle --version | head -n 1)"
    else
        log_error "Java环境安装失败"
        return 1
    fi
}

# 安装Node.js环境
install_nodejs() {
    log_step "安装Node.js开发环境..."

    # 添加NodeSource仓库
    log_info "添加NodeSource仓库..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

    # 安装Node.js
    log_info "安装Node.js LTS..."
    sudo apt install -y nodejs

    # 配置npm镜像源
    log_info "配置npm国内镜像源..."
    npm config set registry https://registry.npmmirror.com

    # 安装常用全局包
    log_info "安装Node.js常用全局包..."
    npm install -g @vue/cli create-react-app typescript yarn pm2 nodemon

    # 验证安装
    if node --version > /dev/null 2>&1 && npm --version > /dev/null 2>&1; then
        log_success "Node.js开发环境安装成功"
        log_info "Node.js版本: $(node --version)"
        log_info "npm版本: $(npm --version)"
    else
        log_error "Node.js环境安装失败"
        return 1
    fi
}

# 创建测试项目
create_test_projects() {
    log_step "创建测试项目..."

    # 创建项目目录
    mkdir -p ~/projects/{docker-test,python-test,go-test,java-test,nodejs-test}

    # 创建Docker测试项目
    log_info "创建Docker测试项目..."
    cd ~/projects/docker-test
    cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    restart: unless-stopped
EOF
    mkdir -p html
    echo "<h1>Docker Test - $(date)</h1>" > html/index.html

    # 创建Go测试项目
    log_info "创建Go测试项目..."
    cd ~/projects/go-test
    cat > main.go << 'EOF'
package main
import (
    "fmt"
    "net/http"
)
func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, Go! Dev environment setup successful!")
}
func main() {
    http.HandleFunc("/", handler)
    fmt.Println("Go test server starting on port 8081...")
    http.ListenAndServe(":8081", nil)
}
EOF
    go mod init test-project 2>/dev/null || true

    # 创建Node.js测试项目
    log_info "创建Node.js测试项目..."
    cd ~/projects/nodejs-test
    npm init -y > /dev/null 2>&1
    cat > server.js << 'EOF'
const http = require('http');
const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello, Node.js! Dev environment setup successful!\n');
});
const PORT = 8082;
server.listen(PORT, () => {
    console.log(`Node.js test server running on port ${PORT}`);
});
EOF

    cd ~
    log_success "测试项目创建完成"
}

# 创建环境验证脚本
create_verification_script() {
    log_step "创建环境验证脚本..."

    cat > ~/dev-env-verify.sh << 'EOF'
#!/bin/bash
echo "=== 开发环境验证 ==="
echo "验证时间: $(date)"
echo

# 验证Docker
echo "Docker验证:"
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
    docker run --rm hello-world > /dev/null 2>&1 && echo "✅ Docker运行正常" || echo "❌ Docker运行异常"
else
    echo "❌ Docker未安装"
fi
echo

# 验证Docker Compose
echo "Docker Compose验证:"
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose: $(docker-compose --version)"
else
    echo "❌ Docker Compose未安装"
fi
echo

# 验证Jenkins
echo "Jenkins验证:"
if docker ps | grep -q jenkins; then
    echo "✅ Jenkins容器运行中"
    JENKINS_PORT=$(docker port jenkins 8080/tcp | cut -d: -f2)
    echo "访问地址: http://localhost:${JENKINS_PORT}"
else
    echo "❌ Jenkins未运行"
fi
echo

# 验证Python
echo "Python验证:"
if command -v python3 &> /dev/null; then
    echo "✅ Python: $(python3 --version)"
    if command -v pip3 &> /dev/null; then
        echo "✅ pip: $(pip3 --version)"
    else
        echo "❌ pip未安装"
    fi
else
    echo "❌ Python未安装"
fi
echo

# 验证Go
echo "Go验证:"
if command -v go &> /dev/null; then
    echo "✅ Go: $(go version)"
    echo "✅ GOPATH: $GOPATH"
else
    echo "❌ Go未安装"
fi
echo

# 验证Java
echo "Java验证:"
if command -v java &> /dev/null; then
    echo "✅ Java: $(java -version 2>&1 | head -n 1)"
    if command -v mvn &> /dev/null; then
        echo "✅ Maven: $(mvn --version | head -n 1)"
    else
        echo "❌ Maven未安装"
    fi
else
    echo "❌ Java未安装"
fi
echo

# 验证Node.js
echo "Node.js验证:"
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
    if command -v npm &> /dev/null; then
        echo "✅ npm: $(npm --version)"
    else
        echo "❌ npm未安装"
    fi
else
    echo "❌ Node.js未安装"
fi

echo
echo "=== 验证完成 ==="
EOF

    chmod +x ~/dev-env-verify.sh
    log_success "环境验证脚本创建完成: ~/dev-env-verify.sh"
}

# 主函数
main() {
    log_info "开始Docker、Jenkins和开发环境配置..."
    log_info "脚本版本: 1.0"
    log_info "基于文档: 002-docker-jenkins-dev-env.md"
    echo

    # 检查权限
    if [ "$EUID" -ne 0 ]; then
        if ! sudo -n true 2>/dev/null; then
            log_info "需要sudo权限，请输入密码"
        fi
    fi

    # 执行配置步骤
    check_system_requirements
    echo
    update_system
    echo
    install_docker
    echo
    install_docker_compose
    echo
    install_jenkins
    echo
    install_python
    echo
    install_go
    echo
    install_java
    echo
    install_nodejs
    echo
    create_test_projects
    echo
    create_verification_script
    echo

    log_success "🎉 Docker、Jenkins和开发环境配置完成！"
    echo
    log_info "配置摘要:"
    log_info "- Docker Engine: 已安装并配置"
    log_info "- Docker Compose: 已安装"
    log_info "- Jenkins: 已部署在容器中"
    log_info "- Python: 已安装开发环境"
    log_info "- Go: 已安装开发环境"
    log_info "- Java: 已安装JDK、Maven、Gradle"
    log_info "- Node.js: 已安装开发环境"
    log_info "- 测试项目: 已创建在 ~/projects/"
    echo
    log_info "下一步操作:"
    log_info "1. 重新登录以刷新用户组权限"
    log_info "2. 运行验证脚本: ~/dev-env-verify.sh"
    log_info "3. 访问Jenkins进行初始配置"
    log_info "4. 测试开发环境功能"
    echo
    log_warning "重要提醒:"
    log_warning "- 请重新登录或运行 'newgrp docker' 以应用docker用户组权限"
    log_warning "- Jenkins需要手动进行初始插件安装和管理员用户配置"
}

# 检查是否直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi