package main

import (
	"fmt"

	"github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
)

func main() {
	fmt.Print("\033[H\033[2J")
	o := overflow.Overflow(overflow.WithPrintResults(), overflow.WithFlowForNewUsers(10.0))

	if o.Error != nil {
		panic(o.Error)
	}

	o.Tx("setup", overflow.WithSigner("alice"))
	o.Tx("setup", overflow.WithSigner("bob"))
	message("We have started the emulator, deployed our Poeternal and created two tests users alice and bob")
	pause()

	message("We mint an NFT")
	// We mint the NFT as this admin
	o.Tx("mintNFT",
		overflow.WithSignerServiceAccount(),
		overflow.WithArg("receiver", "bob"),
	)
}

func pause() {
	fmt.Println()
	color.Yellow("press any key to continue")
	fmt.Scanln()
	fmt.Print("\033[H\033[2J")
}

func message(msg string) {
	fmt.Println()
	color.Green(msg)
}
