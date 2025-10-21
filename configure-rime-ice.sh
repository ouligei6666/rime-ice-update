#!/bin/bash

# Rime-Ice 配置脚本
# 用于在Linux系统上配置或更新rime-ice输入法
# 前提：已安装ibus-rime

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
RIME_ICE_REPO="https://gh-proxy.com/https://github.com/iDvel/rime-ice.git"
RIME_CONFIG_DIR="$HOME/.config/ibus/rime" #如果是fcitx5，改成$HOME/.local/share/fcitx5/rime
PROTECTED_FILES=("default.yaml" "squirrel.yaml" "weasel.yaml")
TEMP_DIR="/tmp/rime-ice-temp"

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

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查git是否安装
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 git"
        exit 1
    fi
    
    # 检查ibus-rime是否安装
    if ! dpkg -l | grep -q ibus-rime 2>/dev/null; then
        log_warning "未检测到 ibus-rime，请确保已正确安装"
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
    mkdir -p "$RIME_CONFIG_DIR"
    log_success "rime配置目录已创建: $RIME_CONFIG_DIR"
}

# 检查rime-ice是否已配置
check_rime_ice_status() {
    log_info "检查rime-ice配置状态..."
    
    # 检查rime-ice特有的文件来判断是否已配置
    if [ -d "$RIME_CONFIG_DIR" ] && [ -f "$RIME_CONFIG_DIR/rime_ice.dict.yaml" ]; then
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
        if [ -f "$RIME_CONFIG_DIR/$file" ]; then
            cp "$RIME_CONFIG_DIR/$file" "$RIME_CONFIG_DIR/$file.backup.$(date +%Y%m%d_%H%M%S)"
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
    cp -r "$TEMP_DIR"/* "$RIME_CONFIG_DIR/"
    
    # 恢复受保护的文件
    for file in "${PROTECTED_FILES[@]}"; do
        backup_file=$(ls "$RIME_CONFIG_DIR/$file.backup."* 2>/dev/null | tail -1)
        if [ -n "$backup_file" ] && [ -f "$backup_file" ]; then
            cp "$backup_file" "$RIME_CONFIG_DIR/$file"
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

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    rm -rf "$TEMP_DIR"
    log_success "清理完成"
}

# 显示配置信息
show_config_info() {
    log_info "rime-ice配置信息:"
    echo "  配置目录: $RIME_CONFIG_DIR"
    echo "  受保护文件: ${PROTECTED_FILES[*]}"
    echo ""
    log_info "配置完成后，请重启ibus或重新登录以生效"
}

# 主函数
main() {
    echo "=========================================="
    echo "    Rime-Ice 配置脚本"
    echo "=========================================="
    echo ""
    
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
