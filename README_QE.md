# Information for non-podman QE

This note is mainly concerned with: How to run podman e2e tests against **my podman client** (on linux). Throughout this entire procedure, I will have the following env variable exported.

```bash
export PODMAN_BINARY=${HOME}/.crc/bin/oc/podman-remote
```
The tests check the presence of this variable and execute against your binary.

## Executing

### Build

The following command should be run from the repository's home dir. For simplicity, we will only build the `start_test.go` test. The entire testsuite can be built by supplying `.` instead of the test name. _To be solved_: how to build a binary from a selection of tests containing a number of tests strictly between 1 and all. 

```bash
GOARCH=amd64 GOOS=linux go test -v test/e2e/custom_libpod_suite_test.go test/e2e/custom_common_test.go test/e2e/config.go test/e2e/custom_config_amd64.go  test/e2e/start_test.go -tags "containers_image_openpgp exclude_graphdriver_btrfs exclude_graphdriver_devicemapper" -c -o ./out/linux-amd64/integration.test
```

### Run

Both options assume you're in the repository's home dir. Also, to continue the example from above, we are only trying to run `start_test.go` test. 

- If you have a test binary (e.g. that you built like above)
    ```bash
    ./out/linux-amd64/integration.test
    ```
- If you have Go on the host and want to run tests directly via go test. 
    ```bash
    go test -v test/e2e/custom_libpod_suite_test.go test/e2e/custom_common_test.go test/e2e/config.go test/e2e/custom_config_amd64.go test/e2e/start_test.go
    ```

**Example**
Running the test binary that we built above against CRC's podman-remote client. 

