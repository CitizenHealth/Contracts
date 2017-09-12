pragma solidity ^0.4.11;

import "../node_modules/zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "../node_modules/zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol";
import "../node_modules/zeppelin-solidity/contracts/token/MintableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./MeditToken.sol";

/**
 * @title MeditCrowdsale
 */
contract MeditCrowdsale is CappedCrowdsale, FinalizableCrowdsale, Pausable {

  address public tokenAddress;

  function MeditCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet, address _tokenAddress)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
    tokenAddress = _tokenAddress;
  }

  // Override parent createTokenContract() to use pre-existing Medit token
  function createTokenContract() internal returns (MintableToken) {
    return MeditToken(tokenAddress);
  }

  // Hook into parent default func to implement Pausable functionality
  function () whenNotPaused payable {
    super.buyTokens(msg.sender);
  }

  // Hook into parent buyTokens() function to implement Pausable functionality
  function buyTokens(address beneficiary) whenNotPaused payable {
    super.buyTokens(beneficiary);
  }
}