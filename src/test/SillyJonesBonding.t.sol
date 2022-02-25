// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {SillyJonesBonding} from "../SillyJonesBonding.sol";
import {SillyJonesERC20} from "../SillyJonesERC20.sol";
import {MockSillyJonesTreasury} from "./mocks/MockSillyJonesTreasury.sol";
import {MockJonesAsset} from "./mocks/MockJonesAsset.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import "ds-test/test.sol";

interface CheatCodes {
    function warp(uint256) external;
}

contract SillyJonesBondingTest is DSTest {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    SillyJonesERC20 sillyJonesToken;
    MockJonesAsset jonesAssetToken;
    MockSillyJonesTreasury treasury;
    SillyJonesBonding bonding;
    uint256 num;

    function setUp() public {
        sillyJonesToken = new SillyJonesERC20(address(this));
        jonesAssetToken = new MockJonesAsset();
        treasury = new MockSillyJonesTreasury();
        bonding = new SillyJonesBonding(
            sillyJonesToken,
            treasury,
            jonesAssetToken
        );
        sillyJonesToken.addMinter(address(bonding));
        num = 0;
    }

    function testBondingBasic() public {
        uint256 _amountToBond = 50;
        uint256 firstTimestamp = block.timestamp;
        bonding.bond(_amountToBond);
        uint256 secondTimestamp = block.timestamp + 2 days;
        cheats.warp(secondTimestamp);
        bonding.bond(_amountToBond);
        assertEq(treasury.totalDeposited(), _amountToBond + _amountToBond);
        SillyJonesBonding.Bond[] memory bonds = bonding.getBonds(address(this));
        assertEq(bonds.length, 2);
        assertEq(bonds[0].timeBonded, firstTimestamp);
        assertEq(bonds[1].timeBonded, secondTimestamp);
        cheats.warp(block.timestamp + 10 days);
    }

    function testBondIsRedeemable() public {
        bonding.bond(32);
        assertTrue(!bonding.isRedeemable(address(this), 0));
        cheats.warp(block.timestamp + 5 days);
        assertTrue(bonding.isRedeemable(address(this), 0));
    }

    // function testDebtOutstanding() public {
    //     bonding.bond(10_000_000);

    // }


}
