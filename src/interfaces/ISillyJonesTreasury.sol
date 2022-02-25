// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

interface ISillyJonesTreasury {
    function totalDeposited() external view returns (uint256);

    function deploy(uint256 _amount, address _from) external;
}
