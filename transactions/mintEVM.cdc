import "Poeternal"
import "EVM"
import "EVMHelper"

transaction(to:Address, tokenId: UInt256, metadata: Poeternal.PoeternalMint) {

    let study: auth(EVM.Owner) &EVMHelper.Poeternal
    let receiver: EVM.EVMAddress

    prepare(signer: auth(BorrowValue) &Account) {
        let receiverAccount = getAccount(to)
        let receiverCoa = receiverAccount.capabilities.borrow<&EVM.CadenceOwnedAccount>(/public/evm) ?? panic("Could not borrow evm account for flow address ".concat(to.toString()))
        self.receiver=receiverCoa.address()

        let coa = signer.storage.borrow<auth(EVM.Owner) &EVM.CadenceOwnedAccount>(
            from: /storage/evm
        ) ?? panic("Could not borrow reference to the COA")

        self.study=coa[EVMHelper.Poeternal] ?? panic("EVMHelper not attached to coa")

    }

    execute {
        self.study.mint(to: self.receiver, newTokenId: tokenId, name: metadata.name, lines:metadata.lines, author: metadata.author, source: metadata.source, colour: metadata.colour)   
    }
}


