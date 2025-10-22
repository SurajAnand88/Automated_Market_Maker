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

    function testAddLiquidityForFirstTime(uint112 amountDesiredA, uint112 amountDesiredB) public {
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

    function testAddLiquiditySubsequentTimes(uint112 amountDesiredA, uint112 amountDesiredB, uint112 amountA, uint112 amountB)
        public
    {
        vm.assume(amountA > 0 && amountA < type(uint112).max / 100);
        vm.assume(amountB > 0 && amountB < type(uint112).max / 100);
        vm.assume(amountA * 100 > amountB && amountB * 100 > amountA);
        addLiquidity(amountDesiredA, amountDesiredB);
        //Arrange
        uint256 reserveTokenA = pool.reserveTokenA();
        uint256 reserveTokenB = pool.reserveTokenB();
        (address tokenA, address tokenB) = pool.getTokenAddresses();
        uint256 totalSupplyBefore = pool.totalSupply();

        //Act
        vm.startPrank(DEFAULT_SENDER);
        IERC20(tokenA).approve(address(pool), amountA);
        IERC20(tokenB).approve(address(pool), amountB);

        (uint112 optimalAmountA, uint112 optimalAmountB, uint256 liqidity) = pool.addLiquidity(amountA, amountB);

        uint112 expectedOptimalAmountA = uint112(uint256(amountB) * reserveTokenA / reserveTokenB);
        uint112 expectedOptimalAmountB = uint112(uint256(amountA) * reserveTokenB / reserveTokenA);
        uint256 totalSupplyAfter = pool.totalSupply();

        //Assert
        if (expectedOptimalAmountB < amountB) {
            assertEq(expectedOptimalAmountB, optimalAmountB);
        } else {
            assertEq(optimalAmountA, expectedOptimalAmountA);
        }
        assertEq(totalSupplyAfter, totalSupplyBefore + liqidity);
        vm.stopPrank();
    }


    //Helper Function to add liquidity for the first time
    function addLiquidity(uint112 amountDesiredA, uint112 amountDesiredB) public {
        vm.assume(amountDesiredA > MINIMUM_LIQUIDITY && amountDesiredA < 1e18);
        vm.assume(amountDesiredB > MINIMUM_LIQUIDITY && amountDesiredB < 1e18);
        vm.assume(
            uint256(amountDesiredA) * 2 > uint256(amountDesiredB)
                && uint256(amountDesiredB) * 2 > uint256(amountDesiredA)
        );
        (address tokenA, address tokenB) = pool.getTokenAddresses();

        vm.startPrank(DEFAULT_SENDER);
        IERC20(tokenA).approve(address(pool), amountDesiredA);
        IERC20(tokenB).approve(address(pool), amountDesiredB);

        pool.addLiquidity(amountDesiredA, amountDesiredB);
        vm.stopPrank();
    }
}
