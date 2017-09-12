pragma solidity ^0.4.11;

import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20Basic.sol";
import "../node_modules/zeppelin-solidity/contracts/token/MintableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/TokenTimelock.sol";

/**
 * @title MeditPremine
 */
contract MeditPremine is Ownable {
    
    MintableToken public meditToken;
    TokenTimelock public timelock;
    address public premineAddress;
    uint64 public releaseDate;
    uint256 public tokenAmount;

    function MeditPremine(address _tokenAddress, address _premineAddress, uint64 _releaseDate, uint256 _tokenAmount) {
        premineAddress = _premineAddress;
        releaseDate = _releaseDate;
        tokenAmount = _tokenAmount;
        meditToken = MintableToken(_tokenAddress);
        timelock = new TokenTimelock(meditToken, premineAddress, releaseDate);
        meditToken.mint(address(timelock), tokenAmount);
    }
}