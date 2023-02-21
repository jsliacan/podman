#!/bin/sh

ARCH="${ARCH:-"amd64"}"
# Vars
BINARY=podman-e2e.test
if [[ ${PLATFORM} == 'windows' ]]; then
    BINARY=podman-e2e.test.exe
fi
BINARY_PATH="/opt/crc/bin/${PLATFORM}-${ARCH}/${BINARY}"

# Results
RESULTS_PATH="${RESULTS_PATH:-/output}"
# results file name
RESULTS_FILE="${RESULTS_FILE:-"podman-e2e"}"

if [ "${DEBUG:-}" = "true" ]; then
    set -xuo 
fi

# Validate conf
validate=true
[[ -z "${TARGET_HOST+x}" ]] \
    && echo "TARGET_HOST required" \
    && validate=false

[[ -z "${TARGET_HOST_USERNAME+x}" ]] \
    && echo "TARGET_HOST_USERNAME required" \
    && validate=false

[[ -z "${TARGET_HOST_KEY_PATH+x}" && -z "${TARGET_HOST_PASSWORD+x}" ]] \
    && echo "TARGET_HOST_KEY_PATH or TARGET_HOST_PASSWORD required" \
    && validate=false

[[ $validate == false ]] && exit 1

# Define remote connection
REMOTE="${TARGET_HOST_USERNAME}@${TARGET_HOST}"
if [[ ! -z "${TARGET_HOST_DOMAIN+x}" ]]; then
    REMOTE="${TARGET_HOST_USERNAME}@${TARGET_HOST_DOMAIN}@${TARGET_HOST}"
fi

# Increase ssh connectivity reliability 
RELIABLE_CONNECTION='-o ServerAliveInterval=30 -o ServerAliveCountMax=1200'
# Set SCP / SSH command with pass or key
NO_STRICT='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
if [[ ! -z "${TARGET_HOST_KEY_PATH+x}" ]]; then
    SCP="scp -r ${RELIABLE_CONNECTION} ${NO_STRICT} -i ${TARGET_HOST_KEY_PATH}"
    SSH="ssh ${RELIABLE_CONNECTION} ${NO_STRICT} -i ${TARGET_HOST_KEY_PATH}"
else
    SCP="sshpass -p ${TARGET_HOST_PASSWORD} scp -r ${RELIABLE_CONNECTION} ${NO_STRICT}" \
    SSH="sshpass -p ${TARGET_HOST_PASSWORD} ssh ${RELIABLE_CONNECTION} ${NO_STRICT}"
fi

echo "Copy resources to target"
# Create execution folder 
EXECUTION_FOLDER="/Users/${TARGET_HOST_USERNAME}/crc-e2e"
if [[ ${PLATFORM} == 'linux' ]]; then
    EXECUTION_FOLDER="/home/${TARGET_HOST_USERNAME}/crc-e2e"
fi
DATA_FOLDER="${EXECUTION_FOLDER}/out"
if [[ ${PLATFORM} == 'windows' ]]; then
    # Todo change for powershell cmdlet
    $SSH "${REMOTE}" "powershell.exe -c New-Item -ItemType directory -Path ${EXECUTION_FOLDER}/bin"
else
    $SSH "${REMOTE}" "mkdir -p ${EXECUTION_FOLDER}/bin"
fi

# Copy crc-e2e binary and pull-secret
# Review this when go 1.16 with embed support
$SCP "${BINARY_PATH}" "${REMOTE}:${EXECUTION_FOLDER}/bin"

echo "Running podman e2e tests"
# e2e envs
if [[ ${PLATFORM} == 'windows' ]]; then
    # BINARY_EXEC="(New-Object -ComObject "Shell.Application").minimizeall(); \$env:SHELL=\"powershell\"; "
    BINARY_EXEC="\$env:SHELL=\"powershell\"; "
fi

if [[ ${PLATFORM} == 'darwin' ]]; then
    BINARY_EXEC+="sudo su - ${TARGET_HOST_USERNAME} -c \"PATH=\$PATH:/usr/local/bin && cd ${EXECUTION_FOLDER}/bin && ./${BINARY} > ${RESULTS_FILE}.results\""
else
    BINARY_EXEC+="cd ${EXECUTION_FOLDER}/bin && ./${BINARY} > ${RESULTS_FILE}.results"
fi
# Execute command remote
$SSH ${REMOTE} ${BINARY_EXEC}

echo "Getting podman e2e tests results and logs"
# Get results
mkdir -p "${RESULTS_PATH}"
$SCP "${REMOTE}:${EXECUTION_FOLDER}/bin/${RESULTS_FILE}.results" "${RESULTS_PATH}"
$SCP "${REMOTE}:${EXECUTION_FOLDER}/bin/out/test-results" "${RESULTS_PATH}"

echo "Cleaning up target host"
# Cleanup
$SSH "${REMOTE}" "rm -r ${EXECUTION_FOLDER}"