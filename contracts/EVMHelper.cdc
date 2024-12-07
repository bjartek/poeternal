import "EVM"

access(all) contract EVMHelper{

    access(all) struct PoeternalMetadata { 
        access(all) let name: String
        access(all) let lines: [String;4]
        access(all) let colour: String
        access(all) let author: String
        access(all) let source: String
        access(all) let id: UInt256

        init(id:UInt256, name: String, lines: [String;4], author: String, colour:String, source:String) {
            self.id=id
            self.name=name 
            self.lines=lines 
            self.author=author
            self.colour=colour
            self.source=source
        }
    }



    access(all) attachment Poeternal for EVM.CadenceOwnedAccount {
        access(EVM.Owner) var contractAddress: EVM.EVMAddress

        access(EVM.Owner) fun call(
            _ signature:String,
            _ returnTypes: [Type],
            _ data:[AnyStruct]?
        ): AnyStruct{

            var data = EVM.encodeABIWithSignature(signature, data ??  [] as [AnyStruct])
            var lastResult = base.call(
                to: self.contractAddress,
                data: data,
                gasLimit: 15000000,
                value: EVM.Balance(attoflow:0)
            )

            if lastResult.status != EVM.Status.successful{
                return nil
            }

            var res = EVM.decodeABI(types: returnTypes, data: lastResult.data)

            if res.length==1{
                return res[0]
            }
            return res
        }

        access(EVM.Owner) fun setContractAddress(_ contractAddress: EVM.EVMAddress){
            self.contractAddress = contractAddress
        }

        init(){
            self.contractAddress = base.address()
        }
        // Generated functions
        access(EVM.Owner) fun DEFAULT_ADMIN_ROLE(): [UInt8]? {
            return self.call("DEFAULT_ADMIN_ROLE()", [Type<[UInt8]>()], nil) as? [UInt8]
        }
        access(EVM.Owner) fun MINTER_ROLE(): [UInt8]? {
            return self.call("MINTER_ROLE()", [Type<[UInt8]>()], nil) as? [UInt8]
        }
        access(EVM.Owner) fun approve(to: EVM.EVMAddress, tokenId: UInt256) {
            self.call("approve(address,uint256)", [], [to, tokenId])
        }
        access(EVM.Owner) fun balanceOf(owner: EVM.EVMAddress): UInt256? {
            return self.call("balanceOf(address)", [Type<UInt256>()], [owner]) as? UInt256
        }
        access(EVM.Owner) fun burn(tokenId: UInt256) {
            self.call("burn(uint256)", [], [tokenId])
        }
        access(EVM.Owner) fun getApproved(tokenId: UInt256): EVM.EVMAddress? {
            return self.call("getApproved(uint256)", [Type<EVM.EVMAddress>()], [tokenId]) as? EVM.EVMAddress
        }
        access(EVM.Owner) fun getEggCattitude(tokenId: UInt256): UInt256? {
            return self.call("getEggCattitude(uint256)", [Type<UInt256>()], [tokenId]) as? UInt256
        }
        access(EVM.Owner) fun getEggDescription(tokenId: UInt256): String? {
            return self.call("getEggDescription(uint256)", [Type<String>()], [tokenId]) as? String
        }
        access(EVM.Owner) fun getEggName(tokenId: UInt256): String? {
            return self.call("getEggName(uint256)", [Type<String>()], [tokenId]) as? String
        }
        access(EVM.Owner) fun getEggSpeed(tokenId: UInt256): String? {
            return self.call("getEggSpeed(uint256)", [Type<String>()], [tokenId]) as? String
        }
        access(EVM.Owner) fun getEggTier(tokenId: UInt256): String? {
            return self.call("getEggTier(uint256)", [Type<String>()], [tokenId]) as? String
        }
        access(EVM.Owner) fun getEggVariant(tokenId: UInt256): String? {
            return self.call("getEggVariant(uint256)", [Type<String>()], [tokenId]) as? String
        }
        access(EVM.Owner) fun getRoleAdmin(role: [UInt8]): [UInt8]? {
            return self.call("getRoleAdmin(bytes32)", [Type<[UInt8]>()], [role]) as? [UInt8]
        }
        access(EVM.Owner) fun grantRole(role: [UInt8], account: EVM.EVMAddress) {
            self.call("grantRole(bytes32,address)", [], [role, account])
        }
        access(EVM.Owner) fun hasRole(role: [UInt8], account: EVM.EVMAddress): Bool? {
            return self.call("hasRole(bytes32,address)", [Type<Bool>()], [role, account]) as? Bool
        }
        access(EVM.Owner) fun isApprovedForAll(owner: EVM.EVMAddress, operator: EVM.EVMAddress): Bool? {
            return self.call("isApprovedForAll(address,address)", [Type<Bool>()], [owner, operator]) as? Bool
        }

        access(EVM.Owner) fun mint(to: EVM.EVMAddress, newTokenId: UInt256, name: String, lines: [String;4], author:String , source: String, colour:String): UInt256? {
            return self.call("mint(address,uint256,string,string[4],string,string,string)", [Type<UInt256>()], [to, newTokenId, name, lines, author, source, colour]) as? UInt256
        }
        access(EVM.Owner) fun getMintData(tokenId: UInt256): PoeternalMetadata? {


            let linesType = ConstantSizedArrayType(type: Type<String>(), size: 4)
            let stringType = Type<String>()

            let returnData : [AnyStruct]? =self.call("getMintData(uint256)", [Type<UInt256>(), stringType, linesType, stringType, stringType, stringType], [tokenId]) as? [AnyStruct] 
            if returnData == nil{
                return nil
            }

            let data = returnData!

            let metadata = PoeternalMetadata(
                id: data[0] as! UInt256,
                name: data[1] as! String,
                lines: data[2] as! [String;4],
                author: data[3] as! String,
                colour: data[4] as! String,
                source: data[5] as! String
            )
            return metadata
        }

        access(EVM.Owner) fun name(): String? {
            return self.call("name()", [Type<String>()], nil) as? String
        }
        access(EVM.Owner) fun ownerOf(tokenId: UInt256): EVM.EVMAddress? {
            return self.call("ownerOf(uint256)", [Type<EVM.EVMAddress>()], [tokenId]) as? EVM.EVMAddress
        }
        access(EVM.Owner) fun renounceRole(role: [UInt8], callerConfirmation: EVM.EVMAddress) {
            self.call("renounceRole(bytes32,address)", [], [role, callerConfirmation])
        }
        access(EVM.Owner) fun revokeRole(role: [UInt8], account: EVM.EVMAddress) {
            self.call("revokeRole(bytes32,address)", [], [role, account])
        }

        access(EVM.Owner) fun safeTransferFrom(from: EVM.EVMAddress, to: EVM.EVMAddress, tokenId: UInt256, data: [UInt8]) {
            self.call("safeTransferFrom(address,address,uint256,bytes)", [], [from, to, tokenId, data])
        }
        access(EVM.Owner) fun setApprovalForAll(operator: EVM.EVMAddress, approved: Bool) {
            self.call("setApprovalForAll(address,bool)", [], [operator, approved])
        }
        access(EVM.Owner) fun supportsInterface(interfaceId: [UInt8]): Bool? {
            return self.call("supportsInterface(bytes4)", [Type<Bool>()], [interfaceId]) as? Bool
        }
        access(EVM.Owner) fun symbol(): String? {
            return self.call("symbol()", [Type<String>()], nil) as? String
        }
        access(EVM.Owner) fun tokenURI(tokenId: UInt256): String? {
            return self.call("tokenURI(uint256)", [Type<String>()], [tokenId]) as? String
        }
        access(EVM.Owner) fun transferFrom(from: EVM.EVMAddress, to: EVM.EVMAddress, tokenId: UInt256) {
            self.call("transferFrom(address,address,uint256)", [], [from, to, tokenId])
        }
        access(EVM.Owner) fun variantDescription(arg: String): String? {
            return self.call("variantDescription(string)", [Type<String>()], [arg]) as? String
        }


    }
}
