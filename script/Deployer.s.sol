// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/DeploymentProxy.sol";

contract SeguroDeployer is Script {

    //CHANGE FACTORY ADDRESS
    DeploymentFactory internal factory = DeploymentFactory(payable(address(0xc8d1eae227e9095ea6d826bf1d1ee1e56b219347)));

    
    function setUp() public {

    }

    function run() public {
        vm.startBroadcast();
        factory.deployContractAndSetUp(shouldBe, shouldOrNot, salt);
        vm.stopBroadcast();


    }
}