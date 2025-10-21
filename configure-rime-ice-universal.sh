#!/bin/bash

# Rime-Ice 通用配置脚本
# 自动检测系统类型并选择相应的配置方式
# 支持 Linux (ibus-rime) 和 macOS (Squirrel)

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
RIME_ICE_REPO="https://gh-proxy.com/https://github.com/iDvel/rime-ice.git"
PROTECTED_FILES=("default.yaml" "squirrel.yaml" "weasel.yaml")
TEMP_DIR="/tmp/rime-ice-temp"

# 系统特定配置
declare -A SYSTEM_CONFIG

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

# 检测系统类型并设置配置
detect_system() {
    log_info "检测系统类型..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS系统
        SYSTEM_CONFIG[type]="macos"
        SYSTEM_CONFIG[config_dir]="$HOME/Library/Rime"
        SYSTEM_CONFIG[input_method]="Squirrel"
        SYSTEM_CONFIG[check_cmd]="[ -f \"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel\" ]"
        SYSTEM_CONFIG[reload_cmd]="/Library/Input\\ Methods/Squirrel.app/Contents/MacOS/Squirrel --reload"
        log_success "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux系统
        SYSTEM_CONFIG[type]="linux"
        SYSTEM_CONFIG[config_dir]="$HOME/.config/ibus/rime"
        SYSTEM_CONFIG[input_method]="ibus-rime"
        SYSTEM_CONFIG[check_cmd]="dpkg -l | grep -q ibus-rime"
        SYSTEM_CONFIG[reload_cmd]="ibus restart"
        log_success "检测到 Linux 系统"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
        # Windows系统 (Git Bash, Cygwin, WSL等)
        SYSTEM_CONFIG[type]="windows"
        SYSTEM_CONFIG[config_dir]="$APPDATA/Rime"
        SYSTEM_CONFIG[input_method]="小狼毫(Weasel)"
        SYSTEM_CONFIG[check_cmd]="[ -d \"$APPDATA/Rime\" ]"
        SYSTEM_CONFIG[reload_cmd]="weasel /deploy"
        log_success "检测到 Windows 系统"
    else
        log_error "不支持的操作系统: $OSTYPE"
        log_info "支持的系统: macOS, Linux, Windows"
        exit 1
    fi
    
    log_info "输入法框架: ${SYSTEM_CONFIG[input_method]}"
    log_info "配置目录: ${SYSTEM_CONFIG[config_dir]}"
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查git是否安装
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 git"
        if [[ "${SYSTEM_CONFIG[type]}" == "macos" ]]; then
            log_info "macOS安装方法："
            log_info "1. 安装 Xcode Command Line Tools: xcode-select --install"
            log_info "2. 使用 Homebrew: brew install git"
        else
            log_info "Linux安装方法："
            log_info "sudo apt install git  # Ubuntu/Debian"
            log_info "sudo yum install git  # CentOS/RHEL"
        fi
        exit 1
    fi
    
    # 检查输入法框架
    if ! eval "${SYSTEM_CONFIG[check_cmd]}"; then
        log_warning "未检测到 ${SYSTEM_CONFIG[input_method]}，请确保已正确安装"
        if [[ "${SYSTEM_CONFIG[type]}" == "macos" ]]; then
            log_info "Squirrel下载地址："
            log_info "https://github.com/rime/squirrel/releases"
        else
            log_info "安装ibus-rime："
            log_info "sudo apt install ibus-rime  # Ubuntu/Debian"
        fi
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log_success "依赖检查完成"
}

# 创建rime配置目录
create_rime_dir() {
    log_info "创建rime配置目录..."
    mkdir -p "${SYSTEM_CONFIG[config_dir]}"
    log_success "rime配置目录已创建: ${SYSTEM_CONFIG[config_dir]}"
}

# 检查rime-ice是否已配置
check_rime_ice_status() {
    log_info "检查rime-ice配置状态..."
    
    # 检查rime-ice特有的文件来判断是否已配置
    if [ -d "${SYSTEM_CONFIG[config_dir]}" ] && [ -f "${SYSTEM_CONFIG[config_dir]}/rime_ice.dict.yaml" ]; then
        log_info "检测到rime-ice已配置"
        return 0  # 已配置
    else
        log_info "rime-ice未配置"
        return 1  # 未配置
    fi
}

# 备份受保护的文件
backup_protected_files() {
    log_info "备份受保护的文件..."
    
    for file in "${PROTECTED_FILES[@]}"; do
        if [ -f "${SYSTEM_CONFIG[config_dir]}/$file" ]; then
            cp "${SYSTEM_CONFIG[config_dir]}/$file" "${SYSTEM_CONFIG[config_dir]}/$file.backup.$(date +%Y%m%d_%H%M%S)"
            log_info "已备份: $file"
        fi
    done
}

# 克隆rime-ice仓库
clone_rime_ice() {
    log_info "克隆rime-ice仓库..."
    
    # 清理临时目录
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # 克隆仓库
    git clone "$RIME_ICE_REPO" "$TEMP_DIR"
    
    if [ $? -eq 0 ]; then
        log_success "rime-ice仓库克隆成功"
    else
        log_error "rime-ice仓库克隆失败"
        exit 1
    fi
}

