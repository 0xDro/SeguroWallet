// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./chainLogic.sol";


contract Owner is ChainLogic { 

    

    
    mapping(address => mapping(bytes32 => uint256)) public approvedHashes; 
   
    mapping (address => address) owners;
    uint public numOfOwners;
    address internal constant endsAddress = address(0x1);




 



    function setOwners(address[] memory _owners, uint _numOfSigners) internal {
        require(numOfSigners == 0, "set up done");
        require(_numOfSigners <= _owners.length, "invalid num of signers");
        require(_numOfSigners >= 1, " < 1 signer");

       
        address ownerNow = endsAddress;
        for(uint i = 0; i < _owners.length; i++){
            address currentOwner = _owners[i];

            //perhaps add extra checks on the currentOwner
            require(currentOwner != address(0) && currentOwner != address(this) && currentOwner != endsAddress && currentOwner != ownerNow, "owner checks have failed. Wrong owner inputs");
            require(owners[currentOwner] == address(0), "duplicate owners");
            owners[ownerNow] = currentOwner;
            ownerNow = currentOwner; 

        }
        owners[ownerNow] = endsAddress;
        numOfOwners = _owners.length;
        numOfSigners = _numOfSigners;
        
    }
    
    function addOwners(address[] memory newOwners, uint256 newNumOfSigners, bool shouldProp) public thisContract() {


        for(uint i = 0; i < newOwners.length; i++){
            address currentOwner = newOwners[i];

            require(currentOwner != address(0) && currentOwner != endsAddress && currentOwner != address(this), "invalid owners");
            require(owners[currentOwner] == address(0), "already an owner");

            owners[currentOwner] = owners[endsAddress];
            owners[endsAddress] = currentOwner;
            numOfOwners++;

        }

        if (newNumOfSigners != numOfSigners) {
            changeNumOfSigners(newNumOfSigners, false);
        }

        if(shouldProp) {
            bytes memory data = abi.encodeWithSignature("addOwners(address[],uint256,bool)", newOwners, newNumOfSigners, false);
            propogateTx(data);
        }

        

    }


    function removeOwner(address prevOwner, address owner, uint256 newNumOfSigners, bool shouldProp) public thisContract() {
        require(numOfOwners - 1 >= newNumOfSigners, "invalid signers");
        require(owner != address(0) && owner != endsAddress, "owner dne");
        require(owners[prevOwner] == owner, "invalid previous owner");

        owners[prevOwner] = owners[owner];
        owners[owner] = address(0);
        numOfOwners--;

        if(newNumOfSigners != numOfSigners){
            changeNumOfSigners(newNumOfSigners, false);
        }

        if(shouldProp) {
            bytes memory data = abi.encodeWithSignature("removeOwner(address,address,uint256,bool)", prevOwner, owner, newNumOfSigners, false);
            propogateTx(data);
        }
    }
    
    function swapOwner(address newOwner, address prevOwner, address oldOwner, bool shouldProp) public thisContract() {
        require(newOwner != address(0) && newOwner != address(this) && newOwner != endsAddress && owners[newOwner] == address(0), "invalid new owner");
        require(owners[prevOwner] == oldOwner , "invalid previous owner");

        owners[newOwner] = owners[oldOwner];
        owners[prevOwner] = newOwner;
        owners[oldOwner] = address(0);

        if(shouldProp) {
            bytes memory data = abi.encodeWithSignature("swapOwner(address,address,uint256,bool)", newOwner, prevOwner, oldOwner, false);
            propogateTx(data);
        }
        

        
    }


    function changeNumOfSigners(uint256 newNumOfSigners,  bool shouldProp) public thisContract() {
        require(numOfOwners >= newNumOfSigners, "invalid signers");
        require(newNumOfSigners >= 1, " < 1 signer");
        numOfSigners = newNumOfSigners;

        if(shouldProp){
            bytes memory data = abi.encodeWithSignature("changeNumOfSigners(uint256,bool)", newNumOfSigners, false);
            propogateTx(data);
        }

        
    }

    function getOwners() public view returns(address[] memory) {
        address[] memory ownersArray = new address[](numOfOwners);
        
        uint index = 0;
        address currentOwner = owners[endsAddress];
        while(currentOwner != endsAddress){
            ownersArray[index] = currentOwner;
            currentOwner = owners[currentOwner];
            index++;
        }
        return ownersArray;
    }

    function approveHash(bytes32 hashToApprove) external {
        require(owners[msg.sender] != address(0), "GS030");
        approvedHashes[msg.sender][hashToApprove] = 1;
    }

    
}