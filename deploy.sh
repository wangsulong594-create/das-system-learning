#!/bin/bash

################################################################################
# DAS系统学习项目 - 自动部署脚本
# 功能：自动创建GitHub仓库并上传所有文件
# 使用：chmod +x deploy.sh && ./deploy.sh
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置信息
GITHUB_USER="wangsulong594-create"
REPO_NAME="das-system-learning"
REPO_DESCRIPTION="DAS系统完整学习记录 - 从硬件到软件的0到1学习指南"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DAS系统学习项目 - 自动部署脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查Git是否安装
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git未安装，请先安装Git${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git已安装${NC}"

# 检查是否有GitHub CLI
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✓ GitHub CLI已安装${NC}"
    USE_GH_CLI=true
else
    echo -e "${YELLOW}⚠ GitHub CLI未安装（可选，用于自动创建仓库）${NC}"
    USE_GH_CLI=false
fi

echo ""
echo -e "${YELLOW}请输入以下信息：${NC}"
echo ""

# 询问用户是否已登录GitHub
read -p "是否已登录GitHub账户? (y/n): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}请先登录GitHub。执行：${NC}"
    echo "  gh auth login"
    exit 1
fi

echo ""
echo -e "${BLUE}开始部署...${NC}"
echo ""

# 步骤1：使用GitHub CLI创建仓库（如果可用）
if [ "$USE_GH_CLI" = true ]; then
    echo -e "${YELLOW}步骤1/4：创建GitHub仓库${NC}"
    
    if gh repo view $GITHUB_USER/$REPO_NAME &>/dev/null; then
        echo -e "${YELLOW}仓库已存在，跳过创建${NC}"
    else
        echo "正在创建仓库 $REPO_NAME..."
        gh repo create $REPO_NAME \
            --public \
            --description "$REPO_DESCRIPTION" \
            --source=. \
            --remote=origin \
            --push
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ 仓库创建成功${NC}"
        else
            echo -e "${RED}✗ 仓库创建失败${NC}"
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}步骤1/4：手动创建GitHub仓库（跳过自动创建）${NC}"
    echo -e "${YELLOW}请在 https://github.com/new 手动创建仓库，设置：${NC}"
    echo "  - Repository name: $REPO_NAME"
    echo "  - Description: $REPO_DESCRIPTION"
    echo "  - Public"
    echo "  - 不要初始化README"
    echo ""
    read -p "创建完成后按Enter继续..."
fi

echo ""
echo -e "${YELLOW}步骤2/4：初始化本地仓库${NC}"

# 步骤2：初始化本地Git仓库
if [ -d ".git" ]; then
    echo "本地仓库已存在，跳过初始化"
else
    git init
    git config user.name "$GITHUB_USER"
    read -p "请输入你的GitHub邮箱: " email
    git config user.email "$email"
    echo -e "${GREEN}✓ 本地仓库初始化完成${NC}"
fi

echo ""
echo -e "${YELLOW}步骤3/4：添加文件${NC}"

# 步骤3：添加所有文件
git add .
git status

echo ""
read -p "确认上传以上文件? (y/n): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 1
fi

echo ""
echo -e "${YELLOW}步骤4/4：提交并推送${NC}"

# 步骤4：创建初始提交
git commit -m "Initial commit: DAS系统学习记录 v1.0.0

- 完整的硬件原理讲解（7章）
- 数字信号处理指南（4章）  
- 系统集成与优化（3章）
- 学习路线图和器件清单
- 总计50,000+字技术文档

硬件部分：
- 窄线宽激光器原理与选型
- 光分路器详细分析
- 脉冲调制(AOM/EOM)详细分析
- 光放大器(EDFA)详细分析
- 环形器与光路隔离
- 混频与检测详细分析
- 高速ADC采样详细分析

信号处理部分：
- 数字IQ解调详细分析
- 相位计算与展开详细分析
- Gauge Length差分分析
- 时间差分与振动信号提取

系统集成部分：
- 系统集成与优化
- 完整器件选型清单
- 学习路线图"

# 检查远程仓库是否已存在
if ! git remote get-url origin &>/dev/null; then
    echo "添加远程仓库..."
    git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git
fi

# 修改分支名为main
git branch -M main

# 推送到GitHub
echo "推送到GitHub..."
if git push -u origin main; then
    echo -e "${GREEN}✓ 推送成功${NC}"
else
    echo -e "${YELLOW}⚠ 首次推送可能需要认证${NC}"
    echo "如果要求输入密码，请使用GitHub Personal Access Token"
    echo "创建方法：Settings → Developer settings → Personal access tokens"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ 部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "仓库地址："
echo -e "${BLUE}https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
echo ""
echo "下一步："
echo "1. 访问仓库地址查看文件"
echo "2. 在仓库设置中添加项目主题标签"
echo "3. 将链接分享给他人"
echo ""