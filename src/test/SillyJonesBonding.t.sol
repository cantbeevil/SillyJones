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
    uint256 constant SILLY_JONES_TOKEN_DECIMAL = 1e18;
    uint256 constant JONES_ASSET_TOKEN_DECIMAL = 1e18;
    uint256 BOND_DURATION = 5 days;

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
    }

    function testBond() public {
        uint256 _amountToBond = 50 * SILLY_JONES_TOKEN_DECIMAL;
        uint256 firstTimestamp = block.timestamp;
        uint256 _expectedPayout = bonding.bond(_amountToBond);
        assertEq(_expectedPayout, 625 * 1e17);
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

    function testRedeem() public {
        bonding.bond(100_000 * SILLY_JONES_TOKEN_DECIMAL);
        assertEq(
            bonding.debtOutstanding(),
            125_000 * SILLY_JONES_TOKEN_DECIMAL
        );
        assertEq(
            treasury.totalDeposited(),
            100_000 * JONES_ASSET_TOKEN_DECIMAL
        );
        cheats.warp(block.timestamp + BOND_DURATION);
        uint256 payout = bonding.redeem(0);
        assertEq(payout, 125_000 * SILLY_JONES_TOKEN_DECIMAL);
        assertEq(
            treasury.totalDeposited(),
            100_000 * JONES_ASSET_TOKEN_DECIMAL
        );
        // assertTrue(bonding.debtOutstanding);
        assertEq(bonding.debtOutstanding(), 0);
    }

    function testFailRedeemForImmatureBond() public {
        bonding.bond(100_000 * SILLY_JONES_TOKEN_DECIMAL);
        bonding.redeem(0);
    }

    function testFailRedeemForEmptyDeposits() public {
        bonding.redeem(0);
    }

    function testBondIsRedeemable() public {
        bonding.bond(32 * SILLY_JONES_TOKEN_DECIMAL);
        assertTrue(!bonding.isRedeemable(address(this), 0));
        cheats.warp(block.timestamp + BOND_DURATION);
        assertTrue(bonding.isRedeemable(address(this), 0));
    }

    function testCalculatePayout() public {
        uint256 _payout = bonding.calculatePayout(
            100 * SILLY_JONES_TOKEN_DECIMAL
        );
        assertEq(_payout, 125 * SILLY_JONES_TOKEN_DECIMAL);
        uint256 _payout2 = bonding.calculatePayout(
            321 * SILLY_JONES_TOKEN_DECIMAL
        );
        assertEq(_payout2, 40125 * 1e16);
    }

    function testIsValidBondAmount() public {
        assertTrue(
            bonding.isValidBondAmount(1_000_000 * SILLY_JONES_TOKEN_DECIMAL)
        );
        assertTrue(
            !bonding.isValidBondAmount(1_000_001 * SILLY_JONES_TOKEN_DECIMAL)
        );
        bonding.bond(1_000_000 * SILLY_JONES_TOKEN_DECIMAL);
        assertTrue(
            bonding.isValidBondAmount(200_000 * SILLY_JONES_TOKEN_DECIMAL)
        );
        assertTrue(
            !bonding.isValidBondAmount(350_001 * SILLY_JONES_TOKEN_DECIMAL)
        );
        bonding.bond(200_000 * SILLY_JONES_TOKEN_DECIMAL);
        assertTrue(
            bonding.isValidBondAmount(125_000 * SILLY_JONES_TOKEN_DECIMAL)
        );
        assertTrue(
            !bonding.isValidBondAmount(220_001 * SILLY_JONES_TOKEN_DECIMAL)
        );
        cheats.warp(block.timestamp + BOND_DURATION);
        bonding.redeem(0);
        bonding.redeem(1);
        assertTrue(
            bonding.isValidBondAmount(1_720_000 * SILLY_JONES_TOKEN_DECIMAL)
        );
        assertTrue(
            !bonding.isValidBondAmount(1_720_001 * SILLY_JONES_TOKEN_DECIMAL)
        );
    }

    function testFailInitialBondDueToMaxDebtOutstanding() public {
        bonding.bond(1_000_000_001 * SILLY_JONES_TOKEN_DECIMAL);
    }

    function testFailBondDueToMaxDebtOutstanding() public {
        bonding.bond(1_000_000 * SILLY_JONES_TOKEN_DECIMAL);
        bonding.bond(200_000 * SILLY_JONES_TOKEN_DECIMAL);
        bonding.bond(220_001 * SILLY_JONES_TOKEN_DECIMAL);
    }
}
