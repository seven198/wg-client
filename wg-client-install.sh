#!/bin/bash

set -e

echo "=============================================="
echo "     WireGuard 客户端一键安装（Debian）"
echo "        支持开机自动启动（可交互）"
echo "=============================================="
echo

# root 检查
if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 权限执行：sudo bash wg-client-install.sh"
    exit 1
fi

# 输入服务器配置
read -p "请输入服务器公网 IP: " WG_SERVER_IP
read -p "请输入服务器端口（默认 51820）: " WG_PORT
WG_PORT=${WG_PORT:-51820}

echo
echo "请将 WG-Easy 为你生成的客户端配置粘贴到下面："
echo "(粘贴完按 Ctrl + D 结束输入)"
echo

CLIENT_CONF=$(cat)

if [[ -z "$CLIENT_CONF" ]]; then
    echo "错误：未输入配置文件内容！"
    exit 1
fi

echo
echo "=================================================="
echo "[1] 安装 WireGuard 所需组件（wireguard + resolvconf）..."
apt update -y
apt install -y wireguard resolvconf

echo "=================================================="
echo "[2] 写入 /etc/wireguard/wg0.conf"

mkdir -p /etc/wireguard
echo "$CLIENT_CONF" > /etc/wireguard/wg0.conf

echo "→ 强制设置 AllowedIPs = 10.8.0.0/24（分流，仅走虚拟局域网）"
sed -i "s|AllowedIPs = .*|AllowedIPs = 10.8.0.0/24|g" /etc/wireguard/wg0.conf

echo "→ 设置 Endpoint = ${WG_SERVER_IP}:${WG_PORT}"
sed -i "s|Endpoint = .*|Endpoint = ${WG_SERVER_IP}:${WG_PORT}|g" /etc/wireguard/wg0.conf

chmod 600 /etc/wireguard/wg0.conf

echo "=================================================="
echo "[3] 启动 WireGuard..."

if wg-quick up wg0; then
    echo "WireGuard 启动成功！"
else
    echo "❌ 启动失败，请检查配置文件"
    exit 1
fi

echo "=================================================="
echo "[4] 开机自动启动设置"

read -p "是否设置 wg0 开机自动启动？(Y/n): " AUTO_START
AUTO_START=${AUTO_START:-Y}

if [[ "$AUTO_START" == "Y" || "$AUTO_START" == "y" ]]; then
    systemctl enable wg-quick@wg0
    echo "✔ 已启用开机自启"
else
    echo "跳过开机自启设置"
fi

echo "=================================================="
echo "[5] 连通性检测（ping 10.8.0.1）..."

sleep 1
ping -c 2 10.8.0.1 || echo "⚠ 无法 ping 10.8.0.1，可能服务器端未放行"

WG_IP=$(ip -4 addr show wg0 | grep inet | awk '{print $2}')
echo "当前客户端 WireGuard IP：$WG_IP"

echo
echo "=================================================="
echo "🎉 WireGuard 客户端安装完成（分流模式）"
echo "✔ AllowedIPs = 10.8.0.0/24（仅走虚拟局域网）"
echo "✔ 配置文件：/etc/wireguard/wg0.conf"
echo
echo "👉 常用命令："
echo "启动： wg-quick up wg0"
echo "停止： wg-quick down wg0"
echo "状态： wg show"
echo "=================================================="
