// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {SillyJonesERC20} from "../SillyJonesERC20.sol";

import "ds-test/test.sol";

interface CheatCodes {
    function prank(address) external;
}

contract SillyJonesERC20Test is DSTest {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    SillyJonesERC20 sillyJonesToken;

    function setUp() public {
        sillyJonesToken = new SillyJonesERC20(address(this));
    }

    function testMintAsMinter() public {
        assertEq(sillyJonesToken.totalSupply(), 0);
        sillyJonesToken.addMinter(address(this));
        uint256 mintAmount = 100_000_000;
        sillyJonesToken.mint(address(this), mintAmount);
        assertEq(sillyJonesToken.totalSupply(), mintAmount);
    }

    function testFailMintAsNotMinter() public {
        cheats.prank(address(0));
        sillyJonesToken.mint(address(this), 1);
    }
}