[![asciicast](https://asciinema.org/a/dqmQ9iuElnXkqBWk84FZhwErb.svg)](https://asciinema.org/a/dqmQ9iuElnXkqBWk84FZhwErb)


## Notes

Not all tests will pass out-of-the-box. For CRC (podman preset with client 4.3.1), the following are the categories we observe.

- Pass (53)
_attach_test.go container_inspect_test.go events_test.go exists_test.go export_test.go history_test.go image_scp_test.go import_test.go init_test.go kill_test.go load_test.go namespace_test.go negative_test.go network_connect_disconnect_test.go pause_test.go pod_infra_container_test.go pod_initcontainers_test.go pod_inspect_test.go pod_kill_test.go pod_pause_test.go pod_pod_namespaces_test.go pod_prune_test.go pod_restart_test.go pod_rm_test.go pod_stop_test.go pod_top_test.go rename_test.go restart_test.go rm_test.go run_apparmor_test.go run_device_test.go run_entrypoint_test.go run_exit_test.go run_memory_test.go run_ns_test.go run_passwd_test.go run_privileged_test.go run_restart_test.go run_seccomp_test.go run_security_labels_test.go start_test.go stats_test.go stop_test.go system_connection_test.go system_dial_stdio_test.go tag_test.go untag_test.go volume_exists_test.go volume_inspect_test.go volume_ls_test.go volume_prune_test.go volume_rm_test.go wait_test.go_
- Fail (48)
_benchmarks_test.go commit_test.go container_create_volume_test.go containers_conf_test.go cp_test.go create_staticip_test.go create_staticmac_test.go create_test.go custom_volume_create_test.go exec_test.go generate_kube_test.go generate_systemd_test.go healthcheck_run_test.go images_test.go info_test.go inspect_test.go logs_test.go network_create_test.go network_test.go play_build_test.go pod_create_test.go pod_ps_test.go pod_start_test.go port_test.go prune_test.go ps_test.go pull_test.go push_test.go quadlet_test.go rmi_test.go run_cgroup_parent_test.go run_env_test.go run_networking_test.go run_selinux_test.go run_signal_test.go run_test.go run_transient_test.go run_volume_test.go run_working_dir_test.go save_test.go secret_test.go system_df_test.go systemd_test.go toolbox_test.go top_test.go unshare_test.go version_test.go volume_create_test.go_
- Not Applicable/Skipped (24)
_checkpoint_image_test.go cleanup_test.go container_clone_test.go diff_test.go generate_spec_test.go image_sign_test.go login_logout_test.go mount_rootless_test.go mount_test.go pod_clone_test.go pod_stats_test.go run_aardvark_test.go run_cleanup_test.go run_cpu_test.go run_dns_test.go run_staticip_test.go runlabel_test.go system_reset_test.go system_service_test.go systemd_activate_test.go tree_test.go trust_test.go update_test.go volume_plugin_test.go_

Among the tests that don't pass, some failures are caused by tested features not being present on our client (e.g. it's a remote client, rootless?, etc.). So going through the failed (out-of-the-box) tests and checking why they failed is still needed.

## Changes

`a/test/e2e/common_test.go b/test/e2e/custom_common_test.go`
```diff
	if noEvents {
		eventsType = "none"
	}
+	podmanOptions := []string{fmt.Sprintf("%s --tmpdir %s --events-backend %s", debug, p.TempDir, eventsType)}
+	// podmanOptions := strings.Split(fmt.Sprintf("%s--root %s --runroot %s --runtime %s --conmon %s --network-config-dir %s --network-backend %s --cgroup-manager %s --tmpdir %s --events-backend %s",
+	//	debug, p.Root, p.RunRoot, p.OCIRuntime, p.ConmonBinary, p.NetworkConfigDir, p.NetworkBackend.ToString(), p.CgroupManager, p.TmpDir, eventsType), " ")

-	podmanOptions := strings.Split(fmt.Sprintf("%s--root %s --runroot %s --runtime %s --conmon %s --network-config-dir %s --network-backend %s --cgroup-manager %s --tmpdir %s --events-backend %s",
-		debug, p.Root, p.RunRoot, p.OCIRuntime, p.ConmonBinary, p.NetworkConfigDir, p.NetworkBackend.ToString(), p.CgroupManager, p.TmpDir, eventsType), " ")
-
-	podmanOptions = append(podmanOptions, strings.Split(p.StorageOptions, " ")...)
+	// podmanOptions = append(podmanOptions, strings.Split(p.StorageOptions, " ")...)
	if !noCache {
		cacheOptions := []string{"--storage-opt",
			fmt.Sprintf("%s.imagestore=%s", p.PodmanTest.ImageCacheFS, p.PodmanTest.ImageCacheDir)}
```

`a/test/e2e/libpod_suite_test.go b/test/e2e/custom_libpod_suite_test.go`
```diff
@@ -13,7 +13,7 @@ import (
)

func IsRemote() bool {
-	return false
+	return true
}
```

## Version of Podman

CRC comes with a specific version of Podman, e.g. right now it is `4.3.1` (for `podman` preset) and `4.2.0` (for `openshift` preset). Going by `podman` preset, we want to run the testsuite associated with the correct version tag. Therefore, all the changes we do here, we need to rebase onto the correct point in commit history. Assuming being in the folder of your local copy of the podman repository:

```bash
git fetch --all --tags
git checkout tags/v4.3.1 -b v4.3.1-prc

git log --oneline -10
814b7b003 (HEAD -> v4.3.1-branch, tag: v4.3.1) Bump to v4.3.1
05498680c Release notes for 4.3.1
f2d838d62 Merge pull request #16459 from mtrmac/c-image-release
684f47010 Bump c/image to released v5.23.1
6b49e1d18 Merge pull request #16448 from openshift-cherrypick-robot/cherry-pick-16327-to-v4.3
560dbcc04 Fix deadlock between 'podman ps' and 'container inspect' commands
3266e7307 Merge pull request #16313 from edsantiago/fix_ubi8_b0rkage_v43
52a6516f9 FIXME: Temporary workaround for ubi8 CI breakage
9ce592fcb Merge pull request #16241 from mtrmac/c-image-5.23-backports
83b02f8fd Update c/image from release-5.23 branch

```
Now you're on a branch new `v4.3.1-prc` (`prc` as in Podman Remote Client, as that's what we are testing at CRC) that diverges from the `main` at tag `v4.3.1`. At this point, all you need to do is cherry-pick changes you made onto this branch. At this (half-baked) stage, it was these 4 commits for me:

```bash
git log --oneline -10
d6e638b61 (HEAD -> v4.3.1-prc) Changes regarding building the test binary
d105f2f55 Add asciinema to README_QE.md
2c77b8873 Add README_QE for our purposes
3b1efd296 Changes needed to run and categorize podman e2e tests
814b7b003 (tag: v4.3.1) Bump to v4.3.1
05498680c Release notes for 4.3.1
```

Now `v4.3.1-prc` is the branch from which we build test binary to be run against podman-remote client that comes with CRC (`podman` preset). The versions match. 

## Containerized test binary

From repo home folder, build image with:

```bash
PRC_E2E_IMG_VERSION=vlatest make containerized_prc_e2e
```
It is assumed that your podman binary resides in `/usr/bin/podman`. Change as needed under `containerized_prc_e2e` target in the `Makefile`. 

Push to quay with:

```bash
podman push quay.io/crcont/prc-e2e:v${VERSION}
```