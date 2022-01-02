// SPDX-License-Identifier: MIT
// This is a toy contract. 
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Maths.sol";

contract MVAMM {
    
    using SafeMath for uint;

    // address of the ERC20 token we want to trade.
    address tokenAddress;
    ERC20 tokenInstance;

    // LP tokens management.
    uint public totalLiquidityTokenSupply = 0; 
    mapping (address=>uint) public liquidityTokensHolders; // Could also be implemented with an ERC20 token.
    
    // LP information
    uint public k;
    uint public balanceE;
    uint public balanceT;

    // set a (0.003 <-> (1-0.97)) trading fee. Look at 3.1.2, definition 6 in Zhang, 2018.
    // however, we want to manage non integer values for prices, using wei (1e18) at units
    // simply rewrite (1-0.97 as (1e18 - 0.97*1e18)/1e18) 
    // this gives us a "constant" which we call delta, basically gamma but rewritten in wei
    uint delta = 997 * 1e17;


    constructor(address _tokenAddress) {
        
        // Initializes the AMM. Could be called by a factory contract.
        tokenAddress = _tokenAddress;
        tokenInstance = ERC20(address(tokenAddress));

    }

    function _updateLPInfo() private {

        balanceE = address(this).balance;
        balanceT = tokenInstance.balanceOf(address(this));        
        
        // Update k
        k = balanceE.mul(balanceT);

    }

    function initiateLiquidity(uint tokenAmount) public payable {

        // Initiate liquidity with E (transferred ether to the contract) and T (transferred ERC20 tokens to the contract)
        uint initLiquiditySuppliedE = msg.value;
        uint initLiquiditySuppliedT = tokenAmount;
        tokenInstance.transferFrom(msg.sender, address(this), tokenAmount);

        // update liquidity tokens holdings
        // number of liquidity tokens distributed is sqrt(x*y) at initialization. Varies following project and time
        // see for exemple: https://docs.uniswap.org/protocol/V2/concepts/core-concepts/pools
        uint liquidityMinted = Maths.sqrt(initLiquiditySuppliedE.mul(initLiquiditySuppliedT));
        liquidityTokensHolders[msg.sender] = liquidityMinted;
        totalLiquidityTokenSupply = totalLiquidityTokenSupply.add(liquidityMinted);

        // update LP info
        _updateLPInfo();

    }

    function addLiquidity(uint tokenAmount) public payable {

        uint liquiditySuppliedE = msg.value;
        tokenInstance.transferFrom(msg.sender, address(this), tokenAmount);

        // Calculate liquidity mined (l * delta{e} / e) (2.1.2, Zhang, 2018)
        uint liquidityMinted = liquiditySuppliedE.mul(totalLiquidityTokenSupply).div(address(this).balance);

        // update liquidity tokens holdings
        liquidityTokensHolders[msg.sender] += liquidityMinted;
        totalLiquidityTokenSupply = totalLiquidityTokenSupply.add(liquidityMinted);

        // update LP info
        _updateLPInfo();

    }

    function removeLiquidity(uint liquidityTokensAmount) public payable {

        // get the contract's current balance in eth and erc20 token
        uint amountE = address(this).balance;
        uint amountT = tokenInstance.balanceOf(address(this));

        // amount transfered of both eth and erc20 is made in proportion with the liquidity tokens sent
        uint amountEtoTransfer = liquidityTokensAmount.mul(amountE).div(totalLiquidityTokenSupply);
        uint amountTtoTransfer = liquidityTokensAmount.mul(amountT).div(totalLiquidityTokenSupply);

        // "burn" here the liquidity token supply
        liquidityTokensHolders[msg.sender] -= liquidityTokensAmount;
        totalLiquidityTokenSupply = totalLiquidityTokenSupply.sub(liquidityTokensAmount);
        
        // transfer corresponding amounts of E and ERC20 T
        payable(msg.sender).transfer(amountEtoTransfer);
        tokenInstance.transfer(address(msg.sender), amountTtoTransfer);

        // update LP info
        _updateLPInfo();

    }

    function getInputPrice(uint amountE) public view returns (uint) {

        // see 3.1.2 in Zhang, 2018
        uint numerator = delta.mul(amountE).mul(balanceT);
        uint denominator = balanceE.mul(1e18).add(amountE.mul(delta));

        // returns input price in wei quantities
        return numerator.div(denominator);

    }

    function getOutputPrice(uint amountT) public view returns (uint) {
        
        // see 3.2.2 in Zhang, 2018
        uint numerator = amountT.mul(balanceE).mul(1e18);
        uint denominator = delta.mul(balanceT.sub(amountT));

        // returns input price in wei quantities
        return numerator.div(denominator);

    }

    function ethToToken() public payable {
        
        // here the amount of eth is accessible using msg.value
        uint amountT = getInputPrice(msg.value);
        tokenInstance.transfer(address(msg.sender), amountT);

        _updateLPInfo();
    }

    function tokenToEth(uint amountT) public payable {

        uint amountE = getOutputPrice(amountT);

        // transfer corresponding amount of T to this contract, 
        tokenInstance.transferFrom(msg.sender, address(this), amountT);
        payable(msg.sender).transfer(amountE);

        _updateLPInfo();
    }

}