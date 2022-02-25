// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {IJonesAsset} from "./interfaces/IJonesAsset.sol";
import {ISillyJonesTreasury} from "./interfaces/ISillyJonesTreasury.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract SillyJonesTreasury is ISillyJonesTreasury {
    IJonesAsset public jonesAssetToken;
    bytes32 private constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    uint256 private totalDeposited_;

    constructor(IJonesAsset _jonesAsset) {
        jonesAssetToken = _jonesAsset;
    }

    function deploy(uint256 _amount, address _from) external {
        SafeTransferLib.safeTransferFrom(
            ERC20(address(jonesAssetToken)),
            _from,
            address(this),
            _amount
        );
        totalDeposited_ += _amount;
    }

    function totalDeposited() external view returns (uint256) {
        return totalDeposited_;
    }
}
