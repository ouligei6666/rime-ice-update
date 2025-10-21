# Rime-Ice 配置脚本集合

这是一套用于在不同操作系统上配置rime-ice输入法的自动化脚本集合。

## 脚本列表

### 1. `configure-rime-ice.sh` - Linux版本
- **适用系统**: Linux (Ubuntu/Debian等)
- **输入法框架**: ibus-rime
- **配置目录**: `~/.config/ibus/rime/`

### 2. `configure-rime-ice-macos.sh` - macOS版本
- **适用系统**: macOS
- **输入法框架**: Squirrel (鼠须管)
- **配置目录**: `~/Library/Rime/`

### 3. `configure-rime-ice-windows-simple.bat` - Windows版本
- **适用系统**: Windows 7/8/10/11
- **输入法框架**: 小狼毫(Weasel)
- **配置目录**: `%APPDATA%\Rime\`

### 4. `configure-rime-ice-universal.sh` - 通用版本 ⭐
- **适用系统**: Linux + macOS + Windows
- **输入法框架**: 自动检测 (ibus-rime / Squirrel / Weasel)
- **配置目录**: 自动检测
- **推荐使用**: 此脚本可以自动检测系统类型并选择相应的配置方式

## 功能特性

- **智能检测**：自动检测rime-ice是否已配置
- **安全更新**：保护用户自定义的配置文件
- **完整安装**：支持全新安装rime-ice
- **增量更新**：支持更新现有配置
- **错误处理**：完善的错误处理和用户反馈
- **GitHub代理**：使用gh-proxy.com加速下载

## 受保护的文件

所有脚本都会自动保护以下用户配置文件，避免被覆盖：
- `default.yaml`
- `squirrel.yaml` 
- `weasel.yaml`

## 快速开始

### 推荐方式（通用脚本）
```bash
# 下载并运行通用脚本
./configure-rime-ice-universal.sh
```

### 特定系统方式
```bash
# Linux系统
./configure-rime-ice.sh

# macOS系统  
./configure-rime-ice-macos.sh

# Windows系统
configure-rime-ice-windows-simple.bat
```

## 系统要求

### Linux系统
- Linux发行版 (推荐Ubuntu/Debian)
- GNOME桌面环境
- 已安装ibus-rime
- 已安装git

### macOS系统
- macOS 10.12+
- 已安装Squirrel输入法
- 已安装git

### Windows系统
- Windows 7/8/10/11
- 已安装小狼毫(Weasel)输入法
- 已安装git

## 安装输入法框架

### Linux - 安装ibus-rime
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ibus-rime

# 启用ibus
ibus-setup
```

### macOS - 安装Squirrel
1. 访问: https://github.com/rime/squirrel/releases
2. 下载最新版本的Squirrel.dmg
3. 安装并添加到系统偏好设置

### Windows - 安装小狼毫
1. 访问: https://rime.im/download/
2. 下载最新版本的小狼毫安装包
3. 运行安装程序，按照提示完成安装

## 使用方法

1. **确保满足系统要求**
2. **选择适合的脚本运行**
3. **按照提示操作**
4. **重启输入法或重新登录以生效**

## 脚本工作流程

### 全新安装
1. 检查系统依赖
2. 创建rime配置目录
3. 克隆rime-ice仓库
4. 安装所有配置文件
5. 重新加载输入法

### 更新现有配置
1. 检查系统依赖
2. 备份受保护的用户文件
3. 克隆最新版本rime-ice
4. 安装配置文件
5. 恢复受保护的用户文件
6. 重新加载输入法

## 故障排除

### 常见问题

1. **Git未安装**
   - Linux: `sudo apt install git`
   - macOS: `xcode-select --install` 或 `brew install git`

2. **输入法框架未安装**
   - Linux: 安装ibus-rime
   - macOS: 安装Squirrel

3. **网络连接问题**
   - 脚本使用GitHub代理加速下载
   - 确保网络连接正常

4. **权限问题**
   - 确保对配置目录有写权限
   - Linux: `~/.config/ibus/rime/`
   - macOS: `~/Library/Rime/`

### 重启输入法

**Linux (ibus):**
```bash
ibus restart
```

**macOS (Squirrel):**
- 系统偏好设置 → 键盘 → 输入法 → 重新启用Squirrel
- 或重新登录系统

**Windows (小狼毫):**
- 右键点击任务栏中的小狼毫图标，选择"重新部署"
- 或运行: `weasel /deploy`

## 注意事项

- 脚本会自动备份受保护的文件
- 更新前会询问用户确认
- 临时文件会在完成后自动清理
- 建议在运行前备份重要的rime配置
- 使用GitHub代理加速下载

## 文件结构

```
rime-ice-update/
├── configure-rime-ice.sh              # Linux版本
├── configure-rime-ice-macos.sh         # macOS版本
├── configure-rime-ice-windows-simple.bat # Windows版本
├── configure-rime-ice-universal.sh     # 通用版本 ⭐
├── README.md                           # 总体说明
├── README-macos.md                    # macOS详细说明
└── README-windows.md                  # Windows详细说明
```

## 版本历史

- **v1.0**: 初始Linux版本
- **v1.1**: 添加macOS支持
- **v1.2**: 添加通用版本，支持自动检测系统类型
- **v1.3**: 优化错误处理和用户反馈
- **v1.4**: 添加Windows支持，支持小狼毫(Weasel)输入法