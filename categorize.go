package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {

	var green, red, na []string

	testdir := "test/e2e"
	files, err := os.ReadDir(testdir)
	if err != nil {
		fmt.Printf("Could not read files in %s", testdir)
		os.Exit(1)
	}

	var testsToRun = []string{}
	for _, file := range files {
		if strings.Contains(file.Name(), "_test.go") {
			testsToRun = append(testsToRun, file.Name())
		}
	}

	// Normally, one would run a test file as (e.g. start_test.go):
	// PODMAN_BINARY=/home/jsliacan/.crc/bin/oc/podman-remote go test -v test/e2e/custom_libpod_suite_test.go test/e2e/custom_common_test.go test/e2e/config.go test/e2e/custom_config_amd64.go test/e2e/start_test.go
	os.Setenv("PODMAN_BINARY", "/home/jsliacan/.crc/bin/oc/podman-remote")
	for i := 0; i < len(testsToRun); i++ {
		fmt.Printf("%d %-*s: ", i, 30, testsToRun[i])
		args := strings.Fields(fmt.Sprintf("test -v test/e2e/custom_libpod_suite_test.go test/e2e/custom_common_test.go test/e2e/config.go test/e2e/custom_config_amd64.go test/e2e/%s", testsToRun[i]))
		cmd := exec.Command("go", args...)
		// fmt.Println(cmd)
		out, _ := cmd.Output()

		if strings.Contains(string(out), "FAIL!") {
			red = append(red, testsToRun[i])
			fmt.Println("red")
		} else if strings.Contains(string(out), "SUCCESS!") {
			if strings.Contains(string(out), "0 Passed") {
				na = append(na, testsToRun[i])
				fmt.Println("na")
			} else {
				green = append(green, testsToRun[i])
				fmt.Println("green")
			}
		} else {
			fmt.Println("Not green. Not red. Not na.")
		}

	}

	fmt.Println("green: ", green)
	// g := "attach_test.go container_inspect_test.go events_test.go exists_test.go export_test.go history_test.go image_scp_test.go import_test.go init_test.go kill_test.go load_test.go namespace_test.go negative_test.go network_connect_disconnect_test.go pause_test.go pod_infra_container_test.go pod_initcontainers_test.go pod_inspect_test.go pod_kill_test.go pod_pause_test.go pod_pod_namespaces_test.go pod_prune_test.go pod_restart_test.go pod_rm_test.go pod_stop_test.go pod_top_test.go rename_test.go restart_test.go rm_test.go run_apparmor_test.go run_device_test.go run_entrypoint_test.go run_exit_test.go run_memory_test.go run_ns_test.go run_passwd_test.go run_privileged_test.go run_restart_test.go run_seccomp_test.go run_security_labels_test.go start_test.go stats_test.go stop_test.go system_connection_test.go system_dial_stdio_test.go tag_test.go untag_test.go volume_exists_test.go volume_inspect_test.go volume_ls_test.go volume_prune_test.go volume_rm_test.go wait_test.go"
	// r := "benchmarks_test.go commit_test.go container_create_volume_test.go containers_conf_test.go cp_test.go create_staticip_test.go create_staticmac_test.go create_test.go custom_volume_create_test.go exec_test.go generate_kube_test.go generate_systemd_test.go healthcheck_run_test.go images_test.go info_test.go inspect_test.go logs_test.go network_create_test.go network_test.go play_build_test.go pod_create_test.go pod_ps_test.go pod_start_test.go port_test.go prune_test.go ps_test.go pull_test.go push_test.go quadlet_test.go rmi_test.go run_cgroup_parent_test.go run_env_test.go run_networking_test.go run_selinux_test.go run_signal_test.go run_test.go run_transient_test.go run_volume_test.go run_working_dir_test.go save_test.go secret_test.go system_df_test.go systemd_test.go toolbox_test.go top_test.go unshare_test.go version_test.go volume_create_test.go"
	// s := "checkpoint_image_test.go cleanup_test.go container_clone_test.go diff_test.go generate_spec_test.go image_sign_test.go login_logout_test.go mount_rootless_test.go mount_test.go pod_clone_test.go pod_stats_test.go run_aardvark_test.go run_cleanup_test.go run_cpu_test.go run_dns_test.go run_staticip_test.go runlabel_test.go system_reset_test.go system_service_test.go systemd_activate_test.go tree_test.go trust_test.go update_test.go volume_plugin_test.go"
	fmt.Println("red: ", red)
	fmt.Println("na: ", na)
}
