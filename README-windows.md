# Rime-Ice 配置脚本 (Windows版本)

这是一个用于在Windows系统上配置rime-ice输入法的自动化脚本。

## 前提条件

- Windows 7/8/10/11
- 已安装小狼毫(Weasel)输入法
- 已安装git

## 功能特性

- **系统检测**：自动检测Windows系统
- **智能检测**：自动检测rime-ice是否已配置
- **安全更新**：保护用户自定义的配置文件
- **完整安装**：支持全新安装rime-ice
- **增量更新**：支持更新现有配置
- **自动重载**：自动重新部署小狼毫配置
- **错误处理**：完善的错误处理和用户反馈

## 受保护的文件

脚本会自动保护以下用户配置文件，避免被覆盖：
- `default.yaml`
- `squirrel.yaml` 
- `weasel.yaml`

## 安装小狼毫

如果尚未安装小狼毫输入法，可以从以下地址下载：

**官方下载地址：**
- https://rime.im/download/

**安装步骤：**
1. 下载最新版本的小狼毫安装包
2. 运行安装程序，按照提示完成安装
3. 建议使用默认安装路径，避免路径中包含中文字符
4. 安装完成后，小狼毫会自动添加到系统输入法中

## 使用方法

### 方法1：Windows批处理脚本 (推荐)
```cmd
configure-rime-ice-windows-simple.bat
```

### 方法2：通用脚本 (需要Git Bash或WSL)
```bash
./configure-rime-ice-universal.sh
```

## 脚本功能

### 全新安装
- 如果检测到rime-ice未配置，脚本会：
  - 克隆rime-ice仓库
  - 安装所有配置文件到 `%APPDATA%\Rime\`

### 更新现有配置
- 如果检测到rime-ice已配置，脚本会：
  - 备份受保护的用户文件
  - 更新rime-ice仓库内容
  - 恢复受保护的用户文件
  - 自动重新部署小狼毫配置

## 配置目录

rime配置文件位置：`%APPDATA%\Rime\`

可以通过以下方式快速打开：
1. 按 `Win + R`
2. 输入 `%APPDATA%\Rime`
3. 按回车键

## 重新部署小狼毫的方法

配置完成后，可以通过以下方式重新部署小狼毫：

1. **右键菜单方法：**
   - 右键点击任务栏中的小狼毫图标
   - 选择"重新部署"

2. **命令行方法：**
   ```cmd
   weasel /deploy
   ```

3. **重启系统：**
   - 完全重启Windows系统

## 注意事项

- 脚本会自动备份受保护的文件
- 更新前会询问用户确认
- 临时文件会在完成后自动清理
- 建议在运行前备份重要的rime配置
- 使用GitHub代理加速下载（gh-proxy.com）
- 仅适用于Windows系统

## 故障排除

如果遇到问题：

1. **检查小狼毫是否正确安装**
   - 确认小狼毫在系统输入法列表中
   - 确认配置目录 `%APPDATA%\Rime\` 存在

2. **检查git是否安装**
   - 打开命令提示符，输入 `git --version`
   - 如果提示"不是内部或外部命令"，请安装git

3. **编码问题**
   - 如果出现中文字符乱码，请确保脚本文件使用UTF-8编码保存
   - 或者使用英文版本的脚本（已修复编码问题）

4. **检查网络连接**
   - 确保有网络连接（需要克隆git仓库）
   - 如果网络较慢，脚本会使用GitHub代理

5. **检查文件权限**
   - 确保对 `%APPDATA%\Rime\` 目录有写权限
   - 如果遇到权限问题，请以管理员身份运行脚本

6. **查看脚本输出的错误信息**
   - 脚本会显示详细的错误信息和解决建议

## 依赖检查

脚本会自动检查：
- 系统是否为Windows
- git是否安装
- 小狼毫是否安装（警告提示）
- 网络连接

## 与Linux/macOS版本的区别

- **配置目录**：`%APPDATA%\Rime\` (Windows) vs `~/.config/ibus/rime/` (Linux) vs `~/Library/Rime/` (macOS)
- **输入法框架**：小狼毫(Weasel) (Windows) vs ibus-rime (Linux) vs Squirrel (macOS)
- **重载方式**：weasel /deploy (Windows) vs ibus restart (Linux) vs Squirrel --reload (macOS)
- **系统检测**：增加了Windows系统类型检查
- **脚本格式**：批处理脚本(.bat) vs Shell脚本(.sh)

## 高级用法

### 手动配置rime-ice

如果脚本无法正常工作，可以手动配置：

1. **下载rime-ice：**
   - 访问：https://github.com/iDvel/rime-ice
   - 点击"Code" → "Download ZIP"
   - 解压下载的文件

2. **复制配置文件：**
   - 打开 `%APPDATA%\Rime\` 目录
   - 将rime-ice文件夹中的所有文件复制到此目录
   - 注意保护你的自定义配置文件

3. **重新部署：**
   - 右键点击任务栏中的小狼毫图标
   - 选择"重新部署"

### 使用PowerShell脚本

如果你更喜欢PowerShell，可以创建类似的PowerShell脚本：

```powershell
# PowerShell版本的rime-ice配置脚本
$RimeDir = "$env:APPDATA\Rime"
$RimeIceRepo = "https://gh-proxy.com/https://github.com/iDvel/rime-ice.git"

# 检查git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git未安装，请先安装git"
    exit 1
}

# 克隆rime-ice
git clone $RimeIceRepo "$env:TEMP\rime-ice-temp"

# 复制文件
Copy-Item -Path "$env:TEMP\rime-ice-temp\*" -Destination $RimeDir -Recurse -Force

# 重新部署
& weasel /deploy

# 清理
Remove-Item -Path "$env:TEMP\rime-ice-temp" -Recurse -Force
```
