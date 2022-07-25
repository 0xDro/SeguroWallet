// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Seguro.sol";

contract GelatoInit is Script {

    ScWallet internal seguro = ScWallet(payable(address(0xFA874F6f50B5198ff927c9865E01E1a984f18859)));

    function setUp() public {}


    function run() public {
        address[] memory recipients = new address[](2);
        recipients[0] = 0x026E61d6F6d828fCA74FC48588f0FaC75b8f428e;
        recipients[1] = 0xB5052707bF2d17b6C6f58193D42730f4992f0497;
        uint16[] memory Ids = new uint16[](2);
        Ids[0] = 10011;
        Ids[1] = 10001;
        uint256[] memory portion = new uint256[](2);
        portion[0] = 50;
        portion[1] = 25;

        bool shouldProp = true;

        bytes memory data = abi.encodeWithSignature("setPayouts(address[],uint16[],uint256[],bool)", recipients, Ids, portions, shouldProp);

        bytes32 txHash = seguro.getTxHashToBeSigned(address(seguro), 0, data, 3000000);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(69443480337961242545442891203500771485145471382527170566543962106166108394877,txHash);
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(81281661507713928939759658850176124651094913481488961288092444173335050138277,txHash);
        bytes memory sig = abi.encodePacked(r,s,v);
        bytes memory sig1 = abi.encodePacked(r1,s1,v1);

        vm.startBroadcast();
        seguro.executeTx(address(seguro), 0, data, 3000000, abi.encodePacked(sig,sig1));
        vm.stopBroadcast();
    }
}