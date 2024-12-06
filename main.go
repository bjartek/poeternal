package main

import (
	"github.com/bjartek/overflow/v2"
)

func main() {
	o := overflow.Overflow(overflow.WithNetwork("testnet"), overflow.WithPrintResults())

	if o.Error != nil {
		panic(o.Error)
	}

	poeternalTx := o.TxFN(overflow.WithSigner("poeternal"))

	poeternalTx("init")

	//	poeternalTx("setup")

	/*
		mint := Poeternal_PoeternalMint{
			Name: "YourView",
			Lines: []string{
				"To speak of dreams that they hold dear, ",
				"Will bring their joys and passions near.  ",
				"For when their world is seen through you, ",
				"A bond is formed, enduring, true.",
			},
			Colour: "#F8D6D6",
			Author: "0xBjarteK",
			Source: "How to win friends and influence people",
		}
		// We mint the NFT as this admin
		poeternalTx("mintNFT",
			overflow.WithArg("receiver", "poeternal"),
			overflow.WithArg("metadata", mint),
		).Print()
	*/
}

type Poeternal_PoeternalMint struct {
	Name   string   `json:"name"`
	Colour string   `json:"colour"`
	Author string   `json:"author"`
	Source string   `json:"source"`
	Lines  []string `json:"lines"`
}
