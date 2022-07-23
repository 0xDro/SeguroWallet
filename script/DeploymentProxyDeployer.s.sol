// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/DeploymentProxy.sol";

contract TestDeployment is Script {

    address endpointRinkeby = 0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA;
    address endpointMumbai = 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8;
    address endpointOptimism = 0x72aB53a133b27Fa428ca7Dc263080807AfEc91b5;
    address endpointArbitrum = 0x4D747149A57923Beb89f22E6B7B97f7D8c087A00;

    DeploymentFactory internal factory;



    function setUp() public {}

    function run() public {
       vm.startBroadcast();
       factory = new DeploymentFactory(endpointArbitrum);
       vm.stopBroadcast();


    }
}
