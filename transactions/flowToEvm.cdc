import "Teleporter"

transaction(tokenId: UInt64) {
    prepare(signer: auth(BorrowValue) &Account) {
        let bsp= StoragePath(identifier: "poeternal_gate")!
        let teleporter = signer.storage.borrow<auth(Teleporter.Owner) &Teleporter.Gate>(from:bsp) ?? panic("could not borrow teleporter")
        teleporter.flowToEVM(tokenId: tokenId)
    }
}


