package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"github.com/davidbyttow/govips/v2/vips"
)

func main() {
	vips.Startup(nil)
	defer vips.Shutdown()

	vips.NewImageFromFile(os.Args[1])
	//checkError(err)

	// Rotate the picture upright and reset EXIF orientation tag
	//err = image1.AutoRotate()
	//checkError(err)

//	ep := vips.NewDefaultJPEGExportParams()
	//image1bytes, _, err := image1.Export(ep)
	//err = ioutil.WriteFile("output.jpg", image1bytes, 0644)
	//checkError(err)
}
