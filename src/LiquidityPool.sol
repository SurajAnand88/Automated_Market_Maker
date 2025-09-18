// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract LiquidityPool {
    address public immutable tokenA;
    address public immutable tokenB;

    uint256 public reserveTokenA;
    uint256 public reserveTokenB;

    string public constant NAME = "LP Token";
    string public constant SYMBOL = "LST";
    uint256 public constant DECIMAL = 18;
    uint256 public totalSupply;

    mapping(address owner => uint256 amount) balanceOf;
    mapping(address owner => mapping(address spender => uint256 amount)) allowances;

    // <------------------EVENTS------------------>
    event Mint(uint256 indexed provider, address tokenA, address tokenB, uint256 liquidity);
    event Burn(uint256 indexed provider, address tokenA, address tokenB, uint256 liquidity);
    event Swap(uint256 indexed swapper, uint256 amountIn, uint256 amountOut, address tokenIn, address tokenOut);

    // <---------------Constructor--------------->

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }
}
