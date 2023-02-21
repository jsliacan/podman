# Overview

The container includes the podman e2e tests binary for the three platforms (linux, darwin, windows).

The container connects through ssh to the target host and copies the right binary for the platform to the host. It then runs the podman e2e tests before it fetches the results and logs back.

## Envs

**PLATFORM**:*target platform (windows, macos, linux).*
**ARCH**:*target architecture (amd64, arm64). Default amd64*
**TARGET_HOST**:*dns or ip for the target host.*  
**TARGET_HOST_USERNAME**:*username for target host.*  
**TARGET_HOST_KEY_PATH**:*private key for user. (Mandatory if not TARGET_HOST_PASSWORD).*  
**TARGET_HOST_PASSWORD**:*password for user. (Mandatory if not TARGET_HOST_KEY_PATH).*    
**RESULTS_PATH**:*(Optional). Path inside container to fetch results and logs from tests execution.*  
**RESULTS_FILE**:*(Optional). File name for results. Default value: podman-e2e.*   
**USER_PASSWORD**:*(Required when testing mode ux). Password for the user with privileges to run the installer*  

## Samples

```bash
# Run e2e on macos platform with ssh key and custom bundle
podman run --rm -it --name podman-e2e \
    -e PLATFORM=macos \
    -e TARGET_HOST=$IP \
    -e TARGET_HOST_USERNAME=$USER \
    -e TARGET_HOST_KEY_PATH=/opt/crc/id_rsa \
    -v $PWD/id_rsa:/opt/crc/id_rsa:Z \
    -v $PWD/output:/output:Z \
    quay.io/crcont/podman-e2e:vlatest

# Run e2e on windows platform with ssh password and crc released version
podman run --rm -it --name podman-e2e \
    -e PLATFORM=windows \
    -e TARGET_HOST=$IP \
    -e TARGET_HOST_USERNAME=$USER \
    -e TARGET_HOST_PASSWORD=$PASSWORD \
    -v $PWD/output:/output:Z \
    quay.io/crcont/podman-e2e:vlatest
```
