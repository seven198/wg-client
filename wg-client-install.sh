#!/bin/bash

# 1. 安装 WireGuard
install_wireguard() {
    echo "正在更新软件包..."
    sudo apt update
    sudo apt upgrade -y

    echo "正在安装 WireGuard 工具..."
    sudo apt install -y wireguard-tools

    echo "WireGuard 工具已安装！"
}

# 2. 配置 WireGuard 文件
configure_wireguard() {
    # 复制配置文件到 /etc/wireguard 目录
    echo "正在复制配置文件到 /etc/wireguard/"
    sudo cp /boot/debian13.conf /etc/wireguard/

    # 设置文件权限
    echo "设置文件权限为 600"
    sudo chmod 600 /etc/wireguard/debian13.conf

    # 删除 IPv6，保留 IPv4，并配置为 10.8.0.0/24
    echo "配置 IPv4 地址，删除 IPv6 地址..."
    sudo sed -i 's/AllowedIPs = .*::\/0/AllowedIPs = 10.8.0.0\/24/' /etc/wireguard/debian13.conf

    # 确保文件权限为 root 用户读写
    echo "验证文件权限"
    ls -l /etc/wireguard/debian13.conf
    echo "配置文件已复制并授权成功！"
}

# 3. 配置自启动
enable_autostart() {
    echo "配置 WireGuard 开机自启..."
    sudo systemctl enable wg-quick@debian13
    echo "WireGuard 开机自启已启用！"
}

# 4. 启动 WireGuard 连接
start_wireguard() {
    echo "启动 WireGuard 连接..."
    sudo wg-quick up debian13
    echo "WireGuard 连接已启动！"
}

# 5. 验证连接状态
check_status() {
    echo "验证连接状态..."
    sudo wg
}

# 6. 拆卸 WireGuard 和清除残留
uninstall_wireguard() {
    echo "正在卸载 WireGuard..."
    sudo wg-quick down debian13
    sudo apt remove --purge -y wireguard-tools

    # 删除 /etc/wireguard 目录及其内容
    echo "删除 WireGuard 配置目录..."
    sudo rm -rf /etc/wireguard

    # 删除 /boot 目录中的配置文件（如果存在）
    sudo rm -f /boot/debian13.conf

    echo "WireGuard 已卸载，所有配置文件已删除！"
}

# 主要执行
echo "请选择操作："
echo "1. 安装并配置 WireGuard"
echo "2. 启动 WireGuard 连接"
echo "3. 启用开机自启"
echo "4. 验证连接状态"
echo "5. 卸载 WireGuard"

read -p "请输入操作编号: " option

case $option in
    1)
        install_wireguard
        configure_wireguard
        enable_autostart
        start_wireguard
        check_status
        ;;
    2)
        start_wireguard
        check_status
        ;;
    3)
        enable_autostart
        ;;
    4)
        check_status
        ;;
    5)
        uninstall_wireguard
        ;;
    *)
        echo "无效选项，请重新选择。"
        ;;
esac
