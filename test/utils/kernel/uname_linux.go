//go:build linux || freebsd || solaris || openbsd
// +build linux freebsd solaris openbsd

package kernel

import (
	"golang.org/x/sys/unix"
)

type Utsname unix.Utsname

func uname() (*unix.Utsname, error) {
	uts := &unix.Utsname{}

	if err := unix.Uname(uts); err != nil {
		return nil, err
	}
	return uts, nil
}
