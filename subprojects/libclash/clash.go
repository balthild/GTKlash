package main

import "C"

import (
	"fmt"
	"os"
	"github.com/oschwald/geoip2-golang"
	"github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/hub"
)

//export clash_hub_parse
func clash_hub_parse() *C.char {
	if err := hub.Parse(); err != nil {
		return C.CString(err.Error())
	}

	return C.CString("success")
}

//export clash_set_config_home_dir
func clash_set_config_home_dir(root *C.char) {
	constant.SetHomeDir(C.GoString(root))
}

//export clash_mmdb_is_invalid
func clash_mmdb_is_invalid() bool {
	var path = constant.Path.MMDB();

	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		return true
	}

	_, err = geoip2.Open(path)
	if err != nil {
		return true
	}

	return false
}

var progress chan Progress = make(chan Progress)

//export clash_start_download_mmdb
func clash_start_download_mmdb() {
	go downloadMMDB(constant.Path.MMDB(), progress)
}

//export clash_get_download_progress
func clash_get_download_progress() *C.char {
	// TODO: Pass struct between Go ans Vala
	var p = <-progress;
	var str = fmt.Sprintf("%d,%.04f", p.Status, p.Rate)
	return C.CString(str)
}

func main() {}
