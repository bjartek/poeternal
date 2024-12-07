import "EVM"
import "EVMHelper"
import "FungibleToken"
import "NonFungibleToken"
import "FlowToken"
import "Teleporter"
import "Poeternal"

transaction(poeternalAddress:String) {

    prepare(account: auth (UnpublishCapability, StorageCapabilities,Storage, SaveValue, LoadValue, PublishCapability, BorrowValue, IssueStorageCapabilityController) &Account) {

        let evmPoeternalAddress = EVM.addressFromString(poeternalAddress)
        let storagePath = StoragePath(identifier: "evm")!
        let coaB = account.storage.borrow<&EVM.CadenceOwnedAccount>(from:storagePath)
        if coaB == nil {
            let publicPath = PublicPath(identifier: "evm")!
            let coa <- EVM.createCadenceOwnedAccount()
            let vaultRef = account.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
                from: /storage/flowTokenVault
            ) ?? panic("Could not borrow reference to the owner's Vault!")
            let sentVault <- vaultRef.withdraw(amount: 1.0) as! @FlowToken.Vault
            coa.deposit(from: <-sentVault)

            account.storage.save<@EVM.CadenceOwnedAccount>(<-coa, to: storagePath)
            let addressableCap = account.capabilities.storage.issue<&EVM.CadenceOwnedAccount>(storagePath)
            account.capabilities.publish(addressableCap, at: publicPath)
        }

        let coa <-  account.storage.load<@EVM.CadenceOwnedAccount>( from: storagePath) ?? panic("Could not load reference to the COA")
        if let helper = coa[EVMHelper.Poeternal] {
            helper.setContractAddress(evmPoeternalAddress)
            account.storage.save<@EVM.CadenceOwnedAccount>(<-coa, to: storagePath)
        }else {
            let extendedCoa <- attach EVMHelper.Poeternal() to <-coa
            extendedCoa[EVMHelper.Poeternal]!.setContractAddress(evmPoeternalAddress)
            account.storage.save<@EVM.CadenceOwnedAccount>(<-extendedCoa, to: storagePath)
        }

        let bsp= StoragePath(identifier: "poeternal_gate")!
        let gate =  account.storage.borrow<&Teleporter.Gate>(from: bsp)

        if gate ==nil{
            let cd = Poeternal.getCollectionData()
            let nftAdminCollection = account.capabilities.storage.issue<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(cd.storagePath)
            //dont like sending in all this
            let coaAdminCap = account.capabilities.storage.issue<auth(EVM.Owner) &EVM.CadenceOwnedAccount>(storagePath)

            // let helper = coa[EVMHelper.Poeternal] ?? panic("Could not get poeternal helper")

            let teleporter <-   Teleporter.createGate(coa: coaAdminCap, cadenceCollection:nftAdminCollection)
            account.storage.save<@Teleporter.Gate>(<- teleporter, to: bsp)
        }

        let collectionData = Poeternal.getCollectionData()
        // Return early if the account already has a collection
        if account.storage.borrow<&{NonFungibleToken.Collection}>(from: collectionData.storagePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- Poeternal.createEmptyCollection(nftType: Type<@Poeternal.NFT>())

        // save it to the account
        account.storage.save(<-collection, to: collectionData.storagePath)

        // create a public capability for the collection
        let collectionCap= account.capabilities.storage.issue<&{NonFungibleToken.Collection}>( collectionData.storagePath)
        account.capabilities.publish(collectionCap, at: collectionData.publicPath)


    }
}
