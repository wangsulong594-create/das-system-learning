#!/bin/bash

# DAS系统学习项目 - GitHub上传脚本
# 使用方法：chmod +x upload_to_github.sh && ./upload_to_github.sh

echo "🚀 开始上传DAS系统学习项目到GitHub..."
echo ""

# 配置信息
GITHUB_USER="wangsulong594-create"
REPO_NAME="das-system-learning"
BRANCH="main"

# 1. 初始化本地仓库
echo "📁 步骤1：初始化本地仓库..."
git init
git config user.name "$GITHUB_USER"
git config user.email "your-email@example.com"  # 请修改为你的email

# 2. 添加所有文件
echo "📝 步骤2：添加所有文件..."
git add .

# 3. 创建第一次提交
echo "✍️ 步骤3：创建初始提交..."
git commit -m "Initial commit: DAS系统学习记录 v1.0.0

- 完整的硬件原理讲解（7章）
- 数字信号处理指南（4章）  
- 系统集成与优化（3章）
- 学习路线图和器件清单
- 总计50,000+字技术文档"

# 4. 添加远程仓库
echo "🔗 步骤4：添加远程仓库..."
git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git
git branch -M $BRANCH

# 5. 推送到GitHub
echo "📤 步骤5：推送到GitHub..."
git push -u origin $BRANCH

echo ""
echo "✅ 上传完成！"
echo "🌐 仓库地址：https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "下一步：在GitHub网页上验证文件是否已上传"