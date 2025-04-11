#!/bin/bash
# 配置 Cloudflare API 凭证
EMAIL="p595207742r@gmail.com"
API_KEY="a5888173a44343cb001f0f674e012872c8f0d"
DOMAIN="crackcie.com"
TARGET_FILE="rule_base/direct_domain.list"
TEMP_FILE=$(mktemp)

# 获取 Zone ID（参考网页1/4/6的认证方式）
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
  -H "X-Auth-Email: $EMAIL" \
  -H "X-Auth-Key: $API_KEY" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

# 生成IP列表（结合网页2/7的DNS记录获取思路）
curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=1000" \
  -H "X-Auth-Email: $EMAIL" \
  -H "X-Auth-Key: $API_KEY" \
  | jq -r '.result[] | select(.type == "A" or .type == "AAAA") | .content' \
  | sort -u \
  | while read ip; do
      [[ $ip =~ : ]] && echo "IP-CIDR6,$ip/128" || echo "IP-CIDR,$ip/32"
    done > "$TEMP_FILE"

# 动态更新文件（参考网页5/6的自动化思路）
if grep -q "#Start" "$TARGET_FILE"; then
  # 替换现有段落
  sed -i "/#Start/,/#End/{
    /#Start/!{/#End/!d}
    /#Start/r $TEMP_FILE
  }" "$TARGET_FILE"
else
  # 新增段落（参考网页3的配置格式）
  {
    echo -e "#Start\n# 自用可直连IP"
    cat "$TEMP_FILE"
    echo -e "#End\n"
  } >> "$TARGET_FILE"
fi

rm -f "$TEMP_FILE"
echo "IP列表已更新到：$TARGET_FILE"