// liudq_dns_redirect.js
let domain = "liudq_ubuntu.yuisuki.com";
let specificIP = "192.168.31.2";

// 判断当前是否连接到特定 Wi-Fi 网络
function isOnSpecificWifi() {
    return $network.wifi.ssid === "liudq";
}

// 处理 DNS 请求
function onRequest(request) {
    // 如果连接在特定 Wi-Fi 网络上，并请求的域名匹配
    if (isOnSpecificWifi() && request.hostname === domain) {
        // 返回指定的 IP 地址
        return {
            addresses: [specificIP],
            ttl: 600
        };
    }

    // 否则，返回 false 让 Surge 进行默认 DNS 解析
    return false;
}

// 监听 DNS 请求事件
$dns.listen((request) => {
    let response = onRequest(request);
    if (response) {
        // 回应 DNS 请求
        $dns.resolve(response);
    } else {
        // 使用默认的 DNS 解析
        $dns.resolve($dns.SYSTEM);
    }
});
