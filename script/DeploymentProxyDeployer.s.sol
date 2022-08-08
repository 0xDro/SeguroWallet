// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/DeploymentProxy.sol";

contract TestDeployment is Script {
    address endpointRinkeby = 0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA;
    address endpointMumbai = 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8;
    address endpointOptimism = 0x72aB53a133b27Fa428ca7Dc263080807AfEc91b5;
    address endpointArbitrum = 0x4D747149A57923Beb89f22E6B7B97f7D8c087A00;
    address endpointBinance = 0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1;
    address endpointFuji = 0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706;
    address endpointFantom = 0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf;


    /*
    rinkeby = vm.createFork(
            "https://eth-rinkeby.alchemyapi.io/v2/imV5d8CKQjE26zjVYlFnDx2IsgIaJIen"
        );
        mumbai = vm.createFork(

            "https://polygon-mumbai.g.alchemy.com/v2/NfoEgCLeIBcOFtHYrrU1cx-sHNHVbgdD"
        );
        optimism = vm.createFork(
            "https://opt-kovan.g.alchemy.com/v2/PEWWIsHZ_dNvgBsdIg3j7K4-LUQSAHAT"
        );
        arbitrum = vm.createFork(
            "https://arb-rinkeby.g.alchemy.com/v2/00xJvEFKaEp3_d-uokM5uKGPGiroo4XN"
        );
        binance = vm.createFork("https://bsctestapi.terminet.io/rpc");
        fuji = vm.createFork("https://rpc.ankr.com/avalanche_fuji");
        fantom = vm.createFork("https://rpc.testnet.fantom.network");

    */
    

    function setUp() public {
        
    }

    function run() public {
        vm.startBroadcast();

        
        DeploymentFactory factory0 = new DeploymentFactory(endpointFantom);

        vm.stopBroadcast();
    }
}
