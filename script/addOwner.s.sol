// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Seguro.sol";

contract addOwner is Script {

    ScWallet internal seguro = ScWallet(payable(address(0xFA874F6f50B5198ff927c9865E01E1a984f18859)));

    
    function setUp() public {

    }

    function run() public {
        address[] memory newOwners = new address[](1);
        newOwners[0] = 0xB5052707bF2d17b6C6f58193D42730f4992f0497;

        uint256 threshold = 2;
        bool shouldProp = true;

        bytes memory data = abi.encodeWithSignature("addOwners(address[],uint256,bool)", newOwners, threshold, shouldProp);

        bytes32 txHash = seguro.getTxHashToBeSigned(payable(address(seguro)), 0, data, 3000000);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(69443480337961242545442891203500771485145471382527170566543962106166108394877,txHash);
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(71829471896628395231254030745849192253528950559110968757256975056336735546685,txHash);

        bytes memory sig = abi.encodePacked(r,s,v);
        bytes memory sig1 = abi.encodePacked(r1,s1,v1);
        
        vm.startBroadcast();
        seguro.executeTx(payable(address(seguro)), 0, data, 3000000, abi.encodePacked(sig1,sig));
        vm.stopBroadcast();
    }      
}