#!/bin/bash
#
# Author: REDD
# Version: 1.1
# Contents: Checks on checks on checks on checks, then PATCH!
#  - patch.sh
#   |- patch/
#   |- patch/library.sh
#    - patch/library

UI_DIR="/www/cgi-bin"
PATCH_DIR="/tmp/patch"
CORRECT_VERSION="1.1.0"

function installlibrary(){
		echo -e "Running Pre-Patch checks.."
		echo -e "\n[!] Checking firmware..."
		VERIFY_VERS=$(cat "/root/VERSION")
		echo -e "[+] Current Firmware: ${VERIFY_VERS}"
		# "ash" doesnt have comparison on decimals! Lets do some Bash-Fu to fix that!
		# Hiiiiyyya!
		COMPARE=$(echo ${VERIFY_VERS} ${CORRECT_VERSION} | awk '{if ($1 >= $2) print "1"; else print "0" }')
		# Summarize - If SJs Firmware is equal to or greater than, print 1, if not print 0.
		if [ "${COMPARE}" == "1" ]; then
			echo -e "[+] Firmware matches Patcher requirements. (1.1.0+)"
		fi
		if [ "${COMPARE}" == "0" ]; then
			echo -e "[!] Incorrected Firmware. Please update or contact developer."
			exit 1
		fi
		if [ ! -d "${PATCH_DIR}" ]; then
			echo -e "[!] No patch directory. Please download the patch module for this script."
			exit 0
		else
			if [ -f "${PATCH_DIR}/library.sh" ]; then
                echo -e "[+] Library Module found in patch directory. Continuing."
			fi
			if [ ! -f "${PATCH_DIR}/library.sh" ]; then
                echo -e "[!] No Library Module in patch directory. Please download the patch module for this script."
                exit 0;
			fi
			if [ -f "${PATCH_DIR}/library" ]; then
                echo -e "[+] library command found in patch directory. Continuing."
			fi
			if [ ! -f "${PATCH_DIR}/library" ]; then
                echo -e "[!] No library command in patch directory. Please download the patch module for this script."
                exit 0;
			fi
		fi
		echo -e "[+] Installing library command (library shell extension) for SharkJack 1.1.0"
		sleep 2;
		bash "${PATCH_DIR}/library" "--install-library"
        echo -e "[+] Installing Payload Library Module for SharkJack 1.1.0"
                sleep 2;
                echo -e "  [+] Installing Payload Library into UI directory."
                cp -rf "${PATCH_DIR}/library.sh" "${UI_DIR}/library.sh"
		# Do 1 check instead of check all to save on resources during patch.
        STRING_CHK=$(cat $UI_DIR/status.sh | grep -c '/cgi-bin/library.sh')
        if [ ${STRING_CHK} -eq 0 ]; then
                echo -e "  [+] Patching status.sh..";
                addlibrarymenu ${UI_DIR}/status.sh;
                echo -e "  [+] Patching help.sh..";
                addlibrarymenu ${UI_DIR}/help.sh;
                echo -e "  [+] Patching loot.sh..";
                addlibrarymenu ${UI_DIR}/loot.sh;
                echo -e "  [+] Patching edit.sh..";
                addlibrarymenu ${UI_DIR}/edit.sh;
        else
                echo -e "Library is already install or has errors. Please restore from .bak files."
        fi
}

function addlibrarymenu(){
        # Why did I volunteer for this?
        INPUT="$1"
        BACKUPFILE="$1.bak"
        cp -rf "$1" "${BACKUPFILE}";rm -rf "${INPUT}"
		# Time to check if a basic line in the Original UI is in each file. - if so add Library.
        n=0
        IFS=''
        while read -r line; do
                echo -e "${line}"
                if [[ "${line}" =~ '/cgi-bin/loot.sh' && $n = 0 ]]; then
                echo '    <a href="/cgi-bin/library.sh">Library</a>'
                n=1
                fi
        done < "${BACKUPFILE}" > "${INPUT}"
        # Fix Permission for file.
        chmod 0755 "${INPUT}"
}

function removelibrary(){
				# Check for .bak files in the Web UI directory. If not, gtfo.
                CHK_BAK=$(ls ${UI_DIR}/*.sh.bak 2> /dev/null | wc -l)
                if [ "${CHK_BAK}" == 0 ]; then
                        echo -e "No BAK Files found. Library Module is not installed."
                        exit 1
                fi
                echo -e "[+] BAK Files found. Starting removal process.."
                # For each .bak file remove current and replace with backup copy.
				for file in "${UI_DIR}"/*.bak;
                do
                        BASE_FILE=$(basename "${file}" .bak)
                        DIR_NAME=$(dirname "${file}")
                        ORIG_NAME="${DIR_NAME}/${BASE_FILE}"
                        echo -e "  [!] ${BASE_FILE}.bak found. Restoring original copy.."
                        rm "${ORIG_NAME}";mv "${file}" "${ORIG_NAME}"
                        echo -e "  [+] ${BASE_FILE} restored."
                done
				# Remove the Library UI Tab itself but leave library directory. - DONT DELETE MY FILES!
				if [ -f "${UI_DIR}/library.sh" ]; then
						echo -e "[!] Removing Library Module from UI directory."
						rm "${UI_DIR}/library.sh"
						echo -e  "[+] Library Module Removed."
				fi
				if [ -f "/usr/sbin/payloads" ]; then
						echo -e "[!] Removing library command (library shell extension)."
						rm "/usr/sbin/library"
						echo -e "[+] library command removed."
				fi
}

# Check if 1st argument is the remove tag, if not. - install.
if [ "$1" == "--remove" ]; then
        removelibrary;
else
        installlibrary;
fi

echo -e "[+] Patcher has finished."
