// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Seguro.sol";

contract DeployNewChain is Script {

    ScWallet internal seguro = ScWallet(payable(address(0xFA874F6f50B5198ff927c9865E01E1a984f18859)));

    address endpointRinkeby = 0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA;
    address endpointMumbai = 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8;
    address endpointOptimism = 0x72aB53a133b27Fa428ca7Dc263080807AfEc91b5;
    address endpointArbitrum = 0x4D747149A57923Beb89f22E6B7B97f7D8c087A00;

    address stargateRinkeby = 0x82A0F5F531F9ce0df1DF5619f74a0d3fA31FF561;
    address stargateMumbai = 0x817436a076060D158204d955E5403b6Ed0A5fac0;
    address stargateOptimism = 0xCC68641528B948642bDE1729805d6cf1DECB0B00;
    address stargateArbitrum = 0x6701D9802aDF674E524053bd44AA83ef253efc41;

    address usdcRinkeby = 0x1717A0D5C8705EE89A8aD6E808268D6A826C97A4;
    address usdcMumbai = 0x742DfA5Aa70a8212857966D491D67B09Ce7D6ec7;
    address usdcOptimism = 0x567f39d9e6d02078F357658f498F80eF087059aa;
    address usdcArbitrum = 0x1EA8Fb2F671620767f41559b663b86B1365BBc3d;

    address opsRinkeby = 0x8c089073A9594a4FB03Fa99feee3effF0e2Bc58a;
    address opsMumbai = 0xB3f5503f93d5Ef84b06993a1975B9D21B962892F;
    address opsOptimism = 0xB3f5503f93d5Ef84b06993a1975B9D21B962892F;


    
    function setUp() public {

    }

    function run() public {

        uint16[] memory chainID = new uint16[](1);
        chainID[0] = 10009;

        bytes32 salt = keccak256("NEWPC3");

        address[] memory endpoints = new address[](1);
        endpoints[0] = endpointMumbai;
        address[] memory ops = new address[](1);
        ops[0] = opsMumbai;
        address[] memory usdc = new address[](1);
        usdc[0] = usdcMumbai;
        address[] memory stargate = new address[](1);
        stargate[0] = stargateMumbai;

        
        bytes memory data = abi.encodeWithSignature("deployOnNewChain(uint16[],bytes32,address[],address[],address[],address[])", chainID, salt, endpoints, ops, usdc, stargate);

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