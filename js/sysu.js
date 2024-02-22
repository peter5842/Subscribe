var ssidMatched = /SYSU-SECURE.*/.test($network.wifi.ssid);
if (ssidMatched) {
	$done({servers: new Array("10.8.8.8","10.8.4.4")});
} else {
	$done({servers: $network.dns});
}
