
import "NonFungibleToken"
import "Poeternal"
import "UniversalCollection"
import "MetadataViews"

transaction {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {
        let collectionData = Poeternal.getCollectionData()
        // Return early if the account already has a collection
        if signer.storage.borrow<&{NonFungibleToken.Collection}>(from: collectionData.storagePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- Poeternal.createEmptyCollection(nftType: Type<@Poeternal.NFT>())

        // save it to the account
        signer.storage.save(<-collection, to: collectionData.storagePath)

        // create a public capability for the collection
        let collectionCap= signer.capabilities.storage.issue<&{NonFungibleToken.Collection}>( collectionData.storagePath)
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)

    }
}
