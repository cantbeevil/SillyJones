// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {IJonesAsset} from "./interfaces/IJonesAsset.sol";
import {ISillyJonesERC20} from "./interfaces/ISillyJonesERC20.sol";
import {ISillyJonesTreasury} from "./interfaces/ISillyJonesTreasury.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract SillyJonesBonding {
    using FixedPointMathLib for uint256;

    ISillyJonesERC20 public sillyJonesToken;
    IJonesAsset public jonesAssetToken;
    ISillyJonesTreasury public treasury;

    uint256 public constant BOND_DURATION = 5 days;
    uint256 public constant INITIAL_DEBT_CAPACITY = 1_000_000;
    uint256 public constant PERCENT_DEBT_CAPACITY = 20; // How many percent over total deposits the sillyJonesTokens can be minted.
    uint256 private debtOutstanding_; // Total amount of sillyJoneToken's that need to be payed out after all bonds are matured.
    mapping(address => Bond[]) public bonds;
    mapping(address => uint256) public deposits;

    struct Bond {
        address bondholder;
        uint256 timeBonded;
        uint256 amount;
        bool redeemed;
    }

    constructor(
        ISillyJonesERC20 _sillyJonesToken,
        ISillyJonesTreasury _treasury,
        IJonesAsset _assetToken
    ) {
        sillyJonesToken = _sillyJonesToken;
        jonesAssetToken = _assetToken;
        treasury = _treasury;
        jonesAssetToken.approve(address(treasury), 100_000_000_000);
    }

    function getBonds(address _account) public view returns (Bond[] memory) {
        return bonds[_account];
    }

    function approve() public {
        jonesAssetToken.approve(address(treasury), 100_000_000_000_000);
    }

    function calculatePayout(uint256 _amount) public pure returns (uint256) {
        return _amount + _amount.mulWadDown(25);
    }

    function debtCapacity() private view returns (uint256) {
        if (treasury.totalDeposited() <= INITIAL_DEBT_CAPACITY) {
            return INITIAL_DEBT_CAPACITY;
        }
        return
            treasury.totalDeposited() +
            treasury.totalDeposited().mulWadDown(PERCENT_DEBT_CAPACITY);
    }

    function bond(uint256 _amount) public returns (uint256 _payout) {
        _payout = calculatePayout(_amount);
        require(
            _payout + debtOutstanding_ <= debtCapacity(),
            "Debt capacity reached"
        );
        treasury.deploy(_amount, msg.sender);
        bonds[msg.sender].push(
            Bond({
                bondholder: msg.sender,
                timeBonded: block.timestamp,
                amount: _amount,
                redeemed: false
            })
        );
        deposits[msg.sender] += _amount;
        debtOutstanding_ += _payout;
    }

    function isRedeemable(address _account, uint256 _bondNumber)
        public
        view
        returns (bool)
    {
        Bond storage bond_ = bonds[_account][_bondNumber];
        return block.timestamp >= bond_.timeBonded + BOND_DURATION;
    }

    function redeem(uint256 _bondNumber) public {
        Bond storage bond_ = bonds[msg.sender][_bondNumber];
        require(
            isRedeemable(msg.sender, _bondNumber),
            "Bond is not yet mature"
        );
        require(!bond_.redeemed, "Already redeemed bond");
        uint256 payout = calculatePayout(bond_.amount);
        sillyJonesToken.mint(msg.sender, payout);
        debtOutstanding_ -= payout;
        bond_.redeemed = true;
    }
}
