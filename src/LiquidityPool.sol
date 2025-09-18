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

    /**
     *
     * @param _to address to transfer the token
     * @param _amount the amount of the token to be transferred by the sender
     * @dev this function will trnsfer the token from caller to _to address
     */
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "Insufficient Amount");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     *
     * @param spender the address of the spender to approved by the owner
     * @param _amount the amount of the token to be approved by the sender
     * @dev this function will approve the amount of the token to the spender
     * so the he can spend the token in behalf of the owner
     */
    function approve(address spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][spender] = _amount;
        emit Approval(msg.sender, spender, _amount);
        return true;
    }

    /**
     *
     * @param _from the address of the owner of the token
     * @param _to the address of the user to transfer the token
     * @param _amount the amount of the token to be transfered
     * @dev this function will be called by the spender to transfer the token on behalf of the owner
     */
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
