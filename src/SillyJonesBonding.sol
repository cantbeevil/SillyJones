// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {IJonesAsset} from "./interfaces/IJonesAsset.sol";
import {ISillyJonesERC20} from "./interfaces/ISillyJonesERC20.sol";
import {ISillyJonesTreasury} from "./interfaces/ISillyJonesTreasury.sol";
import {SimpleMath} from "./libraries/Math.sol";

contract SillyJonesBonding {
    using SimpleMath for uint256;

    ISillyJonesERC20 public sillyJonesToken;
    IJonesAsset public jonesAssetToken;
    ISillyJonesTreasury public treasury;

    uint256 public constant BOND_DURATION = 5 days;
    uint256 public constant TOKEN_DECIMAL = 1e18;
    uint256 public constant INITIAL_DEBT_CAPACITY = 1_000_000 * TOKEN_DECIMAL;
    uint256 public constant PERCENT_DEBT_CAPACITY = 60; // How many percent over total deposits the sillyJonesTokens can be minted.
    uint256 public constant PERCENT_PAYOUT = 25;
    uint256 public constant PERCENT_BASE = 1e2;
    uint256 public debtOutstanding; // Total amount of sillyJoneToken's that need to be payed out after all bonds are matured.
    mapping(address => Bond[]) public bonds;

    struct Bond {
        address bondholder;
        uint256 timeBonded;
        uint256 amount;
        bool redeemed;
    }

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Bonding(
        address indexed bondholder,
        uint256 amount,
        uint256 expectedPayout
    );
    event Redeeming(address indexed bondholder, uint256 payout);

    constructor(
        ISillyJonesERC20 _sillyJonesToken,
        ISillyJonesTreasury _treasury,
        IJonesAsset _assetToken
    ) {
        sillyJonesToken = _sillyJonesToken;
        jonesAssetToken = _assetToken;
        treasury = _treasury;
        jonesAssetToken.approve(address(treasury), 100_000_000 * TOKEN_DECIMAL);
    }

    function getBonds(address _account) public view returns (Bond[] memory) {
        return bonds[_account];
    }

    function approve() public {
        uint256 _amount = 100_000_000 * TOKEN_DECIMAL;
        jonesAssetToken.approve(address(treasury), _amount);
        emit Approval(msg.sender, address(treasury), _amount);
    }

    function calculatePayout(uint256 _amount) public pure returns (uint256) {
        return _amount + _amount.fmul(PERCENT_PAYOUT, PERCENT_BASE);
    }

    function _debtCapacity() private view returns (uint256) {
        return
            INITIAL_DEBT_CAPACITY +
            treasury.totalDeposited().fmul(PERCENT_DEBT_CAPACITY, PERCENT_BASE);
    }

    function isValidBondAmount(uint256 _amount) public view returns (bool) {
        return _amount + debtOutstanding <= _debtCapacity();
    }

    function bond(uint256 _amount) public returns (uint256 _payout) {
        require(isValidBondAmount(_amount), "Debt capacity reached");
        treasury.deploy(_amount, msg.sender);
        bonds[msg.sender].push(
            Bond({
                bondholder: msg.sender,
                timeBonded: block.timestamp,
                amount: _amount,
                redeemed: false
            })
        );
        _payout = calculatePayout(_amount);
        debtOutstanding += _payout;
        emit Bonding(msg.sender, _amount, _payout);
    }

    function isRedeemable(address _account, uint256 _bondNumber)
        public
        view
        returns (bool)
    {
        Bond storage bond_ = bonds[_account][_bondNumber];
        return block.timestamp >= bond_.timeBonded + BOND_DURATION;
    }

    function redeem(uint256 _bondNumber) public returns (uint256 _payout) {
        Bond storage bond_ = bonds[msg.sender][_bondNumber];
        require(
            isRedeemable(msg.sender, _bondNumber),
            "Bond is not yet mature"
        );
        require(!bond_.redeemed, "Already redeemed bond");
        _payout = calculatePayout(bond_.amount);
        sillyJonesToken.mint(msg.sender, _payout);
        debtOutstanding -= _payout;
        bond_.redeemed = true;
        emit Redeeming(msg.sender, _payout);
    }
}
