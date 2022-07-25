// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/DeploymentProxy.sol";

contract SeguroDeployer is Script {

    //CHANGE FACTORY ADDRESS
    DeploymentFactory internal factory = DeploymentFactory(payable(address(0x0061F44fa7Fa8aDe70BA7DC69528BB445607A2F2)));

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

        //CHANGE CONFIG
        address shouldBe = 0xFA874F6f50B5198ff927c9865E01E1a984f18859;
        bool shouldOrNot = true;
        bytes32 salt = keccak256("NEWPC3");
        uint256 threshold = 2;
        uint16 chainId = 10011;
        address lzEndpoint = endpointOptimism;
        address opsAdr = opsOptimism;
        address usdc = usdcOptimism;
        address stargate = stargateOptimism;

        address[] memory owners = new address[](2);
        owners[0] = 0x5DA1258F4FfD096750adB6340E8334ecb8A78108;
        owners[1] = 0x026E61d6F6d828fCA74FC48588f0FaC75b8f428e;

        uint16[] memory enabledChains = new uint16[](2);
        enabledChains[0] = 10001;
        enabledChains[1] = 10011;




        vm.startBroadcast();
        address wallet = factory.deployContractAndSetUp(
            shouldBe,
            shouldOrNot,
            salt,
            owners,
            threshold,
            enabledChains,
            chainId,
            lzEndpoint,
            opsAdr,
            usdc,
            stargate
        );
        vm.stopBroadcast();


    }
}