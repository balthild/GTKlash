package main

import (
	"C"

	"github.com/Dreamacro/clash/config"
	"github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/hub"
	"github.com/Dreamacro/clash/proxy"
	"github.com/Dreamacro/clash/tunnel"
)

//export clash_run
func clash_run() *C.char {
	tunnel.Instance().Run()
	proxy.Instance().Run()
	hub.Run()

	config.Init()
	err := config.Instance().Parse()
	if err != nil {
		return C.CString(err.Error())
	}

	return C.CString("success")
}

//export clash_update_all_config
func clash_update_all_config() *C.char {
	err := config.Instance().Parse()
	if err != nil {
		return C.CString(err.Error())
	}
	return C.CString("success")
}

//export clash_set_config_home_dir
func clash_set_config_home_dir(root *C.char) {
	constant.SetHomeDir(C.GoString(root))
}

func main() {}
