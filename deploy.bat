@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================================
REM DAS系统学习项目 - Windows自动部署脚本
REM 使用方法：双击运行此文件或在CMD中执行 deploy.bat
REM ============================================================

echo.
echo 🚀 DAS系统学习项目 - GitHub自动部署工具
echo ==================================================
echo.

REM 配置信息
set GITHUB_USER=wangsulong594-create
set REPO_NAME=das-system-learning
set PROJECT_DIR=das-system-learning

REM ============================================================
REM 第一步：检查Git
REM ============================================================
echo 📋 步骤1：检查Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：Git未安装
    echo 请从 https://git-scm.com/download/win 下载安装Git
    pause
    exit /b 1
)
echo ✅ Git已安装
echo.

REM ============================================================
REM 第二步：创建项目目录
REM ============================================================
echo 📁 步骤2：创建项目目录...
if not exist "%PROJECT_DIR%" (
    mkdir "%PROJECT_DIR%"
    echo ✅ 目录已创建
) else (
    echo ⚠️ 目录已存在
)
cd /d "%PROJECT_DIR%"
echo.

REM ============================================================
REM 第三步：创建文件
REM ============================================================
echo 📄 步骤3：生成项目文件...

REM 创建README.md
(
echo # DAS系统学习记录
echo.
echo 这是一个完整的DAS系统学���项目
echo.
echo ## 内容包括
echo - 硬件原理讲解（7章）
echo - 数字信号处理（4章）
echo - 系统集成优化（3章）
echo.
echo 详见各章节文档
) > README.md
echo ✅ README.md已创建

REM 创建LICENSE
(
echo MIT License
echo.
echo Copyright (c) 2026 wangsulong594-create
) > LICENSE
echo ✅ LICENSE已创建

echo.

REM ============================================================
REM 第四步：初���化Git
REM ============================================================
echo 🔧 步骤4：初始化Git仓库...
git init
git config user.name "%GITHUB_USER%"
git config user.email "%GITHUB_USER%@users.noreply.github.com"
echo ✅ Git仓库已初始化
echo.

REM ============================================================
REM 第五步：添加文件
REM ============================================================
echo 📝 步骤5：添加所有文件...
git add .
echo ✅ 文件已添加
echo.

REM ============================================================
REM 第六步：提交
REM ============================================================
echo 💾 步骤6：创建提交...
git commit -m "Initial commit: DAS系统学习记录 v1.0.0"
echo ✅ 提交已创建
echo.

REM ============================================================
REM 第七步：获取Token
REM ============================================================
echo 🔑 步骤7：输入GitHub Personal Access Token
echo 获取Token：https://github.com/settings/tokens
echo.
set /p GITHUB_TOKEN=请输入你的GitHub Token: 

if "!GITHUB_TOKEN!"=="" (
    echo ❌ Token不能为空
    pause
    exit /b 1
)
echo.

REM ============================================================
REM 第八步：添加远程并推送
REM ============================================================
echo 🔗 步骤8：添加远程仓库...
git remote add origin "https://%GITHUB_USER%:%GITHUB_TOKEN%@github.com/%GITHUB_USER%/%REPO_NAME%.git"
echo ✅ 远程仓库已添加
echo.

echo 📤 步骤9：��送到GitHub...
git branch -M main
git push -u origin main

if errorlevel 1 (
    echo ❌ 推送失败
    pause
    exit /b 1
)

echo.
echo ==================================================
echo ✅ 部署成功！
echo ==================================================
echo.
echo 🎉 恭喜！你的项目已经上传到GitHub！
echo.
echo 仓库地址：
echo   https://github.com/%GITHUB_USER%/%REPO_NAME%
echo.
echo 下一步建议：
echo   1. 访问上述链接验证文件
echo   2. 添加项目描述和标签
echo   3. 邀请协作者（可选）
echo.
pause
