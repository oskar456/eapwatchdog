# Eapwatchdog 

OpenWRT package to enable and disable wireless depending on RADIUS server
reachability.  It's main purpose is to prevent broadcasting of a wireless
network essid when RADIUS connection is not working, making the network
inaccessible.

## Usage
To activate the watchdog, create a new section `eapwatchdog` in wireless
configuration file and specify server that should be tested. Other
options than server name are optional, below is the default:

    config eapwatchdog 'eapwatchdog'
        option server   '127.0.0.1'
        option disabled '0'
        option secret   'mysecret'
        option timeout  '3'
        option identity 'eduroom-status'
        option password 'nonexistent123'
        option expected_string 'eduroom is alive'

The watchdog will try to test the connection using `eapol-test` tool every
10 seconds and if that command don't return expected string, all VIF that
are configured to use that RADIUS server will get disabled. After the
reachability test succeds the VIFs get re-enabled again.
