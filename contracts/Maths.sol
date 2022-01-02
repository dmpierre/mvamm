// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


library Maths {
    function sqrt(uint y) internal pure returns (uint z) {
        // calculating square root of a number 
        // see: https://github.com/Uniswap/v2-core/blob/v1.0.1/contracts/libraries/Math.sol
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}