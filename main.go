package main

import (
	"github.com/bjartek/overflow/v2"
)

func main() {
	o := overflow.Overflow(overflow.WithNetwork("testnet"), overflow.WithPrintResults())
	//	o := overflow.Overflow(overflow.WithPrintResults())

	if o.Error != nil {
		panic(o.Error)
	}

	// poeternalSolAddress := "0xe5892986bdc87a9F6776506E364ef39b64dCe24E"

	poeternalTx := o.TxFN(overflow.WithSigner("poeternal"))

	// we init so we create bridge again
	// poeternalTx("initUser", overflow.WithArg("poeternalAddress", poeternalSolAddress))

	/*
		poeternalTx("teleport",
			overflow.WithArg("tokenId", 42),
		)
	*/

	/*
		mint := Poeternal_PoeternalMint{
			Name: "YourView",
			Lines: []string{
				"To speak of dreams that they hold dear, ",
				"Will bring their joys and passions near.  ",
				"For when their world is seen through you, ",
				"A bond is formed, enduring, true.",
			},
			Colour: "#7ec4cf",
			Author: "0xBjarteK",
			Source: "How to win friends and influence people",
		}
	*/

	id := 42

	poeternalTx("flowToEvm",
		overflow.WithArg("tokenId", id),
	)
	/*
		poeternalTx("mintNFT",
			overflow.WithArg("receiver", "poeternal"),
			overflow.WithArg("metadata", mint),
			overflow.WithArg("id", id),
		)
	*/

	/*
		// we mint a poeternal to the users coa
		poeternalTx("mintEVM",
			overflow.WithArg("metadata", mint),
			overflow.WithArg("tokenId", 42),
			overflow.WithArg("to", "poeternal"),
		)
	*/

	/*

		// We mint the NFT as this admin
	*/
}

type Poeternal_PoeternalMint struct {
	Name   string   `json:"name"`
	Colour string   `json:"colour"`
	Author string   `json:"author"`
	Source string   `json:"source"`
	Lines  []string `json:"lines"`
}
