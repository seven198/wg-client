#!/bin/bash

echo "=============================================="
echo "     WireGuard 客户端一键安装（Debian）"
echo "        支持开机自动启动（可交互）"
echo "=============================================="

# 设置公网IP和端口（内置）
SERVER_IP="34.92.101.179"
SERVER_PORT="51820"

# 设置客户端配置（内置配置文件）
WG_CONFIG="
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.8.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = YOUR_PUBLIC_KEY
PresharedKey = YOUR_PRESHARED_KEY
AllowedIPs = 10.8.0.0/24
Endpoint = ${SERVER_IP}:${SERVER_PORT}
"

# 创建 WireGuard 配置目录（确保目录存在）
mkdir -p /etc/wireguard

# 函数：安装 WireGuard 客户端
install_wg_client() {
    # 写入客户端配置文件
    echo "$WG_CONFIG" > /tmp/wg0-temp.conf

    # 确保目标目录存在
    if [ ! -d "/etc/wireguard" ]; then
        echo "[ERROR] 目标目录 /etc/wireguard 不存在！"
        exit 1
    fi

    # 移动临时配置文件到目标目录
    mv /tmp/wg0-temp.conf /etc/wireguard/wg0.conf
    echo "[INFO] 配置文件写入完成"

    # 设置开机启动
    echo "是否设置开机自启? (Y/n)"
    read -r AUTO_START
    AUTO_START="${AUTO_START:-Y}"

    if [[ "$AUTO_START" == "Y" || "$AUTO_START" == "y" ]]; then
        systemctl enable wg-quick@wg0
        echo "已设置开机自启"
    else
        echo "跳过开机自启设置"
    fi

    # 安装 WireGuard
    apt update -y
    apt install -y wireguard

    # 启动 WireGuard
    systemctl start wg-quick@wg0

    echo "=============================================="
    echo "     WireGuard 客户端安装完成"
    echo "     公网IP: ${SERVER_IP}, 端口: ${SERVER_PORT}"
    echo "=============================================="
}

# 主菜单
menu() {
    echo "=============================================="
    echo "请选择操作:"
    echo "1) 安装 WireGuard 客户端"
    echo "2) 卸载 WireGuard 客户端"
    echo "0) 退出"
    echo "=============================================="
    read -r -p "请输入选项: " op

    case "$op" in
        1) install_wg_client ;;
        2) uninstall_wg_client ;;
        0) exit 0 ;;
        *) echo "无效选项！"; menu ;;
    esac
}

# 执行主菜单
menu
