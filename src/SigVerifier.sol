// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "contracts/dependencies/ISignatureValidator.sol";
import "contracts/dependencies/SignatureDecoder.sol";
import "contracts/dependencies/GnosisSafeMath.sol";
import "./ownable.sol";

contract Validation is SignatureDecoder, ISignatureValidatorConstants, Owner{

    using GnosisSafeMath for uint256;

    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
    bytes32 private constant SIGNED_DATA_SAFEHASH = keccak256("executeTx(address to, uint _value, bytes calldata _data, uint _gas, bytes memory signatures)");



    function domainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, block.chainid, this));
    }

    function encodeTxData(address to, uint _value, bytes calldata _data, uint _gas) public view returns(bytes memory){
        bytes32 dataHash =  keccak256(abi.encode(
            SIGNED_DATA_SAFEHASH,
            to,
            _value,
            keccak256(_data),
            _gas
        ));
        return(abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparator(), dataHash));

    }
    function getTxHashToBeSigned(address to, uint _value, bytes calldata _data, uint _gas) public view returns(bytes32){
        return(keccak256(encodeTxData(to, _value, _data, _gas)));
    }

    function checkSignatures(
        bytes32 dataHash,
        bytes memory data,
        bytes memory signatures
    ) public view {
        // Load threshold to avoid multiple storage loads
        uint256 _threshold = numOfSigners;
        // Check that a threshold is set
        require(_threshold > 0, "numOfSigners not set");
        checkNSignatures(dataHash, data, signatures, _threshold);
    }

    function checkNSignatures(
        bytes32 dataHash,
        bytes memory data,
        bytes memory signatures,
        uint256 requiredSignatures
    ) public view {
        // Check that the provided signature data is not too short
        require(signatures.length >= requiredSignatures.mul(65), "GS020");
        // There cannot be an owner with address 0.
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < requiredSignatures; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            if (v == 0) {
                currentOwner = address(uint160(uint256(r)));

                
                require(uint256(s) >= requiredSignatures.mul(65), "GS021");

 
                require(uint256(s).add(32) <= signatures.length, "GS022");

      
                uint256 contractSignatureLen;
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    contractSignatureLen := mload(add(add(signatures, s), 0x20))
                }
                require(uint256(s).add(32).add(contractSignatureLen) <= signatures.length, "GS023");

                // Check signature
                bytes memory contractSignature;
                // solhint-disable-next-line no-inline-assembly
                assembly {
                   
                    contractSignature := add(add(signatures, s), 0x20)
                }
                require(ISignatureValidator(currentOwner).isValidSignature(data, contractSignature) == EIP1271_MAGIC_VALUE, "GS024");
            } else if (v == 1) {
                currentOwner = address(uint160(uint256(r)));
        
                require(msg.sender == currentOwner || approvedHashes[currentOwner][dataHash] != 0, "GS025");
            } else if (v > 30) {
             
                currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v - 4, r, s);
            } else {
               
                currentOwner = ecrecover(dataHash, v, r, s);
            }
            require(currentOwner > lastOwner &&  owners[currentOwner] != address(0)  && currentOwner != endsAddress, "Invalid Signature");
            lastOwner = currentOwner;
        } 
    }

}