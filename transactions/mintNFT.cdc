
import "NonFungibleToken"
import "Poeternal"
import "UniversalCollection"
import "MetadataViews"

transaction(receiver:Address) {

    let minter :&Poeternal.Minter
    let collection : &{NonFungibleToken.Receiver}

    prepare(signer: auth(BorrowValue) &Account) {
        self.minter =signer.storage.borrow<&Poeternal.Minter>(from: /storage/poeternalNFTMinter)!
        let cd = Poeternal.getCollectionData()
        self.collection = getAccount(receiver).capabilities.borrow<&{NonFungibleToken.Receiver}>(cd.publicPath) ?? panic("Could not get receiver reference to the NFT Collection")
    }

    execute {
        self.minter.mintNFT(metadata: {"Foo": "Bar"}, receiver:self.collection)
    }
}
