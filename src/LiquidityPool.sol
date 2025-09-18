// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract LiquidityPool {
    address public immutable tokenA;
    address public immutable tokenB;

    uint112 public reserveTokenA;
    uint112 public reserveTokenB;

    string public constant NAME = "LP Token";
    string public constant SYMBOL = "LST";
    uint256 public constant DECIMAL = 18;
    uint256 public totalSupply;

    mapping(address owner => uint256 amount) balances;
    mapping(address owner => mapping(address spender => uint256 amount)) allowances;

    // <------------------EVENTS------------------>
    event Mint(uint256 indexed provider, address tokenA, address tokenB, uint256 liquidity);
    event Burn(uint256 indexed provider, address tokenA, address tokenB, uint256 liquidity);
    event Swap(uint256 indexed swapper, uint256 amountIn, uint256 amountOut, address tokenIn, address tokenOut);
    event Transfer(address indexed from, address indexed to, uint256 indexed value);
    event Approval(address indexed owner, address indexed spender, uint256 indexed value);

    // <---------------Constructor--------------->

    /**
     *
     * @param _tokenA This is the address of token A
     * @param _tokenB This is the address of token B
     * @dev Constructor sets the address of token A and token B
     */
    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "Insufficient Amount");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][spender] = _amount;
        emit Approval(msg.sender, spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(balances[_from] >= _amount, "Insufficient Balance");
        require(allowances[_from][msg.sender] >= _amount, "Insufficient Allowance");
        balances[_from] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function addLiquidity() public {}

    function removeLiquidity() public {}

    function swap() public {}
}
