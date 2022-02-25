// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {IJonesAsset} from "../../interfaces/IJonesAsset.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockJonesAsset is ERC20("Governance OHM", "gOHM"), IJonesAsset {
    function mint(address recipient, uint256 amount) external {}
    function giveMinterRole(address account) external {}
    function revokeMinterRole(address account) external {}
    function burnFrom(address account, uint256 amount) external {}
}
