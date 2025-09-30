// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test, console} from "forge-std/Test.sol";
import {LiquidityPool} from "src/LiquidityPool.sol";
import {DeployLiquidityPool} from "script/DeployLiquidityPool.s.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract TestLiquidityPool is Test {
    DeployLiquidityPool public deployer;
    LiquidityPool public pool;

    function setUp() public {
        deployer = new DeployLiquidityPool();
        pool = deployer.run();
    }

    function testCheckTotalSupply() public view {
        (address tokenA, address tokenB) = pool.getTokenAddresses();
        uint256 totalSupplyTokenA = IERC20(tokenA).totalSupply();
        uint256 totalSupplyTokenB = IERC20(tokenB).totalSupply();
        assertEq(totalSupplyTokenA, deployer.initialMintTokens());
        assertEq(totalSupplyTokenB, deployer.initialMintTokens());
    }
}
