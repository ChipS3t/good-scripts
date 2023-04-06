#!/bin/bash

SPLUNK_URL=https://download.splunk.com/products/splunk/releases/9.0.4.1/linux/splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz
APPS_AND_ADDONS=https://github.com/s00p123/resource-repo/archive/splunk.zip
SPLUNK_HOME=/opt/splunk

if ! command tar; then
	echo "Error: tar not in PATH"
	exit 1
elif ! command printf; then
	echo "Error: printf not in PATH"
	exit 1
elif ! command unzip; then
	echo "Error: unzip not in PATH"
	exit 1
fi

if command -v wget; then
	echo "Downloading splunk.tar..."
	wget -q -O splunk.tar $SPLUNK_URL
	echo "Downloading apps and addons..."
	wget -q -O apps_and_addons.zip $APPS_AND_ADDONS
elif command -v curl; then
	echo "Downloading splunk.tar..."
	curl -q -s -o splunk.tar $SPLUNK_URL
	echo "Downloading apps and addons..."
	curl -q -s -o apps_and_addons.zip $APPS_AND_ADDONS
else
	echo "Error: wget or curl not in PATH"
	exit 1
fi

if [[ -f splunk.tar && -r splunk.tar && -f apps_and_addons.zip && -r apps_and_addons.zip ]]; then
	echo "Extracting splunk.tar..."
	tar xfz splunk.tar -C /opt
	echo "Extracting apps_and_addons.zip"
	unzip apps_and_addons.zip
else
	echo "Download must have failed, splunk.tar or apps_and_addons.zip not found or are not readable"
	exit 1
fi

# Adding apps and addons
cd resource-repo-splunk/Splunk
tar xfz Add-On/punchcard-custom-visualization_150.tgz -C $SPLUNK_HOME/etc/apps/
tar xfz Add-On/splunk-add-on-for-unix-and-linux_820.tgz -C $SPLUNK_HOME/etc/apps/
tar xfz Add-On/splunk-add-on-for-unix-and-linux_820.tgz -C $SPLUNK_HOME/etc/deployment-apps/
tar xfz Add-On/splunk-sankey-diagram-custom-visualization_160.tgz -C $SPLUNK_HOME/etc/apps/
tar xfz Apps/infosec-app-for-splunk_170.tgz -C $SPLUNK_HOME/etc/apps/
tar xfz Apps/splunk-app-for-lookup-file-editing_360.tgz -C $SPLUNK_HOME/etc/apps/
tar xfz Apps/splunk-common-information-model-cim_502.tgz -C $SPLUNK_HOME/etc/apps/

# Add symlink to splunk binary
ln -s /opt/splunk/bin/splunk /usr/local/bin

# Set working directory for the rest of the script
cd /opt/splunk/bin

printf '[user_info]\nPASSWORD = changeme' > /opt/splunk/etc/system/local/user-seed.conf
printf '[serverClass:linux-server-class]\nwhitelist.0 = *\nmachineTypesFilter = linux*\n' > /opt/splunk/etc/system/local/serverclass.conf
printf '[serverClass:linux-server-class:app:Splunk_TA_nix]\nrestartSplunkd = true\n' >> /opt/splunk/etc/system/local/serverclass.conf
printf '[serverClass:windows-server-class]\nwhitelist.0 = *\nmachineTypesFilter = windows*\n' >> /opt/splunk/etc/system/local/serverclass.conf
printf '[serverClass:windows-server-class:app:Splunk_TA_windows]\nrestartSplunkd = true\n' >> /opt/splunk/etc/system/local/serverclass.conf
./splunk enable listen 9997 --accept-license --no-prompt
./splunk start