# 安装rime-ice文件
install_rime_ice() {
    log_info "安装rime-ice文件..."
    
    # 复制所有文件到rime配置目录
    cp -r "$TEMP_DIR"/* "${SYSTEM_CONFIG[config_dir]}/"
    
    # 恢复受保护的文件
    for file in "${PROTECTED_FILES[@]}"; do
        backup_file=$(ls "${SYSTEM_CONFIG[config_dir]}/$file.backup."* 2>/dev/null | tail -1)
        if [ -n "$backup_file" ] && [ -f "$backup_file" ]; then
            cp "$backup_file" "${SYSTEM_CONFIG[config_dir]}/$file"
            log_info "已恢复受保护文件: $file"
        fi
    done
    
    log_success "rime-ice文件安装完成"
}

# 更新rime-ice
update_rime_ice() {
    log_info "更新rime-ice配置..."
    
    # 备份受保护的文件
    backup_protected_files
    
    # 克隆最新版本
    clone_rime_ice
    
    # 安装文件
    install_rime_ice
    
    log_success "rime-ice更新完成"
}

# 重新加载输入法配置
reload_input_method() {
    log_info "重新加载${SYSTEM_CONFIG[input_method]}配置..."
    
    if [[ "${SYSTEM_CONFIG[type]}" == "macos" ]]; then
        # macOS Squirrel重载
        if [ -f "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" ]; then
            "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload 2>/dev/null || {
                log_warning "无法自动重新加载Squirrel，请手动重启Squirrel"
                log_info "或者重新登录系统以生效"
            }
        else
            log_warning "未找到Squirrel应用，请手动重启输入法"
        fi
    elif [[ "${SYSTEM_CONFIG[type]}" == "windows" ]]; then
        # Windows 小狼毫重载
        if command -v weasel &> /dev/null; then
            weasel /deploy 2>/dev/null || {
                log_warning "无法自动重新部署小狼毫，请手动重新部署"
                log_info "右键点击任务栏中的小狼毫图标，选择'重新部署'"
            }
        else
            log_warning "未找到weasel命令，请手动重新部署小狼毫"
            log_info "右键点击任务栏中的小狼毫图标，选择'重新部署'"
        fi
    else
        # Linux ibus重载
        if command -v ibus &> /dev/null; then
            ibus restart 2>/dev/null || {
                log_warning "无法自动重启ibus，请手动重启ibus"
            }
        else
            log_warning "未找到ibus命令，请手动重启输入法"
        fi
    fi
    
    log_success "${SYSTEM_CONFIG[input_method]}配置重新加载完成"
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    rm -rf "$TEMP_DIR"
    log_success "清理完成"
}

# 显示配置信息
show_config_info() {
    log_info "rime-ice配置信息:"
    echo "  系统类型: ${SYSTEM_CONFIG[type]}"
    echo "  配置目录: ${SYSTEM_CONFIG[config_dir]}"
    echo "  输入法框架: ${SYSTEM_CONFIG[input_method]}"
    echo "  受保护文件: ${PROTECTED_FILES[*]}"
    echo ""
    log_info "配置完成后，请重启${SYSTEM_CONFIG[input_method]}或重新登录以生效"
    
    if [[ "${SYSTEM_CONFIG[type]}" == "macos" ]]; then
        log_info "macOS重启Squirrel的方法："
        log_info "1. 在系统偏好设置中禁用并重新启用Squirrel"
        log_info "2. 重新登录系统"
        log_info "3. 重启计算机"
    elif [[ "${SYSTEM_CONFIG[type]}" == "windows" ]]; then
        log_info "Windows重启小狼毫的方法："
        log_info "1. 右键点击任务栏中的小狼毫图标，选择'重新部署'"
        log_info "2. 运行: weasel /deploy"
        log_info "3. 重启计算机"
    else
        log_info "Linux重启ibus的方法："
        log_info "1. 运行: ibus restart"
        log_info "2. 重新登录系统"
        log_info "3. 重启计算机"
    fi
}

# 主函数
main() {
    echo "=========================================="
    echo "    Rime-Ice 通用配置脚本"
    echo "=========================================="
    echo ""
    
    # 检测系统类型
    detect_system
    
    # 检查依赖
    check_dependencies
    
    # 创建rime配置目录
    create_rime_dir
    
    # 检查rime-ice状态
    if check_rime_ice_status; then
        log_info "检测到rime-ice已配置，将进行更新操作"
        read -p "是否继续更新？(Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            log_info "操作已取消"
            exit 0
        fi
        update_rime_ice
    else
        log_info "rime-ice未配置，将进行全新安装"
        read -p "是否继续安装？(Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            log_info "操作已取消"
            exit 0
        fi
        clone_rime_ice
        install_rime_ice
    fi
    
    # 重新加载输入法配置
    reload_input_method
    
    # 清理临时文件
    cleanup
    
    # 显示配置信息
    show_config_info
    
    log_success "rime-ice配置完成！"
}

# 捕获中断信号
trap cleanup EXIT

# 运行主函数
main "$@"
