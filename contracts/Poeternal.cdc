import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "SimpleNFT"
import "Base64Util"

access(all) contract Poeternal : SimpleNFT, NonFungibleToken {

    access(all) entitlement Admin

    access(all) struct PoeternalMint {
        access(all) let name: String
        access(all) let lines: [String;4]
        access(all) let colour: String
        access(all) let author: String
        access(all) let source: String

        init(name: String, lines: [String;4], author: String, colour:String, source:String) {
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
            id: UInt64,
            metadata: PoeternalMint
        ) {
            self.metadata=metadata
            self.id=id
            self.image=self.renderImage()

        }

        access(all) view fun getMetadata() : PoeternalMint {
            return self.metadata
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
                description: String.join(self.metadata.lines.toVariableSized(), separator:"\n"),
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
            MetadataViews.Trait(name: "author", value: "@".concat(self.metadata.author), displayType: "string", rarity: nil),
            MetadataViews.Trait(name: "source", value: self.metadata.source, displayType: "string", rarity: nil)

            ]
            return MetadataViews.Traits(traits)


        }

        //add rarity here maybe? we can add that later
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
                url: "https://github.com/bjartek/poeternal/blob/main/poeternal.jpeg?raw=true"
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
                "twitter": MetadataViews.ExternalURL("https://twitter.com/poeternal")
            }
        )
    }

    access(all) resource Minter {
        access(Admin) fun mintNFT(id: UInt64, metadata: PoeternalMint, receiver : &{NonFungibleToken.Receiver}){
            Poeternal.mintNFT(id: id, metadata: metadata, receiver: receiver)
        }
    }

    access(account) fun mintNFT(id:UInt64, metadata: PoeternalMint, receiver : &{NonFungibleToken.Receiver}){
        let nft <- create NFT(id:id, metadata: metadata)
        emit Minted(id: id, uuid:nft.uuid, to: receiver.owner?.address, type: Type<@Poeternal.NFT>().identifier)
        receiver.deposit(token: <- nft)
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
