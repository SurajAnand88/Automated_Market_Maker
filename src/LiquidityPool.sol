// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Math} from "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract LiquidityPool {
    using Math for uint112;

    address public immutable tokenA;
    address public immutable tokenB;

    bool private firstTime;
    uint256 private poolRatio;

    uint112 public reserveTokenA;
    uint112 public reserveTokenB;

    string public constant NAME = "LP Token";
    string public constant SYMBOL = "LST";
    uint256 public constant DECIMAL = 18;
    uint256 public totalSupply;
    uint112 private constant MINIMUM_LIQUIDITY = 10 ** 3;

    mapping(address owner => uint256 amount) balances;
    mapping(address owner => mapping(address spender => uint256 amount)) allowances;

    // <------------------ERRORS------------------>
    error LiquidityPool_DepositeRatioShouldBeSimilar();

    // <------------------EVENTS------------------>
    event Mint(address indexed provider, uint112 tokenA, uint112 tokenB, uint256 liquidity);
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
        allowances[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    /**
     *
     * @param amountADesired the amount of token A user wants to add to the liquidity
     * @param amountBDesired the amount of toke B user wants to add to the liquidity
     * @return amountA The amount of token A deposited by user in equal ratio to the token B
     * @return amountB The amount of token B deposited by user in equal ration to the token A
     * @return liquidity The amount of LP token user will get after adding the liquidity
     */
    function addLiquidity(uint112 amountADesired, uint112 amountBDesired)
        public
        returns (uint112 amountA, uint112 amountB, uint256 liquidity)
    {
        //calculate the optional DesiredToken
        if (reserveTokenA > 0 && reserveTokenB > 0) {
            uint112 amountBoptimal = (amountADesired * reserveTokenB) / reserveTokenA;
            if (amountBoptimal <= amountBDesired) {
                amountA = amountADesired;
                amountB = amountBoptimal;
            } else {
                uint112 amountAoptimal = (amountBDesired * reserveTokenA) / reserveTokenB;
                if (amountAoptimal <= amountADesired) {
                    amountB = amountBDesired;
                    amountA = amountAoptimal;
                }
            }
        } else {
            amountA = amountADesired;
            amountB = amountBDesired;
        }

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        if (totalSupply == 0) {
            liquidity = uint256(Math.sqrt(amountA * amountB) - MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min((amountA * totalSupply) / reserveTokenA, (amountB * totalSupply) / reserveTokenB);
        }
        require(liquidity > 0, "Insufficient LP Tokens to mint");
        _mint(msg.sender, liquidity);
        _updateReserves(amountA, amountB, true);
        emit Mint(msg.sender, amountA, amountB, liquidity);
    }

    /**
     *
     * @param to users address to mint the LP token
     * @param lpTokens the amount of LP tokens to mint the user
     */
    function _mint(address to, uint256 lpTokens) internal {
        balances[to] += lpTokens;
        totalSupply += lpTokens;
        emit Transfer(address(0), to, lpTokens);
    }

    /**
     *
     * @param from users address to burn the LP tokens
     * @param lpTokens the amount of LP tokens to burn from users address
     */
    function _burn(address from, uint256 lpTokens) private {
        balances[from] -= lpTokens;
        totalSupply -= lpTokens;
        emit Transfer(from, address(0), lpTokens);
    }

    /**
     *
     * @param amountA the amount of token A to update the reserveA
     * @param amountB the amounf of token B to update the reserveB
     */
    function _updateReserves(uint112 amountA, uint112 amountB, bool add) internal {
        if (add) {
            reserveTokenA += amountA;
            reserveTokenB += amountB;
        } else {
            reserveTokenA -= amountA;
            reserveTokenB -= amountB;
        }
    }

    /**
     *
     * @param liquidity the amount of LP tokens user wants to remove from liquidity
     * @return tokenAmountA the amount of token A user will get after removing the liquidity
     * @return tokenAmountB the amount of token B user will get after removing the liquidity
     */
    function removeLiquidity(uint256 liquidity) public returns (uint112 tokenAmountA, uint112 tokenAmountB) {
        //check
        require(balances[msg.sender] >= liquidity, "Insufficient LP tokens to withdraw");

        //Effects
        tokenAmountA = uint112((liquidity * reserveTokenA) / totalSupply);
        tokenAmountB = uint112((liquidity * reserveTokenB) / totalSupply);
        _burn(msg.sender, liquidity);
        _updateReserves(tokenAmountA, tokenAmountB, false);

        //Interaction
        IERC20(tokenA).transfer(msg.sender, tokenAmountA);
        IERC20(tokenB).transfer(msg.sender, tokenAmountB);
    }

    function swap() public {}
}
