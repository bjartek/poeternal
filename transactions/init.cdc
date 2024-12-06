import "EVM"
import "FlowToken"
import "FungibleToken"

transaction() {

    prepare(account: auth (UnpublishCapability, StorageCapabilities,Storage, SaveValue, LoadValue, PublishCapability, BorrowValue, IssueStorageCapabilityController) &Account) {

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
    }

}
