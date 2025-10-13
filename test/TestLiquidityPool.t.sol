// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test, console} from "forge-std/Test.sol";
import {LiquidityPool} from "src/LiquidityPool.sol";
import {DeployLiquidityPool} from "script/DeployLiquidityPool.s.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Math} from "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract TestLiquidityPool is Test {
    using Math for uint112;

    DeployLiquidityPool public deployer;
    LiquidityPool public pool;
    address user1 = makeAddr("User1");
    uint256 lpTokensTransfer = 100;
    uint112 MINIMUM_LIQUIDITY = 10 ** 3;

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

    function testTransferShouldRevert() public {
        vm.expectRevert();
        pool.transfer(user1, lpTokensTransfer);
    }

    function testAddLiquidity(uint112 amountDesiredA, uint112 amountDesiredB) public {
        vm.assume(amountDesiredA > MINIMUM_LIQUIDITY && amountDesiredA < type(uint112).max);
        vm.assume(amountDesiredB > MINIMUM_LIQUIDITY && amountDesiredB < type(uint112).max);

        //Arrange

        (address tokenA, address tokenB) = pool.getTokenAddresses();
        uint256 totalSupplyBefore = pool.totalSupply();

        vm.startPrank(DEFAULT_SENDER);
        IERC20(tokenA).approve(address(pool), amountDesiredA);
        IERC20(tokenB).approve(address(pool), amountDesiredB);

        //Act
        (uint112 amountA, uint112 amountB, uint256 liquidity) = pool.addLiquidity(amountDesiredA, amountDesiredB);
        uint256 totalSupplyAfter = pool.totalSupply();

        assertEq(amountDesiredB, amountB);
        assertEq(amountDesiredA, amountA);
        uint256 expectedLiquidity = Math.sqrt(uint256(amountA) * uint256(amountB)) - MINIMUM_LIQUIDITY;
        assertEq(liquidity, expectedLiquidity);
        assertEq(totalSupplyAfter, totalSupplyBefore + liquidity + MINIMUM_LIQUIDITY);

        vm.stopPrank();
    }
}
