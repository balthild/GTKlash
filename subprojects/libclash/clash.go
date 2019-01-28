package main

import (
	"C"

	"github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/hub"
)

//export clash_reload
func clash_reload() *C.char {
	if err := hub.Parse(); err != nil {
		return C.CString(err.Error())
	}

	return C.CString("success")
}

//export clash_set_config_home_dir
func clash_set_config_home_dir(root *C.char) {
	constant.SetHomeDir(C.GoString(root))
}

func main() {}
