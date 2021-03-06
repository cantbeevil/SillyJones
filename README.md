# SillyJones

SillyJones is a dapp that lets you bond **x** [jAsset tokens](https://docs.jonesdao.io/jones-dao/features/jassets) to mint **x + x*0.25** SillyJonesTokens. The bond matures linearly over 5 days. The goal of the protocol is to accumulate as many jAsset tokens as possible.

## Learning
This is a fun little project I created to demonstrate my Solidity skills and understanding of DEFI.

## Dependencies
* Foundry 
  * Forge for testing
  * Cast for deployment
* Openzapplin for ERC20 and a few other libraries

# Contracts
The following contracts are deployed on Arbitrum
- [SillyJonesERC20](src/SillyJonesERC20.sol): 0x50f1ab7b49811526227604f31ab5e56ec0f5e009
- [SillyJonesTreasury](src/SillyJonesTreasury.sol): 0x7c4cac748a66305c16ef8002f217bf69b34d54fe
- [SillyJonesBonding](src/SillyJonesBonding.sol): 0x510ee81e950eaa6cebd9809a94063d1eafd689cf

# Tests
- [SillyJonesBonding](src/test/SillyJonesBonding.t.sol)
- [SillyJonesERC20](src/test/SillyJonesERC20.t.sol)
