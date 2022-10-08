package main

import (
	"os"
	"github.com/davidbyttow/govips/v2/vips"
)

func main() {
	vips.Startup(nil)
	defer vips.Shutdown()
	vips.NewImageFromFile(os.Args[1])
}
