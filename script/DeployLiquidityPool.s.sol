// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {LiquidityPool} from "src/LiquidityPool.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract DeployLiquidityPool is Script {
    uint256 public initialMintTokens = 1000000;

    function run() public returns (LiquidityPool) {
        LiquidityPool pool;
        vm.startBroadcast();
        (address tokenA, address tokenB) = getTokenAddresses(initialMintTokens);
        pool = new LiquidityPool(tokenA, tokenB);
        vm.stopBroadcast();
        return pool;
    }

    function getTokenAddresses(uint256 _mintAmount) public returns (address _tokenA, address _tokenB) {
        ERC20Mock tokenA = new ERC20Mock();
        ERC20Mock tokenB = new ERC20Mock();
        tokenA.mint(DEFAULT_SENDER, _mintAmount);
        tokenB.mint(DEFAULT_SENDER, _mintAmount);
        return (address(tokenA), address(tokenB));
    }
}
