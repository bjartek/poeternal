import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "SimpleNFT"
import "Base64Util"

access(all) contract Poeternal : SimpleNFT, NonFungibleToken {



    access(all) struct PoeternalMint {
        access(all) let name: String
        access(all) let lines: [String]
        access(all) let colour: String
        access(all) let author: String
        access(all) let source: String


        init(name: String, lines: [String], author: String, colour:String, source:String) {
            self.name=name 
            self.lines=lines 
            self.author=author
            self.colour=colour
            self.source=source
        }


        access(all) fun generateSVG() : String {
            let color = self.colour
            let lines=self.lines
            let author=self.author
            let svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 600 380\" width=\"600\" height=\"380\">"
            .concat("<rect width=\"100%\" height=\"100%\" fill=\"").concat(color).concat("\" />") // Background color
            .concat("<text x=\"50%\" y=\"20%\" font-family=\"Cursive, Georgia, serif\" font-size=\"36\" text-anchor=\"middle\" fill=\"#3D2B1F\" font-style=\"italic\">").concat(lines[0]).concat("</text>")
            .concat("<text x=\"50%\" y=\"35%\" font-family=\"Cursive, Georgia, serif\" font-size=\"36\" text-anchor=\"middle\" fill=\"#3D2B1F\" font-style=\"italic\">").concat(lines[1]).concat("</text>")
            .concat("<text x=\"50%\" y=\"50%\" font-family=\"Cursive, Georgia, serif\" font-size=\"36\" text-anchor=\"middle\" fill=\"#3D2B1F\" font-style=\"italic\">").concat(lines[2]).concat("</text>")
            .concat("<text x=\"50%\" y=\"65%\" font-family=\"Cursive, Georgia, serif\" font-size=\"36\" text-anchor=\"middle\" fill=\"#3D2B1F\" font-style=\"italic\">").concat(lines[3]).concat("</text>")
            .concat("<text x=\"50%\" y=\"85%\" font-family=\"'Brush Script MT', cursive\" font-size=\"36\" font-style=\"italic\" text-anchor=\"middle\" fill=\"#3D2B1F\" alignment-baseline=\"middle\">").concat(author).concat("</text>")
            .concat("</svg>")
            return svg
        }

    }

    access(all) let minterPath : StoragePath
    access(all) event Minted(id: UInt64, uuid: UInt64, to: Address?, type: String)

    access(all) let nftType: Type

    /// The only thing that an NFT really needs to have is this resource definition
    access(all) resource NFT : NonFungibleToken.NFT {
        /// Arbitrary trait mapping metadata
        access(self) let metadata: PoeternalMint

        access(self) let image: String //we prerender this
        access(all) let id:UInt64

        init(
            metadata: PoeternalMint
        ) {
            self.metadata=metadata
            self.id=self.uuid
            self.image=self.renderImage()

        }

        /// Uses the poeternal NFT views
        access(all) view fun getViews(): [Type] {
            return [
            Type<MetadataViews.Display>(),
            Type<MetadataViews.Traits>(),
            Type<MetadataViews.NFTCollectionDisplay>(),
            Type<MetadataViews.NFTCollectionData>()
            ]
        }

        access(all) fun resolveDisplay() : MetadataViews.Display {
            return MetadataViews.Display(
                name: self.metadata.name,
                description: String.join(self.metadata.lines, separator:"\n"),
                thumbnail: MetadataViews.HTTPFile(
                    url: self.image
                )
            )
        }


        access(all) fun renderImage() : String {
            let svg = self.metadata.generateSVG()
            let svgEncoded = Base64Util.encode(svg)
            return "data:image/svg+xml;base64,".concat(svgEncoded)
        }

        access(all) fun resolveTraits() : MetadataViews.Traits {

            let traits: [MetadataViews.Trait] = [
            //TODO: add more traits
            MetadataViews.Trait(name: "author", value: "@".concat(self.metadata.author), displayType: "string", rarity: nil),
            MetadataViews.Trait(name: "source", value: self.metadata.source, displayType: "string", rarity: nil)

            ]
            return MetadataViews.Traits(traits)


        }

        //TODO: add more views
        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>(): return self.resolveDisplay()
                case Type<MetadataViews.Traits>(): return self.resolveTraits()
                case Type<MetadataViews.NFTCollectionData>(): return Poeternal.getCollectionData()
                case Type<MetadataViews.NFTCollectionDisplay>(): return Poeternal.getCollectionDisplay()
            }
            return nil
        }

        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <- Poeternal.createEmptyCollection(nftType: Type<@Poeternal.NFT>())
        }
    }


    access(all) view fun getCollectionDisplay() : MetadataViews.NFTCollectionDisplay {

        let media = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
                //TODO fix
                url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
            ),
            mediaType: "image/svg+xml"
        )
        return MetadataViews.NFTCollectionDisplay(
            name: "Poeternal",
            description: "Eternal poetry in the cryptoverse.",
            externalURL: MetadataViews.ExternalURL("https://poeternal.xyz"),
            squareImage: media,
            bannerImage: media,
            socials: {
                //TODO: add twitter
                "twitter": MetadataViews.ExternalURL("https://twitter.com/poeternal")
            }
        )
    }

    access(all) resource Minter {
        access(all) fun mintNFT(metadata: PoeternalMint, receiver : &{NonFungibleToken.Receiver}){
            let nft <- create NFT(metadata: metadata)
            emit Minted(id: nft.id, uuid:nft.uuid, to: receiver.owner?.address, type: Type<@Poeternal.NFT>().identifier)
            receiver.deposit(token: <- nft)
        }
    }

    //I really do not want this method here, but i need to because of an bug in inheritance of interface 
    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- Poeternal.createEmptyUniversalCollection()
    }

    init() {
        let minter <- create Minter()
        self.nftType= Type<@Poeternal.NFT>() //we cannot have generics so we make a poor mans generics

        self.minterPath=/storage/poeternalNFTMinter
        self.account.storage.save(<-minter, to: self.minterPath)
    }


}


