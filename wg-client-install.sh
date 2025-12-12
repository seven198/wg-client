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

# 函数：安装 WireGuard 客户端
install_wg_client() {
    # 写入客户端配置文件
    echo "$WG_CONFIG" > /etc/wireguard/wg0.conf

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

# 函数：卸载 WireGuard 客户端
uninstall_wg_client() {
    echo "=============================================="
    echo "     开始卸载 WireGuard 客户端"
    echo "=============================================="

    # 停止 WireGuard 服务
    systemctl stop wg-quick@wg0

    # 禁用开机自启
    systemctl disable wg-quick@wg0

    # 删除 WireGuard 配置文件
    rm -f /etc/wireguard/wg0.conf

    # 卸载 WireGuard
    apt remove -y wireguard
    apt purge -y wireguard

    # 清理残留文件
    rm -rf /etc/wireguard
    echo "WireGuard 客户端卸载完成"

    # 清理自启文件
    rm -f /etc/systemd/system/wg-quick@wg0.service
    rm -f /usr/local/bin/wd
    echo "所有相关文件已删除"
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
