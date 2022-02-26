// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {ISillyJonesERC20} from "./interfaces/ISillyJonesERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ERC20 token
contract SillyJonesERC20 is
    AccessControlEnumerable,
    ERC20("Silly Jones", "SLJN"),
    ISillyJonesERC20
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function mint(address _to, uint256 _amount) external {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "SillyJonesERC20: must have minter role to mint"
        );
        _mint(_to, _amount);
    }

    function addMinter(address _minter) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "SillyJonesERC20: only admin can add minter"
        );
        _setupRole(MINTER_ROLE, _minter);
    }
}
