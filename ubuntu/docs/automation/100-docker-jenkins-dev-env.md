# Docker、Jenkins和开发环境配置指南

## 文档信息
- **编号**: 002
- **版本**: 1.0
- **创建日期**: 2025-11-05
- **目标系统**: Ubuntu 25.04 (plucky)
- **适用场景**: CI/CD环境和开发环境配置

## 目录
1. [Docker安装与配置](#docker安装与配置)
2. [Docker Compose安装](#docker-compose安装)
3. [Jenkins安装与配置](#jenkins安装与配置)
4. [Python开发环境配置](#python开发环境配置)
5. [Go开发环境配置](#go开发环境配置)
6. [Java开发环境配置](#java开发环境配置)
7. [Node.js和前端环境配置](#nodejs和前端环境配置)
8. [环境验证和测试](#环境验证和测试)
9. [故障排除](#故障排除)

---

## Docker安装与配置

### 1. 系统要求检查

#### 检查系统版本和架构
```bash
# 查看系统版本
lsb_release -a
# 应该显示 Ubuntu 25.04 (plucky)

# 查看系统架构
uname -m
# 应该显示 x86_64 (amd64)

# 查看内核版本
uname -r
# 推荐内核版本 5.x 以上
```

#### 检查系统资源
```bash
# 检查内存（推荐至少2GB）
free -h

# 检查磁盘空间（推荐至少20GB可用）
df -h

# 检查CPU信息
lscpu
```

### 2. 卸载旧版本（如果存在）

```bash
# 卸载旧版本的Docker
sudo apt remove docker docker-engine docker.io containerd runc -y

# 清理残留文件
sudo apt autoremove -y
sudo apt autoclean

# 删除Docker相关目录
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

### 3. 安装Docker

#### 方法一：官方脚本安装（推荐）
```bash
# 下载并执行Docker官方安装脚本
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 验证安装
docker --version
```

#### 方法二：手动安装
```bash
# 更新包索引
sudo apt update

# 安装依赖包
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加Docker软件源
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新包索引
sudo apt update

# 安装Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 验证安装
docker --version
docker compose version
```

### 4. Docker配置优化

#### 配置Docker用户组
```bash
# 将当前用户添加到docker组
sudo usermod -aG docker ${UBUNTU_SERVER_USER}

# 验证用户组
groups ${UBUNTU_SERVER_USER}

# 重新登录或使用以下命令刷新组权限
newgrp docker
```

#### 配置Docker守护进程
```bash
# 创建Docker配置目录
sudo mkdir -p /etc/docker

# 配置Docker daemon
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

# 重新加载并重启Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

# 验证Docker状态
sudo systemctl status docker
```

### 5. Docker基础验证

```bash
# 测试Docker运行
docker run hello-world

# 查看Docker信息
docker info

# 查看系统资源使用
docker system df

# 清理未使用的Docker资源
docker system prune -f
```

---

## Docker Compose安装

### 1. 安装Docker Compose（最新版本）

```bash
# 获取最新版本号
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

# 下载Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 创建软链接
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# 验证安装
docker-compose --version
```

### 2. 创建示例项目测试

```bash
# 创建测试目录
mkdir -p ~/docker-test
cd ~/docker-test

# 创建docker-compose.yml
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

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    restart: unless-stopped
EOF

# 创建测试页面
mkdir -p html
echo "<h1>Docker Compose Test - $(date)</h1>" > html/index.html

# 启动服务
docker-compose up -d

# 验证服务
docker-compose ps
curl http://localhost:8080

# 停止服务
docker-compose down
cd ~
```

---

## Jenkins安装与配置

### 1. 创建Jenkins数据和配置目录

```bash
# 创建Jenkins主目录
sudo mkdir -p /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home

# 创建Jenkins配置目录
mkdir -p ~/.jenkins
```

### 2. 使用Docker安装Jenkins

```bash
# 拉取Jenkins镜像
docker pull jenkins/jenkins:lts

# 创建Jenkins容器
docker run -d \
  --name jenkins \
  --restart=always \
  -p 8081:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v $(which docker):/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# 查看Jenkins容器状态
docker ps | grep jenkins

# 查看Jenkins日志获取初始密码
docker logs jenkins
```

### 3. Jenkins初始配置

#### 获取初始管理员密码
```bash
# 从容器日志中获取密码
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# 或者从挂载目录获取
sudo cat /var/jenkins_home/secrets/initialAdminPassword
```

#### 访问Jenkins
1. 打开浏览器访问: `http://localhost:8081`
2. 输入初始管理员密码
3. 选择"Install suggested plugins"
4. 创建管理员用户
5. 配置Jenkins URL

### 4. Jenkins插件配置

#### 推荐安装的插件
- **Docker Plugin**: Docker集成
- **Pipeline**: 流水线支持
- **Git**: Git版本控制
- **GitHub Integration**: GitHub集成
- **Blue Ocean**: 现代化界面
- **NodeJS Plugin**: Node.js支持
- **Maven Integration**: Maven构建支持

#### 配置Docker插件
```bash
# 在Jenkins管理界面配置：
# 1. Manage Jenkins → Manage Plugins → Available
# 2. 搜索并安装 "Docker Plugin"
# 3. Manage Jenkins → Configure System → Cloud
# 4. 添加Docker Cloud配置
```

### 5. 创建Jenkins Pipeline示例

#### 创建测试Pipeline
```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/example/repo.git'
            }
        }

        stage('Build') {
            steps {
                sh 'echo "Building application..."'
            }
        }

        stage('Test') {
            steps {
                sh 'echo "Running tests..."'
            }
        }

        stage('Deploy') {
            steps {
                sh 'echo "Deploying application..."'
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

---

## Python开发环境配置

### 1. 安装Python环境

#### 安装Python 3（系统自带）
```bash
# 检查Python版本
python3 --version

# 安装Python开发工具
sudo apt install -y python3-dev python3-pip python3-venv python3-setuptools

# 验证pip版本
pip3 --version
```

#### 安装多个Python版本（使用pyenv）
```bash
# 安装pyenv依赖
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev

# 安装pyenv
curl https://pyenv.run | bash

# 配置环境变量
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# 重新加载环境变量
source ~/.bashrc

# 安装Python版本
pyenv install 3.11.0
pyenv install 3.10.0
pyenv global 3.11.0

# 验证Python版本
python --version
```

### 2. 配置虚拟环境

#### 使用venv创建虚拟环境
```bash
# 创建项目目录
mkdir -p ~/projects/python-app
cd ~/projects/python-app

# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装常用包
pip install requests flask django numpy pandas jupyter

# 验证环境
python -c "import flask, numpy, pandas; print('Python environment ready!')"

# 退出虚拟环境
deactivate
```

### 3. 配置Jupyter Notebook

```bash
# 安装Jupyter
pip install jupyter jupyterlab

# 生成配置文件
jupyter notebook --generate-config

# 设置密码
jupyter notebook password

# 启动Jupyter（远程访问）
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root

# 或者使用systemd服务
sudo tee /etc/systemd/system/jupyter.service > /dev/null << 'EOF'
[Unit]
Description=Jupyter Notebook
After=network.target

[Service]
Type=simple
User=${UBUNTU_SERVER_USER}
WorkingDirectory=/home/${UBUNTU_SERVER_USER}/projects
ExecStart=/home/${UBUNTU_SERVER_USER}/.local/bin/jupyter lab --ip=0.0.0.0 --port=8888
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动Jupyter服务
sudo systemctl daemon-reload
sudo systemctl enable jupyter
sudo systemctl start jupyter
```

---

## Go开发环境配置

### 1. 安装Go语言环境

#### 方法一：官方二进制包安装
```bash
# 下载Go最新版本
GO_VERSION="1.21.5"
cd /tmp
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz

# 解压到/usr/local
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

# 配置环境变量
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc

# 重新加载环境变量
source ~/.bashrc

# 验证安装
go version
```

#### 方法二：包管理器安装
```bash
# 添加Go PPA（Ubuntu 25.04）
sudo apt update
sudo apt install -y golang-go

# 验证安装
go version
```

### 2. 配置Go开发环境

#### 设置Go模块代理
```bash
# 配置Go模块代理（国内镜像）
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GOSUMDB=sum.golang.google.cn

# 验证配置
go env GOPROXY
go env GOSUMDB
```

#### 创建Go项目示例
```bash
# 创建Go项目目录
mkdir -p ~/projects/go-app
cd ~/projects/go-app

# 初始化Go模块
go mod init example.com/go-app

# 创建main.go
cat > main.go << 'EOF'
package main

import (
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, Go! This is running on Ubuntu!")
}

func main() {
    http.HandleFunc("/", handler)
    fmt.Println("Server starting on port 8080...")
    http.ListenAndServe(":8080", nil)
}
EOF

# 运行Go应用
go run main.go

# 测试（在另一个终端）
curl http://localhost:8080

# 构建二进制文件
go build -o go-app
./go-app
```

### 3. 安装Go开发工具

```bash
# 安装常用Go工具
go install github.com/cweill/gotests/gotests@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/josharian/impl@latest
go install github.com/haya14busa/goplay/cmd/goplay@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
go install golang.org/x/tools/cmd/goimports@latest

# 验证工具安装
ls ~/go/bin/
```

---

## Java开发环境配置

### 1. 安装Java Development Kit (JDK)

#### 安装OpenJDK 17（推荐）
```bash
# 更新包索引
sudo apt update

# 安装OpenJDK 17
sudo apt install -y openjdk-17-jdk openjdk-17-jre

# 验证安装
java -version
javac -version

# 查看Java安装路径
which java
readlink -f $(which java)
```

#### 安装多个JDK版本
```bash
# 安装OpenJDK 11
sudo apt install -y openjdk-11-jdk

# 安装OpenJDK 8
sudo apt install -y openjdk-8-jdk

# 查看已安装的Java版本
sudo update-alternatives --list java
sudo update-alternatives --list javac

# 切换Java版本
sudo update-alternatives --config java
sudo update-alternatives --config javac
```

### 2. 配置Java环境变量

```bash
# 设置JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc

# 重新加载环境变量
source ~/.bashrc

# 验证环境变量
echo $JAVA_HOME
```

### 3. 安装Maven

```bash
# 安装Maven
sudo apt install -y maven

# 验证安装
mvn --version

# 创建Maven项目示例
mkdir -p ~/projects/maven-app
cd ~/projects/maven-app

# 创建Maven项目
mvn archetype:generate -DgroupId=com.example -DartifactId=maven-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

# 编译项目
cd maven-app
mvn compile

# 运行测试
mvn test

# 打包项目
mvn package

# 运行应用
java -cp target/maven-app-1.0-SNAPSHOT.jar com.example.App
```

### 4. 安装Gradle

```bash
# 下载Gradle
cd /tmp
wget https://services.gradle.org/distributions/gradle-8.5-bin.zip

# 解压到/opt
sudo unzip gradle-8.5-bin.zip -d /opt/
sudo ln -sf /opt/gradle-8.5 /opt/gradle

# 配置环境变量
echo 'export GRADLE_HOME=/opt/gradle' >> ~/.bashrc
echo 'export PATH=$PATH:$GRADLE_HOME/bin' >> ~/.bashrc

# 重新加载环境变量
source ~/.bashrc

# 验证安装
gradle --version

# 创建Gradle项目示例
mkdir -p ~/projects/gradle-app
cd ~/projects/gradle-app

# 初始化Gradle项目
gradle init --type java-application

# 构建项目
./gradlew build

# 运行应用
./gradlew run
```

---

## Node.js和前端环境配置

### 1. 安装Node.js

#### 使用NodeSource仓库安装
```bash
# 添加NodeSource仓库
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# 安装Node.js LTS
sudo apt install -y nodejs

# 验证安装
node --version
npm --version
```

#### 使用NVM安装多个版本
```bash
# 安装NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 重新加载环境变量
source ~/.bashrc

# 安装Node.js版本
nvm install 18
nvm install 20
nvm install --lts

# 切换Node.js版本
nvm use 18
nvm use 20
nvm use --lts

# 设置默认版本
nvm alias default 18

# 验证版本
node --version
npm --version
```

### 2. 配置npm

```bash
# 配置npm镜像源
npm config set registry https://registry.npmmirror.com

# 验证配置
npm config get registry

# 安装常用全局包
npm install -g @vue/cli
npm install -g create-react-app
npm install -g typescript
npm install -g yarn
npm install -g pm2
npm install -g nodemon

# 验证全局包
vue --version
create-react-app --version
```

### 3. Vue.js开发环境

#### 创建Vue项目
```bash
# 创建Vue项目目录
mkdir -p ~/projects/vue-app
cd ~/projects/vue-app

# 使用Vue CLI创建项目
vue create vue-project

# 或者使用Vite创建Vue3项目
npm create vue@latest vue-vite-project
cd vue-vite-project
npm install
npm run dev

# 测试Vue应用（在另一个终端）
curl http://localhost:5173
```

### 4. React开发环境

#### 创建React项目
```bash
# 创建React项目目录
mkdir -p ~/projects/react-app
cd ~/projects/react-app

# 使用Create React App创建项目
npx create-react-app react-project
cd react-project

# 启动开发服务器
npm start

# 测试React应用（在另一个终端）
curl http://localhost:3000
```

### 5. TypeScript配置

#### 全局安装TypeScript
```bash
# 安装TypeScript
npm install -g typescript ts-node

# 验证安装
tsc --version
ts-node --version

# 创建TypeScript项目
mkdir -p ~/projects/typescript-app
cd ~/projects/typescript-app

# 初始化项目
npm init -y
npm install typescript @types/node --save-dev

# 创建TypeScript配置
npx tsc --init

# 创建示例文件
cat > index.ts << 'EOF'
function greet(name: string): string {
    return `Hello, ${name}! TypeScript is working!`;
}

console.log(greet("Ubuntu"));
EOF

# 编译并运行
npx tsc index.ts
node index.js
```

---

## 环境验证和测试

### 1. 创建综合测试脚本

```bash
# 创建环境测试脚本
cat > ~/dev-env-test.sh << 'EOF'
#!/bin/bash

echo "=== 开发环境验证测试 ==="
echo "测试时间: $(date)"
echo

# 测试Docker
echo "1. Docker测试:"
if command -v docker &> /dev/null; then
    echo "✅ Docker已安装: $(docker --version)"
    if docker info &> /dev/null; then
        echo "✅ Docker服务正常"
    else
        echo "❌ Docker服务异常"
    fi
else
    echo "❌ Docker未安装"
fi
echo

# 测试Docker Compose
echo "2. Docker Compose测试:"
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose已安装: $(docker-compose --version)"
else
    echo "❌ Docker Compose未安装"
fi
echo

# 测试Jenkins
echo "3. Jenkins测试:"
if docker ps | grep -q jenkins; then
    echo "✅ Jenkins容器运行中"
    echo "访问地址: http://localhost:8081"
else
    echo "❌ Jenkins未运行"
fi
echo

# 测试Python
echo "4. Python测试:"
if command -v python3 &> /dev/null; then
    echo "✅ Python已安装: $(python3 --version)"
    if command -v pip3 &> /dev/null; then
        echo "✅ pip已安装: $(pip3 --version)"
    else
        echo "❌ pip未安装"
    fi
else
    echo "❌ Python未安装"
fi
echo

# 测试Go
echo "5. Go测试:"
if command -v go &> /dev/null; then
    echo "✅ Go已安装: $(go version)"
    echo "✅ GOPATH: $GOPATH"
else
    echo "❌ Go未安装"
fi
echo

# 测试Java
echo "6. Java测试:"
if command -v java &> /dev/null; then
    echo "✅ Java已安装: $(java -version 2>&1 | head -n 1)"
    if command -v mvn &> /dev/null; then
        echo "✅ Maven已安装: $(mvn --version | head -n 1)"
    else
        echo "❌ Maven未安装"
    fi
else
    echo "❌ Java未安装"
fi
echo

# 测试Node.js
echo "7. Node.js测试:"
if command -v node &> /dev/null; then
    echo "✅ Node.js已安装: $(node --version)"
    if command -v npm &> /dev/null; then
        echo "✅ npm已安装: $(npm --version)"
    else
        echo "❌ npm未安装"
    fi
else
    echo "❌ Node.js未安装"
fi
echo

echo "=== 测试完成 ==="
EOF

# 使脚本��执行
chmod +x ~/dev-env-test.sh

# 运行测试
~/dev-env-test.sh
```

### 2. 创建服务状态检查

```bash
# 创建服务状态检查脚本
cat > ~/service-status.sh << 'EOF'
#!/bin/bash

echo "=== 服务状态检查 ==="
echo "检查时间: $(date)"
echo

# 检查Docker服务
echo "Docker服务状态:"
sudo systemctl is-active docker
sudo systemctl status docker --no-pager -l
echo

# 检查Jenkins容器
echo "Jenkins容器状态:"
docker ps | grep jenkins || echo "Jenkins容器未运行"
echo

# 检查端口占用情况
echo "端口占用情况:"
echo "Docker: $(netstat -tlnp | grep :2375 || echo '未占用')"
echo "Jenkins: $(netstat -tlnp | grep :8081 || echo '未占用')"
echo "Nginx测试: $(netstat -tlnp | grep :8080 || echo '未占用')"
echo

echo "=== 检查完成 ==="
EOF

chmod +x ~/service-status.sh
~/service-status.sh
```

---

## 故障排除

### 1. Docker相关问题

#### 问题：Docker命令需要sudo
```bash
# 解决方案：将用户添加到docker组
sudo usermod -aG docker ${UBUNTU_SERVER_USER}
newgrp docker
```

#### 问题：Docker镜像拉取缓慢
```bash
# 解决方案：配置国内镜像源
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF
sudo systemctl restart docker
```

### 2. Jenkins相关问题

#### 问题：Jenkins启动缓慢
```bash
# 解决方案：增加JVM内存
docker run -d --name jenkins \
  --restart=always \
  -p 8081:8080 \
  -e JAVA_OPTS="-Xmx1024m -Xms512m" \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

#### 问题：插件安装失败
```bash
# 解决方案：使用国内镜像源
docker exec jenkins sed -i 's/https://updates.jenkins.io/https://mirrors.tuna.tsinghua.edu.cn/jenkins/g' /var/jenkins_home/hudson.model.UpdateCenter.xml
docker restart jenkins
```

### 3. 开发环境问题

#### 问题：Python包安装缓慢
```bash
# 解决方案：配置pip国内镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

#### 问题：Go模块下载缓慢
```bash
# 解决方案：配置Go代理
go env -w GOPROXY=https://goproxy.cn,direct
```

#### 问题：Node.js包安装缓慢
```bash
# 解决方案：配置npm镜像
npm config set registry https://registry.npmmirror.com
```

### 4. 端口冲突解决

```bash
# 查看端口占用
sudo netstat -tlnp | grep :8081

# 杀死占用端口的进程
sudo kill -9 <PID>

# 或者修改服务端口
docker run -d -p 8082:8080 jenkins/jenkins:lts
```

---

## 验证清单

### ✅ Docker环境 (已测试)
- [x] Docker Engine安装成功 - 28.2.2
- [ ] Docker Compose安装成功 - 待测试
- [x] Docker服务正常运行 - Active
- [ ] 镜像拉取测试通过 - 网络问题，已配置加速器
- [ ] 容器运行测试通过 - 待网络恢复后测试

### ✅ Jenkins环境 (部分测试)
- [ ] Jenkins容器运行正常 - 待Docker镜像拉取后测试
- [ ] 初始配置完成 - 待测试
- [ ] 推荐插件安装完成 - 待测试
- [ ] Pipeline配置测试通过 - 待测试

### ✅ Python环境 (已测试)
- [x] Python3安装成功 - 3.13.3
- [x] pip工具正常 - 25.0
- [ ] 虚拟环境创建成功 - 待测试
- [ ] Jupyter Notebook可访问 - 待测试

### ✅ Go环境 (已测试)
- [x] Go语言安装成功 - 1.24.2
- [ ] GOPATH配置正确 - 待配置
- [ ] Go模块代理配置成功 - 待配置
- [ ] 示例项目运行正常 - 待测试

### ✅ Java环境 (已测试)
- [x] JDK安装成功 - OpenJDK 17.0.16
- [ ] JAVA_HOME配置正确 - 待配置
- [ ] Maven安装成功 - 待安装
- [ ] Gradle安装成功 - 待安装

### ✅ Node.js环境 (已测试)
- [x] Node.js安装成功 - v20.18.1
- [x] npm工具正常 - 9.2.0
- [ ] Vue CLI安装成功 - 待安装
- [ ] React项目创建成功 - 待测试

---

**文档版本**: 1.0
**最后更新**: 2025-11-05
**���试状态**: ⏳ 待测试
**维护状态**: ✅ 活跃维护中