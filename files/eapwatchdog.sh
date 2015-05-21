#!/bin/sh

source /lib/functions.sh

iface_cb() {
	local cfg="$1"
	local server="$2" #server name to find only VIFs authenticating to checked RADIUS server
	local state="$3"  #RADIUS reachability state: 0 - broken, 1 - working
	local ifserver ifdisabled ifssid ifdevice

	config_get ifserver $cfg server
	[ "$server" != "$ifserver" ] && return

	config_get_bool ifdisabled $cfg disabled 0
	config_get ifssid $cfg ssid
	config_get ifdevice $cfg device
	[ "$state" == '0' -a "$ifdisabled" == '0' ] && {
		logger -t eapwatchdog -p daemon.warn "RADIUS connection failed, disabling SSID $ifssid on $ifdevice"
		uci_set wireless "$cfg" disabled 1
		uci_commit wireless
		wifi reload "$ifdevice"
	}
	[ "$state" == '1' -a "$ifdisabled" == '1' ] && {
		logger -t eapwatchdog -p daemon.warn "RADIUS connection working, enabling SSID $ifssid on $ifdevice"
		uci_set wireless "$cfg" disabled 0
		uci_commit wireless
		wifi reload "$ifdevice"
	}
}

eapwatchdog_cb() {
	local cfg="$1"
	local cfgfile="/var/run/eapoltest-$cfg.conf"
	local disabled server secret timeout identity password expected_string

	config_get_bool disabled $cfg disabled 0
	[ $disabled = '1' ] && return

	config_get server "$cfg" server
	[ "$server" = "" ] && return
	config_get secret "$cfg" secret mysecret
	config_get timeout "$cfg" timeout 3
	config_get identity "$cfg" identity "eduroom-status"
	config_get password "$cfg" password "nonexistent123"
	config_get expected_string "$cfg" expected_string "eduroom is alive"

	cat > "$cfgfile" <<-EOF
	network={
		ssid="dummy"
		key_mgmt=WPA-EAP
		eap=PEAP
		identity="$identity"
		password="$password"
	}
	EOF

	local radiusstate=0 # 0 - broken, 1 - working
	eapol_test "-a$server" "-s$secret" "-t$timeout" -r0 "-c$cfgfile" | \
		grep -q "$expected_string" && radiusstate=1
	
	config_foreach iface_cb wifi-iface $server $radiusstate
}



while true;
do
	config_load wireless
	config_foreach eapwatchdog_cb eapwatchdog
	sleep 10
done
