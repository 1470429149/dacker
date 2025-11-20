#!/bin/bash
#
# Config encryption script
# 在构建 Docker 镜像前使用此脚本加密您的 config.json
#
# 使用方法:
#   ./encrypt_config.sh [加密密钥]
#
# 如果不提供加密密钥,将使用默认密钥 (不推荐)
#

# 加密密钥
ENCRYPTION_KEY="${1:-default_encryption_key_change_me}"

# 配置文件路径
PLAIN_CONFIG="config.json"
ENCRYPTED_CONFIG="config.json.enc"

# 检查原始配置文件是否存在
if [ ! -f "$PLAIN_CONFIG" ]; then
    echo "Error: Config file $PLAIN_CONFIG not found"
    exit 1
fi

# 验证是否为有效的 JSON
if ! grep -q '{' "$PLAIN_CONFIG" || ! grep -q '}' "$PLAIN_CONFIG"; then
    echo "Error: $PLAIN_CONFIG does not appear to be valid JSON"
    exit 1
fi

# 使用 OpenSSL 加密配置文件
# 使用 AES-256-CBC 加密算法
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 \
    -in "$PLAIN_CONFIG" \
    -out "$ENCRYPTED_CONFIG" \
    -k "$ENCRYPTION_KEY"

if [ $? -eq 0 ]; then
    echo "✓ Config encrypted successfully: $ENCRYPTED_CONFIG"
    echo ""
    echo "重要提示:"
    echo "1. 构建 Docker 镜像时会使用 $ENCRYPTED_CONFIG"
    echo "2. 运行容器时需要设置环境变量: -e CONFIG_KEY='$ENCRYPTION_KEY'"
    echo "3. 请妥善保管您的加密密钥,丢失后无法恢复配置!"
    echo ""
    echo "示例运行命令:"
    echo "docker run -d -e CONFIG_KEY='$ENCRYPTION_KEY' your-image:tag"
else
    echo "Error: Failed to encrypt config file"
    exit 1
fi
