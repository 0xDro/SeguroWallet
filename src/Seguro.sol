// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OpsReady} from "lib/ops/contracts/vendor/gelato/OpsReady.sol";
import "lib/safe-contracts/contracts/external/GnosisSafeMath.sol";
import "lib/LayerZero/contracts/interfaces/ILayerZeroEndpoint.sol";
import "lib/LayerZero/contracts/interfaces/ILayerZeroReceiver.sol";
import "./owners.sol";
import "./SigVerifier.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/stargate/contracts/interfaces/IStargateRouter.sol";
import "lib/ops/contracts/interfaces/IResolver.sol";

interface IOps {
    function createTaskNoPrepayment(address _execAddress, bytes4 _execSelector, address _resolverAddress, bytes calldata _resolverData, address _feeToken) external returns (bytes32 task);
    function getFeeDetails() external view returns (uint256, address);
}

contract ScWallet is  Validation, ILayerZeroReceiver, OpsReady, IResolver{


    uint public nonce;

    event recievedEther(uint amount);
    IERC20 internal usdc;
    IStargateRouter internal stargateRouter;

    using GnosisSafeMath for uint256;

    address[] public recipeints;   
    mapping(address => uint16) public recipeintChains;
    mapping(address => uint256) public recipeintPortion;    

    uint public lastAmount;   

    uint public portionLeft = 100;

    constructor(uint16[] memory enabledChains, address payable deploymentFactory) {
        setEnabledChains(enabledChains, false);
        proxy = deploymentFactory;
    }



    function setUp(address[] memory tempOwners, uint256 threshold, address payable _ops, address _usdc, address _stargateRouter,address lzEndpoint, uint16 chainID) public {
        require(numOfSigners == 0);
        usdc = IERC20(_usdc);
        chainId = chainID;
        stargateRouter = IStargateRouter(_stargateRouter);
        endpoint = ILayerZeroEndpoint(lzEndpoint);
        setOwners(tempOwners, threshold);
        addressSet(_ops);
    }
  

    //add functionality for delegateCall
    function executeTx(address to, uint _value, bytes calldata _data, uint _gas, bytes memory signatures) public  returns(bool success) {
        
        bytes memory signedData = encodeTxData(to, _value, _data, _gas);
        checkSignatures(keccak256(signedData), signedData, signatures);

        (success, ) = to.call{value: _value, gas: _gas}(_data);
        require(success == true, "failed transaction");
        nonce++;
        lastAmount = usdc.balanceOf(address(this));
        
    } 
  
  

    
    function deployOnNewChain(uint16[] memory dstChainID, bytes32 salt, address[] memory endpoints, address[] memory _ops, address[] memory _usdc, address[] memory _stargateRouter) public thisContract() {
        
        uint i; 
        uint length = dstChainID.length;
        require(length == endpoints.length);
        
        for (i = 0; i < length; i++) {
            require(getEnabledChains[dstChainID[i]] == false, "chain is already added");
            bytes memory data = abi.encode(address(this), true, salt, getOwners(), numOfSigners, activeChains, dstChainID[i], endpoints[i], _ops[i], _usdc[i], _stargateRouter[i]);
            bytes memory adaptParams = abi.encodePacked(uint16(1), uint256(8000000));

            (uint fee, ) = endpoint.estimateFees(dstChainID[i], proxy, data, false, adaptParams);

            require(address(this).balance > fee + 100000, "insufficient balance");
            endpoint.send{value: fee + 100000}(dstChainID[i], abi.encodePacked(proxy), data, payable(address(owners[endsAddress])), address(0x0), adaptParams);

        }

        setEnabledChains(dstChainID, true);
        

    }
    //----------------------------------------------------GELATO LOGIC-------------------------------------------------------------------------------------------------------------------

    function setPayouts(address[] memory _recipeints, uint16[] memory respectiveChain, uint256[] memory portion, bool shouldProp) public thisContract() {
        IOps(ops).createTaskNoPrepayment(address(this), this.forwardUSDC.selector, address(this), abi.encodeWithSelector(this.checker.selector), ETH);
        uint length = _recipeints.length;
        require(length == respectiveChain.length && length == portion.length);
        require(length < 4, "limited to 4 recipeints");
        uint8 j;
        for(j = 0; j < length; j++){
            require(_recipeints[j] != address(0), "invalid recipeint");
            recipeints.push(_recipeints[j]);
            recipeintChains[_recipeints[j]] = respectiveChain[j];
            require(portionLeft >= 0, "portions off");
            recipeintPortion[_recipeints[j]] = portion[j];
            portionLeft = portionLeft.sub(portion[j]);
        }
        if(shouldProp){
            bytes memory data = abi.encodeWithSignature("setPayouts(address[],uint16[],uint256[],bool)", _recipeints, respectiveChain, portion, false);
            propogateTx(data);
        }
    } 

    

    function forwardUSDC(uint256[] memory amounts) external onlyOps() {
        uint256 currentBalance = usdc.balanceOf(address(this));
        require(currentBalance > lastAmount);

        uint length = recipeints.length;
        require(amounts.length == length);
        uint i;
        for(i = 0; i < length; i++) {
            if(recipeintChains[recipeints[i]] == chainId){
                usdc.transfer(recipeints[i],amounts[i]);
            } else {
                (uint fee, ) = stargateRouter.quoteLayerZeroFee(recipeintChains[recipeints[i]], 1, abi.encodePacked(recipeints[i]), bytes(""), IStargateRouter.lzTxObj(0, 0, "0x"));
                require(address(this).balance > fee + 100000, "not enough funds");
                usdc.approve(address(stargateRouter), amounts[i]);
                stargateRouter.swap{value: fee + 100000}(recipeintChains[recipeints[i]], 1, 1, payable(address(recipeints[i])), amounts[i], amounts[i].sub(amounts[i] / 10), IStargateRouter.lzTxObj(0, 0,"0x"), abi.encodePacked(recipeints[i]), bytes(""));
            }
        }

        lastAmount = usdc.balanceOf(address(this));

        (uint fee2, address feeToken) = IOps(ops).getFeeDetails();
        _transfer(fee2,feeToken);


    }

    function checker() external view override returns(bool canExec, bytes memory execPayload) {
        uint256 currentBal = usdc.balanceOf(address(this));

        canExec = currentBal > lastAmount;

        uint length = recipeints.length;
        uint i;

        uint256[] memory amounts = new uint256[](length);

        uint256 payout = currentBal.sub(lastAmount);

        


        for(i = 0; i < length; i++){
            uint numerator = payout.mul(recipeintPortion[recipeints[i]]);
            uint currentPayout = numerator / 100;

            amounts[i] = currentPayout;
        }


        execPayload = abi.encodeWithSignature("forwardUSDC(uint256[])", amounts);

    }
//--------------------------------------------------------------------------------END GELATO LOGIC----------------------------------------------------------------------------------------------------

    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes calldata _payload) external override {
        require(msg.sender == address(endpoint), "caller must be layerZero Endpoint");
        address fromAdr;
        assembly {
            fromAdr := mload(add(_srcAddress, 20))
        }
        require(fromAdr == address(this), "wrong source address");

        (bool result, ) = address(this).call(_payload);
        require(result);

    }
    

    receive() external payable{
        emit recievedEther(msg.value);
    }





}
