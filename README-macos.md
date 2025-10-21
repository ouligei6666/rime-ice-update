# Rime-Ice 配置脚本 (macOS版本)

这是一个用于在macOS系统上配置rime-ice输入法的自动化脚本。

## 前提条件

- macOS系统
- 已安装Squirrel（鼠须管）输入法
- 已安装git

## 功能特性

- **系统检测**：自动检测macOS系统
- **智能检测**：自动检测rime-ice是否已配置
- **安全更新**：保护用户自定义的配置文件
- **完整安装**：支持全新安装rime-ice
- **增量更新**：支持更新现有配置
- **自动重载**：自动重新加载Squirrel配置
- **错误处理**：完善的错误处理和用户反馈

## 受保护的文件

脚本会自动保护以下用户配置文件，避免被覆盖：
- `default.yaml`
- `squirrel.yaml` 
- `weasel.yaml`

## 安装Squirrel

如果尚未安装Squirrel输入法，可以从以下地址下载：

**官方下载地址：**
- https://github.com/rime/squirrel/releases

**安装步骤：**
1. 下载最新版本的Squirrel.dmg
2. 双击安装包，将Squirrel.app拖拽到Applications文件夹
3. 在系统偏好设置 → 键盘 → 输入法中添加Squirrel

## 使用方法

1. 确保满足前提条件
2. 运行脚本：
   ```bash
   ./configure-rime-ice-macos.sh
   ```
3. 按照提示操作
4. 重启Squirrel或重新登录以生效

## 脚本功能

### 全新安装
- 如果检测到rime-ice未配置，脚本会：
  - 克隆rime-ice仓库
  - 安装所有配置文件到 `~/Library/Rime/`

### 更新现有配置
- 如果检测到rime-ice已配置，脚本会：
  - 备份受保护的用户文件
  - 更新rime-ice仓库内容
  - 恢复受保护的用户文件
  - 自动重新加载Squirrel配置

## 配置目录

rime配置文件位置：`~/Library/Rime/`

## 重启Squirrel的方法

配置完成后，可以通过以下方式重启Squirrel：

1. **系统偏好设置方法：**
   - 系统偏好设置 → 键盘 → 输入法
   - 取消勾选Squirrel，然后重新勾选

2. **重新登录：**
   - 注销并重新登录用户账户

3. **重启系统：**
   - 完全重启macOS系统

## 注意事项

- 脚本会自动备份受保护的文件
- 更新前会询问用户确认
- 临时文件会在完成后自动清理
- 建议在运行前备份重要的rime配置
- 使用GitHub代理加速下载（gh-proxy.com）
- 仅适用于macOS系统

## 故障排除

如果遇到问题：

1. **检查Squirrel是否正确安装**
   - 确认Squirrel.app在Applications文件夹中
   - 确认在系统偏好设置中已启用Squirrel

2. **检查网络连接**
   - 确保有网络连接（需要克隆git仓库）
   - 如果网络较慢，脚本会使用GitHub代理

3. **检查文件权限**
   - 确保对`~/Library/Rime/`目录有写权限

4. **查看脚本输出的错误信息**
   - 脚本会显示详细的错误信息和解决建议

## 依赖检查

脚本会自动检查：
- 系统是否为macOS
- git是否安装
- Squirrel是否安装（警告提示）
- 网络连接

## 与Linux版本的区别

- **配置目录**：`~/Library/Rime/` (macOS) vs `~/.config/ibus/rime/` (Linux)
- **输入法框架**：Squirrel (macOS) vs ibus-rime (Linux)
- **重载方式**：Squirrel --reload (macOS) vs ibus restart (Linux)
- **系统检测**：增加了macOS系统类型检查
