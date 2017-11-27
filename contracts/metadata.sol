pragma solidity ^0.4.17;

/**
 * This contract stores address of other contractr according to their IDs
 */
contract metadata {
    
    address public owner;
    
	mapping (uint256 => address) registerMap;
	 
	function metadata() public {
	    owner = msg.sender;
        registerMap[0] = msg.sender;
	}
	
	  //get contract by address
    function getAddress (uint256 addressId) public view returns (address){
        return registerMap[addressId];
    }
    //add or replace by id
    function addAddress (uint256 addressId, address addressContract) public {
        assert(addressContract != address(0));
        if (owner == msg.sender || owner == tx.origin){
            registerMap[addressId] = addressContract;
        }

    }
}
