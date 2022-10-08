package main

import (
	"os"
	"github.com/davidbyttow/govips/v2/vips"
)

func checkError(err error) {
	if err != nil {
		return
	}
}

func main() {
	vips.Startup(nil)
	defer vips.Shutdown()

	image1, err := vips.NewImageFromFile(os.Args[1])
	checkError(err)

	// Rotate the picture upright and reset EXIF orientation tag
	err = image1.AutoRotate()
	checkError(err)

	ep := vips.NewDefaultJPEGExportParams()
	image1.Export(ep)
}
