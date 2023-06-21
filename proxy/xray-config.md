保存一下 xray 的配置。

nginx 配置：

```json
server {
        server_name host
        listen 80;
        return 301 https://$host$request_uri;
}


map $http_upgrade $connection_upgrade {
        default upgrade;
        ""      close;
}

map $proxy_protocol_addr $proxy_forwarded_elem {
        ~^[0-9.]+$        "for=$proxy_protocol_addr";
        ~^[0-9A-Fa-f:.]+$ "for=\"[$proxy_protocol_addr]\"";
        default           "for=unknown";
}

map $http_forwarded $proxy_add_forwarded {
        "~^(,[ \\t]*)*([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?(;([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?)*([ \\t]*,([ \\t]*([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?(;([!#$%&'*+.^_`|~0-9A-Za-z-]+=([!#$%&'*+.^_`|~0-9A-Za-z-]+|\"([\\t \\x21\\x23-\\x5B\\x5D-\\x7E\\x80-\\xFF]|\\\\[\\t \\x21-\\x7E\\x80-\\xFF])*\"))?)*)?)*$" "$http_forwarded, $proxy_forwarded_elem";
        default "$proxy_forwarded_elem";
}

server {
        listen 127.0.0.1:8001 proxy_protocol;
        listen 127.0.0.1:8002 http2 proxy_protocol;
        set_real_ip_from 127.0.0.1;

        location / {
            sub_filter                         $proxy_host $host;
            sub_filter_once                    off;

            proxy_pass                         https://www.lovelive-anime.jp;
            proxy_set_header Host              $proxy_host;

            proxy_http_version                 1.1;
            proxy_cache_bypass                 $http_upgrade;

            proxy_ssl_server_name on;

            proxy_set_header Upgrade           $http_upgrade;
            proxy_set_header Connection        $connection_upgrade;
            proxy_set_header X-Real-IP         $proxy_protocol_addr;
            proxy_set_header Forwarded         $proxy_add_forwarded;
            proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host  $host;
            proxy_set_header X-Forwarded-Port  $server_port;

            proxy_connect_timeout              60s;
            proxy_send_timeout                 60s;
            proxy_read_timeout                 60s;

            resolver 1.1.1.1;
        }
}
```

xray 配置：

```json
{
    "log": {
        "error": "/var/log/xray/error.log",
        "access": "/var/log/xray/access.log",
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            // 防止服务器直连国内
            {
                "type": "field",
                "ip": [
                    "geoip:cn"
                ],
                "outboundTag": "block"
            },
            {
                "type": "field",
                "domain": [
                    "geosite:cn"
                ],
                "outboundTag": "block"
            },
            // 屏蔽广告
            {
                "type": "field",
                "domain": [
                    "geosite:category-ads-all"
                ],
                "outboundTag": "block"
            },
            // 防止服务器本地流转问题
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "block"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "0.0.0.0", // "0.0.0.0" Indicates listening to both IPv4 and IPv6
            "port": 443, // The port on which the server listens
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "", // User ID, perform xray uuid generation, or a string of 1-30 bytes
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "dest": "8001",
                        "xver": 1
                    },
                    {
                        "alpn": "h2",
                        "dest": "8002",
                        "xver": 1
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "rejectUnknownSni": true,
                    "minVersion": "1.2",
                    "certificates": [
                        {
                            "ocspStapling": 3600,
                            "certificateFile": "/home/azureuser/xray_cert/cert.crt", // For the certificate file, it is recommended to use fullchain (full SSL certificate chain). If there is only a website certificate, v2rayN can be used but v2rayNG cannot be used. Usually, the extension is not distinguished
                            "keyFile": "/home/azureuser/xray_cert/cert.key" // private key file
                        }
                    ]
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ],
    "policy": {
        "levels": {
            "0": {
                "handshake": 2, // The handshake time limit when the connection is established, in seconds, the default value is 4, it is recommended to be different from the default value
                "connIdle": 120 // Connection idle time limit in seconds, the default value is 300, it is recommended to be different from the default value
            }
        }
    }
}
```

服务器【地址】: a-name.yourdomain.com
服务器【端口】: 443
连接的【协议】: vless
连接的【流控】: xtls-rprx-vision (vision 模式适合全平台)
连接的【验证】: uuiduuid-uuid-uuid-uuiduuiduuid
连接的【安全】: "allowInsecure": false

传输：TCP

传输层安全：tls

TLS 安全设置：

不检查服务器证书。SNI：域名。
