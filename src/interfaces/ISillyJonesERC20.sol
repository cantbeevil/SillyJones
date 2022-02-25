// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISillyJonesERC20 is IERC20 {
    function mint(address recipient, uint256 amount) external;

    function addMinter(address _minter) external;
}
