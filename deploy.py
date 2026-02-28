#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
DAS系统学习项目 - GitHub自动部署工具
跨平台支持：Windows、Mac、Linux
使用方法：python deploy.py
"""

import os
import sys
import subprocess
import getpass
from pathlib import Path

# 颜色定义（兼容Windows）
class Colors:
    if sys.platform == 'win32':
        GREEN = ''
        RED = ''
        YELLOW = ''
        NC = ''
    else:
        GREEN = '\033[0;32m'
        RED = '\033[0;31m'
        YELLOW = '\033[1;33m'
        NC = '\033[0m'

def print_success(msg):
    print(f"{Colors.GREEN}✅ {msg}{Colors.NC}")

def print_error(msg):
    print(f"{Colors.RED}❌ {msg}{Colors.NC}")

def print_warning(msg):
    print(f"{Colors.YELLOW}⚠️  {msg}{Colors.NC}")

def print_header(msg):
    print("\n" + "="*50)
    print(msg)
    print("="*50 + "\n")

def run_command(cmd, check=True):
    """运行命令并返回结果"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=check)
        return result.returncode == 0
    except Exception as e:
        print_error(f"命令执行失败：{e}")
        return False

def check_prerequisites():
    """检查前置条件"""
    print_header("📋 步骤1：检查前置条件")
    
    # 检查Git
    if not run_command("git --version", check=False):
        print_error("Git未安装")
        print("请从 https://git-scm.com/download 下载安装Git")
        sys.exit(1)
    print_success("Git已安装")

def create_project_directory(project_dir):
    """创建项目目录"""
    print_header("📁 步骤2：创建项目目录")
    
    if os.path.exists(project_dir):
        print_warning(f"目录 {project_dir} 已存在")
    else:
        os.makedirs(project_dir)
        print_success(f"目录已创建：{project_dir}")
    
    os.chdir(project_dir)

def create_readme():
    """创建README.md"""
    readme_content = """# DAS系统学习记录 📚

**作者**：wangsulong594-create  
**开始时间**：2026年2月28日  
**项目状态**：🚀 进行中

## 项目简介

这是一个**从硬件到软件、从0到1**的DAS（分布式声波传感）系统完整学习记录。

## 核心内容

### 第一部分：硬件基础（7章）
1. 窄线宽激光器原理与选型
2. 光分路器详细分析
3. 脉冲调制(AOM/EOM)详细分析
4. 光放大器(EDFA)详细分析
5. 环形器与光路隔离
6. 混频与检测详细分析
7. 高速ADC采样详细分析

### 第二部分：数字信号处理（4章）
8. 数字IQ解调详细分析
9. 相位计算与展开详细分析
10. Gauge Length差分分析
11. 时间差分与振动信号提取

### 第三部分：系统集成（3章）
12. 系统集成与优化
13. 完整器件选型清单
14. 学习路线图

## 许可证

MIT License - 自由使用和修改

---

**最后更新**：2026年2月28日  
**版本**：v1.0.0
"""
    with open('README.md', 'w', encoding='utf-8') as f:
        f.write(readme_content)
    print_success("README.md已创建")

def create_license():
    """创建MIT许可证"""
    license_content = """MIT License

Copyright (c) 2026 wangsulong594-create

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
    with open('LICENSE', 'w', encoding='utf-8') as f:
        f.write(license_content)
    print_success("LICENSE已创建")

def create_gitignore():
    """创建.gitignore"""
    gitignore_content = """# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# MATLAB
*.mat
*.asv

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Data files
*.csv
*.xlsx
*.xls
"""
    with open('.gitignore', 'w', encoding='utf-8') as f:
        f.write(gitignore_content)
    print_success(".gitignore已创建")

def initialize_git(github_user):
    """初始化Git仓库"""
    print_header("🔧 步骤3：初始化Git仓库")
    
    run_command("git init")
    run_command(f'git config user.name "{github_user}"')
    run_command(f'git config user.email "{github_user}@users.noreply.github.com"')
    
    print_success("Git仓库已初始化")

def add_and_commit():
    """添加文件并提交"""
    print_header("💾 步骤4：添加文件并提交")
    
    run_command("git add .")
    commit_msg = """Initial commit: DAS系统学习记录 v1.0.0

- 完整的硬件原理讲解
- 数字信号处理指南  
- 系统集成与优化
- 学习路线图和器件清单
- 总计50,000+字技术文档"""
    
    run_command(f'git commit -m "{commit_msg}"')
    print_success("提交已创建")

def add_remote_and_push(github_user, repo_name, github_token):
    """添加远程仓库并推送"""
    print_header("📤 步骤5：推送到GitHub")
    
    remote_url = f"https://{github_user}:{github_token}@github.com/{github_user}/{repo_name}.git"
    
    run_command(f'git remote add origin "{remote_url}"')
    run_command("git branch -M main")
    
    if run_command("git push -u origin main"):
        print_success("推送成功！")
        print("\n🎉 恭喜！你的项目已经上传到GitHub！\n")
        print(f"仓库地址：https://github.com/{github_user}/{repo_name}\n")
        return True
    else:
        print_error("推送失败")
        return False

def main():
    """主函数"""
    print("\n🚀 DAS系统学习项目 - GitHub自动部署工具\n")
    
    # 配置信息
    github_user = "wangsulong594-create"
    repo_name = "das-system-learning"
    project_dir = "das-system-learning"
    
    # 第一步：检查前置条件
    check_prerequisites()
    
    # 第二步：创建项目目录
    create_project_directory(project_dir)
    
    # 第三步：创建文件
    print_header("📄 步骤3：生成项目文件")
    create_readme()
    create_license()
    create_gitignore()
    
    # 第四步：初始化Git
    initialize_git(github_user)
    
    # 第五步：添加并提交
    add_and_commit()
    
    # 第六步：获取Token
    print_header("🔑 步骤6：输入GitHub Personal Access Token")
    print("获取Token：https://github.com/settings/tokens")
    print("权限选择：repo (所有repo权限)\n")
    
    github_token = getpass.getpass("请输入你的GitHub Token（不会显示）: ")
    
    if not github_token:
        print_error("Token不能为空")
        sys.exit(1)
    
    # 第七步：推送
    if add_remote_and_push(github_user, repo_name, github_token):
        print("\n✨ 部署完成！")
        print(f"下一步：访问 https://github.com/{github_user}/{repo_name} 查看你的项目\n")
    else:
        print("\n⚠️  推送失败，请检查Token并重试\n")
        sys.exit(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  操作已取消")
        sys.exit(1)
    except Exception as e:
        print_error(f"发生错误：{e}")
        sys.exit(1)
