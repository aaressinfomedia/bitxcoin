/**
 *Submitted for verification at BscScan.com on 2022-05-17 09:05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
import "./IERC20.sol";
import "./IRouter.sol";
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}