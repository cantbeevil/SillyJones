// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {ISillyJonesTreasury} from "../../interfaces/ISillyJonesTreasury.sol";

contract MockSillyJonesTreasury is ISillyJonesTreasury {
    uint256 private deposits_ = 0;

    function totalDeposited() external view returns (uint256) {
        return deposits_;
    }

    function deploy(uint256 _amount, address _from) external {
        deposits_ += _amount;
    }
}
