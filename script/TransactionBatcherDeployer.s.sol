// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/transactionBatcher.sol";

contract BatchDeployer is Script{

    TransactionBatcher batcher;

     address endpointRinkeby = 0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA;
    address endpointMumbai = 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8;
    address endpointOptimism = 0x72aB53a133b27Fa428ca7Dc263080807AfEc91b5;
    address endpointArbitrum = 0x4D747149A57923Beb89f22E6B7B97f7D8c087A00;
    address endpointBinance = 0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1;
    address endpointFuji = 0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706;
    address endpointFantom = 0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf;

    address proxy = 0x31bf6CF5434B4155c58eCF651b293aF513CA62B5;


    
    function setUp() public {}


    function run() public {
        vm.startBroadcast();
        batcher = new TransactionBatcher(endpointFantom, proxy);
        vm.stopBroadcast();
    }
}