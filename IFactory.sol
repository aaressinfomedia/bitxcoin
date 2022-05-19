/**
 *Submitted for verification at BscScan.com on 2022-05-17 09:05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}
