// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/LayerZero/contracts/interfaces/ILayerZeroEndpoint.sol";



contract ChainLogic {

    address public proxy;

    mapping(uint16 => bool) public getEnabledChains;
    uint16 public numOfEnabledChains; 
    uint256 public numOfSigners = 0;

    uint16[] public activeChains;


    ILayerZeroEndpoint public endpoint;

    uint16 public chainId; 


    modifier thisContract() { 
        if(numOfSigners > 0) {
            require(msg.sender == address(this)); 
        }
        _;
    }


    function setEnabledChains(uint16[] memory ids, bool shouldProp) public thisContract() {

        uint i;
        uint length = ids.length;

        for(i = 0; i < length; i++){

            if(getEnabledChains[ids[i]] == false ){
                //require(ids[i] < 13 && ids[i] > 0, "invalidChainId");
                getEnabledChains[ids[i]] = true;
                activeChains.push(ids[i]);
                numOfEnabledChains++;
            }
        }
        if(shouldProp){
            bytes memory _data = abi.encodeWithSignature("setEnabledChains(uint16[],bool)", ids,false);
            propogateTx(_data);
        }
        
    }

    function propogateTx(bytes memory data) public thisContract() {

      
        uint i;
        for(i = 0; i < activeChains.length; i++){
            if(activeChains[i] != chainId){
                (uint nativeFee, ) =  endpoint.estimateFees(activeChains[i], address(this), data, false, bytes(""));
                require(address(this).balance > nativeFee + 10000000, "not enough native token to pay fee");
                endpoint.send{value: nativeFee + 10000000}(activeChains[i], abi.encodePacked(address(this)), data, payable(address(this)) ,address(0x0), bytes(""));
            }
        }


    }

}   