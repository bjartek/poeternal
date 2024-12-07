import "Poeternal"
import "EVM"
import "EVMHelper"
import "NonFungibleToken"

access(all) contract Teleporter {

    access(all) entitlement Owner
    access(all) event Bridged(id:UInt64, type:String, from:String, to:String)

    access(all) resource Gate {

        access(self) let adminCoa : Capability<auth(EVM.Owner) &EVM.CadenceOwnedAccount>
        access(self) let nftCollection:  Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>

        //to make this generic we need? a standard way of getting mintdata from evm. 
        //we need to have an adapter that knows how to get mintData for that type with a given id on a given chain.
        access(Owner) fun evmToFlow(tokenId:UInt64) {

            //TODO: need to create a CoaHelperStruct
            let c = self.adminCoa.borrow() ?? panic("could not borrow coa")
            let helper= c[EVMHelper.Poeternal] ?? panic("could not borrow helper")

            let account = self.owner!

            let metadata = helper.getMintData(tokenId: UInt256(tokenId))

            if metadata == nil{
                panic("could not find metadata")
            }

            let data = metadata!

            let cd = Poeternal.getCollectionData()
            let collection = account.capabilities.borrow<&{NonFungibleToken.Receiver}>(cd.publicPath) ?? panic("Could not get receiver reference to the NFT Collection")

            let mintData = Poeternal.PoeternalMint(
                name: data.name,
                lines:data.lines,
                author: data.author, 
                colour: data.colour,
                source:data.source, 
            )

            //we burn on evm
            helper.burn(tokenId: UInt256(tokenId))

            Poeternal.mintNFT(id: tokenId, metadata: mintData, receiver: collection)

            emit Bridged(id: tokenId, type: Type<@Poeternal.NFT>().identifier, from: c.address().toString(), to: account.address.toString())
        }

        access(Owner) fun flowToEVM(tokenId:UInt64) {


            let c = self.adminCoa.borrow() ?? panic("Could not get coa")
            let helper= c[EVMHelper.Poeternal] ?? panic("could not get helper")
            let nftCollection = self.nftCollection.borrow() ?? panic("could not get nft collection")

            let nft <- nftCollection.withdraw(withdrawID: tokenId) as! @Poeternal.NFT
            let metadata= nft.getMetadata()

            let mintResult = helper.mint(to: c.address(), newTokenId: UInt256(tokenId), name: metadata.name, lines:metadata.lines, author: metadata.author, source: metadata.source, colour: metadata.colour)   

            if mintResult == nil{
                panic("could not mint on evm")
            }
            emit Bridged(id: tokenId, type: Type<@Poeternal.NFT>().identifier, from: self.owner!.address.toString(), to: c.address().toString())

            destroy <- nft
        }

        init(coa: Capability<auth(EVM.Owner) &EVM.CadenceOwnedAccount>, cadenceCollection: Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>) {
            self.adminCoa=coa
            self.nftCollection=cadenceCollection
        }
    }

    access(all) fun createGate(coa: Capability<auth(EVM.Owner) &EVM.CadenceOwnedAccount>, cadenceCollection: Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>) : @Gate {
        return <- create Gate( coa: coa, cadenceCollection: cadenceCollection)
    }

}
