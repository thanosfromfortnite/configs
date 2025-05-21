netsh wlan delete profile name="*"
netsh wlan add profile filename="%~dp0\wifi.xml"
