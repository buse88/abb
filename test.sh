Searching 1 file for "https://githubdw.8080k.eu.org/https://github.com.com"

D:\360安全浏览器下载\debian12-x86_64.sh:
  505  	cd /tmp
  506  	apt-get -y install git
  507: 	git clone https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/mptcpize.git
  508  	cd mptcpize
  509  	make
  ...
  545  		## Compile Shadowsocks
  546  		#rm -rf /tmp/shadowsocks-libev-${SHADOWSOCKS_VERSION}
  547: 		#wget -O /tmp/shadowsocks-libev-${SHADOWSOCKS_VERSION}.tar.gz http://https://githubdw.8080k.eu.org/https://github.com.com/shadowsocks/shadowsocks-libev/releases/download/v${SHADOWSOCKS_VERSION}/shadowsocks-libev-${SHADOWSOCKS_VERSION}.tar.gz
  548  		cd /tmp
  549  		rm -rf shadowsocks-libev
  550: 		git clone https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/shadowsocks-libev.git
  551  		cd shadowsocks-libev
  552  		git checkout ${SHADOWSOCKS_VERSION}
  ...
  556  		#wget https://raw.https://gh.api.99988866.xyz/https://github.comusercontent.com/Ysurac/openmptcprouter-feeds/master/shadowsocks-libev/patches/020-NOCRYPTO.patch
  557  		#patch -p1 < 020-NOCRYPTO.patch
  558: 		#wget https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/shadowsocks-libev/commit/31b93ac2b054bc3f68ea01569649e6882d72218e.patch
  559  		#patch -p1 < 31b93ac2b054bc3f68ea01569649e6882d72218e.patch
  560: 		#wget https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/shadowsocks-libev/commit/2e52734b3bf176966e78e77cf080a1e8c6b2b570.patch
  561  		#patch -p1 < 2e52734b3bf176966e78e77cf080a1e8c6b2b570.patch
  562: 		#wget https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/shadowsocks-libev/commit/dd1baa91e975a69508f9ad67d75d72624c773d24.patch
  563  		#patch -p1 < dd1baa91e975a69508f9ad67d75d72624c773d24.patch
  564  		# Shadowsocks eBPF support
  ...
  569  		#cd /tmp
  570  		#rm -rf libbpf
  571: 		#git clone https://githubdw.8080k.eu.org/https://github.com.com/libbpf/libbpf.git
  572  		#cd libbpf
  573  		#if [ "$ID" = "debian" ]; then
  ...
  756  		wget -O /lib/systemd/system/omr-admin.service ${VPSURL}${VPSPATH}/omr-admin.service.in
  757  		wget -O /lib/systemd/system/omr-admin-ipv6.service ${VPSURL}${VPSPATH}/omr-admin-ipv6.service.in
  758: 		wget -O /tmp/openmptcprouter-vps-admin.zip https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/openmptcprouter-vps-admin/archive/${OMR_ADMIN_VERSION}.zip
  759  		cd /tmp
  760  		unzip -q -o openmptcprouter-vps-admin.zip
  ...
  912  			apt-get install -y --no-install-recommends build-essential autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake git ca-certificates
  913  		fi
  914: 		git clone https://githubdw.8080k.eu.org/https://github.com.com/shadowsocks/simple-obfs.git /tmp/simple-obfs
  915  		cd /tmp/simple-obfs
  916  		git checkout ${OBFS_VERSION}
  ...
  934  	if [ "$SOURCES" = "yes" ]; then
  935  		rm -rf /tmp/v2ray-plugin-linux-amd64-${V2RAY_PLUGIN_VERSION}.tar.gz
  936: 		#wget -O /tmp/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz https://githubdw.8080k.eu.org/https://github.com.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz
  937  		#wget -O /tmp/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz ${VPSURL}${VPSPATH}/bin/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz
  938: 		wget -O /tmp/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz https://githubdw.8080k.eu.org/https://github.com.com/teddysun/v2ray-plugin/releases/download/v${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz
  939  		cd /tmp
  940  		tar xzvf v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz
  ...
  948  		#rm -f /var/lib/dpkg/lock
  949  		#apt-get install -y --no-install-recommends git ca-certificates golang-go
  950: 		#git clone https://githubdw.8080k.eu.org/https://github.com.com/shadowsocks/v2ray-plugin.git /tmp/v2ray-plugin
  951  		#cd /tmp/v2ray-plugin
  952  		#git checkout ${V2RAY_PLUGIN_VERSION}
  ...
 1039  #			[ "$ARCH" = "mipsel" ] && V2RAY_FILENAME="v2ray-linux-mips32le.zip"
 1040  #			[ "$ARCH" = "riscv64" ] && V2RAY_FILENAME="v2ray-linux-riscv64.zip"
 1041: #			wget -O /tmp/v2ray-${V2RAY_VERSION}.zip https://githubdw.8080k.eu.org/https://github.com.com/v2fly/v2ray-core/releases/download/v${V2RAY_VERSION}/${V2RAY_FILENAME}
 1042  #			cd /tmp
 1043  #			rm -rf v2ray
 ....
 1175  		rm -rf /tmp/mlvpn
 1176  		cd /tmp
 1177: 		#git clone https://githubdw.8080k.eu.org/https://github.com.com/markfoodyburton/MLVPN.git /tmp/mlvpn
 1178: 		#git clone https://githubdw.8080k.eu.org/https://github.com.com/flohoff/MLVPN.git /tmp/mlvpn
 1179: 		git clone https://githubdw.8080k.eu.org/https://github.com.com/zehome/MLVPN.git /tmp/mlvpn
 1180: 		#git clone https://githubdw.8080k.eu.org/https://github.com.com/link4all/MLVPN.git /tmp/mlvpn
 1181  		cd /tmp/mlvpn
 1182  		git checkout ${MLVPN_VERSION}
 ....
 1236  		rm -rf /tmp/ubond
 1237  		cd /tmp
 1238: 		git clone https://githubdw.8080k.eu.org/https://github.com.com/markfoodyburton/ubond.git /tmp/ubond
 1239  		cd /tmp/ubond
 1240  		git checkout ${UBOND_VERSION}
 ....
 1344  	#fi
 1345  	if [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "18.04" ] && [ ! -d /etc/openvpn/ca ]; then
 1346: 		wget -O /tmp/EasyRSA-unix-v${EASYRSA_VERSION}.tgz https://githubdw.8080k.eu.org/https://github.com.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v${EASYRSA_VERSION}.tgz
 1347  		cd /tmp
 1348  		tar xzvf EasyRSA-unix-v${EASYRSA_VERSION}.tgz
 ....
 1469  		rm -rf /tmp/glorytun-udp
 1470  		cd /tmp
 1471: 		git clone https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/glorytun.git /tmp/glorytun-udp
 1472  		cd /tmp/glorytun-udp
 1473  		git checkout ${GLORYTUN_UDP_VERSION}
 ....
 1537  		rm -rf /tmp/dsvpn
 1538  		cd /tmp
 1539: 		git clone https://githubdw.8080k.eu.org/https://github.com.com/ysurac/dsvpn.git /tmp/dsvpn
 1540  		cd /tmp/dsvpn
 1541  		git checkout ${DSVPN_VERSION}
 ....
 1590  		cd /tmp
 1591  		if [ "$KERNEL" != "5.4" ]; then
 1592: 			wget -O /tmp/glorytun-0.0.35.tar.gz https://githubdw.8080k.eu.org/https://github.com.com/Ysurac/glorytun/archive/refs/heads/tcp.tar.gz
 1593  		else
 1594: 			wget -O /tmp/glorytun-0.0.35.tar.gz https://githubdw.8080k.eu.org/https://github.com.com/angt/glorytun/releases/download/v0.0.35/glorytun-0.0.35.tar.gz
 1595  		fi
 1596  		tar xzf glorytun-0.0.35.tar.gz

23 matches in 1 file
