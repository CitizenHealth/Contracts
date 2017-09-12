pragma solidity ^0.4.11;

import "../node_modules/zeppelin-solidity/contracts/token/MintableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/TokenTimelock.sol";

/**
 * @title MeditToken
 */
contract MeditToken is MintableToken {

  string public constant name = "Medit Token";
  string public constant symbol = "MEDIT";
  uint8 public constant decimals = 18;

  TokenTimelock public teamTimelock;
  TokenTimelock public foundationTimelock;
  TokenTimelock public ventureTimelock;
  TokenTimelock public incentiveTimelock;

  address public teamAddress;
  address public foundationAddress;
  address public ventureAddress;
  address public incentiveAddress;

  function MeditToken(address _mainsalePremine, address _teamPremine, uint64 _teamRelease, address _foundationPremine, uint64 _foundationRelease, address _venturePremine, uint64 _ventureRelease, address _incentivePremine, uint64 _incentiveRelease) {
    // Create time locks for tokens that we plan on using for business purposes in the future
    teamTimelock = new TokenTimelock(this, _teamPremine, _teamRelease);
    foundationTimelock = new TokenTimelock(this, _foundationPremine, _foundationRelease);
    ventureTimelock = new TokenTimelock(this, _venturePremine, _ventureRelease);
    incentiveTimelock = new TokenTimelock(this, _incentivePremine, _incentiveRelease);

    // Record Timelock addresses for withdrawal later
    teamAddress = address(teamTimelock);
    foundationAddress = address(foundationTimelock);
    ventureAddress = address(ventureTimelock);
    incentiveAddress = address(incentiveTimelock);

    // Premine our tokens for our mainsale and four timelocked addresses
    mint(_mainsalePremine, 1000000000 * (10 ** uint256(18)));
    mint(teamAddress, 3500000000 * (10 ** uint256(18)));
    mint(foundationAddress, 1000000000 * (10 ** uint256(18)));
    mint(ventureAddress, 1000000000 * (10 ** uint256(18)));
    mint(incentiveAddress, 3500000000 * (10 ** uint256(18)));
  }

}