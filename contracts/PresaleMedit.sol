pragma solidity ^0.4.17;

import './SafeMath.sol';

contract metadata{
    function getAddress (uint256 addressId) public view returns (address);
    function addAddress (uint256 addressId, address addressContract) public;
}

contract tokenMedit{
    function balanceOf(address _owner) public view returns (uint256 _value);
    function addTokenBalance(address beneficiary, uint256 amount) public;
    function reduceTokenBalance(uint256 amount) public;
}

/**
 * @title presale to implement presale logic of tokenMedit
 */
contract PresaleMedit {
    using SafeMath for uint256;
    //To determine if the presale is running or has stopped
    bool public stopped;
    //Record the block number when presale starts
    uint256 public startBlock;
    //Maximum number of tokens in presale
    uint256 public maxCapPreSale;
    //stores rate of ether passed by owner
    uint256 public spotRate;
    //Record the block number when presale starts
    uint256 public endBlock;
    //To determine if the presale is running or has paused
    bool public paused;
    //To store tokens supplied during presale
    uint256 public totalPreSaleSupply;
    //coinbase account where all ethers should go
    address public coinbase;
    //owner address
    address public owner;
    //the address of control user
    address public controlUser;
    //variable of type metadata to store metadata contract address
    metadata private metadataContract;
    //variable to store address of safe math contract
    tokenMedit private tokenMeditContract;
    //tokenmedit contract Id
    uint256 constant private IDtokenMedit = 1;
    //presale contract Id
    uint256 constant private IDpresale = 2;
    
    //Structure to store token sent and wei received by the buyer of tokens
    struct Investor {
        uint256 weiReceived;
        uint256 tokenSent;
    }

    //investors indexed by their ETH address
    mapping(address => Investor) public investors; 

    //event to log token supplied
    event TokenSupplied(address indexed beneficiary, uint256 indexed tokens, uint256 value);

    /**
     * @dev Constuctor of the contract
     *
     */
    function PresaleMedit(address metadataContrAddr, address _coinbase, address _controlUser) public {
        require(metadataContrAddr != address(0) && _coinbase != address(0) && _controlUser != address(0));
        startBlock = 0;
        endBlock = 0;
        maxCapPreSale = 25000000e18; //25 million 
        totalPreSaleSupply = 0;
        coinbase = _coinbase;
        metadataContract = metadata(metadataContrAddr);
        controlUser = _controlUser;
        // one who has deployed metadata, is allowed to deploy PreSaleMedit
        // Id of owner of metadata is 0
        assert(metadataContract.getAddress(0) == msg.sender);
        owner = msg.sender;
        tokenMeditContract = tokenMedit(metadataContract.getAddress(IDtokenMedit));
        //storing address of presale contract in metadata
        metadataContract.addAddress(IDpresale, this);
    }

    //Verify if the sender is owner
    modifier onlyOwner() {
      require(msg.sender == owner || msg.sender == controlUser);
      _;
    }

    //check if presale is not paused
    modifier isNotPaused(){
        require(!paused);
        _;
    }

    // check if presale is paused
    modifier isPaused(){
        require(paused);
        _;
    }

    /**
     * @dev Pause PreSale
     *
     */
    function emergencyStop() public onlyOwner isNotPaused respectTimeFrame {
        paused = true;
    }

    /**
     * @dev Resume PreSale
     *
     */
    function resume() public onlyOwner isPaused respectTimeFrame{
        paused = false;
    }

    //Modifier to make sure transaction is happening during Presale when it is not stopped and maxCapPreSale not reached
    modifier respectTimeFrame() {
      // When contract is deployed, startblock is 0. When presale is started, startBlock should not be zero
      assert(startBlock != 0 && !stopped);
      _;
    }

    /**
     * @dev Start Presale
     * @param _PriceTokenAgainstOneEther stores number of token against 1 ether
     *
     */
    function startPresale(uint256 _PriceTokenAgainstOneEther) public onlyOwner {
        require(startBlock == 0);
        spotRate = _PriceTokenAgainstOneEther*1e18;
        startBlock = block.number;
    }

    /**
     * @dev Stop PreSale finally
     *
     */
    function stopPresale() public onlyOwner respectTimeFrame {
        endBlock = block.number;
        stopped = true;
    }

    function updateSpotRate(uint256 _PriceTokenAgainstOneEther) public onlyOwner respectTimeFrame {
        spotRate = _PriceTokenAgainstOneEther*1e18;
    }
     
    /**
     * @dev Get price after discounting on sent ether by buyer
     * @return discounted price
     *
     */
    function getTokenRate() public view returns (uint256 result) {
        if (totalPreSaleSupply < 5000000e18) {
            return (spotRate.Mul(100)).Div(70);
        }
        else if (totalPreSaleSupply >= 5000000e18 && totalPreSaleSupply < 10000000e18) {
            return  (spotRate.Mul(100)).Div(75);
        }
        else if (totalPreSaleSupply >= 10000000e18 && totalPreSaleSupply < 15000000e18) {
            return  (spotRate.Mul(100)).Div(80);
        }
        else if (totalPreSaleSupply >= 15000000e18 && totalPreSaleSupply < 20000000e18){
            return  (spotRate.Mul(100)).Div(85);
        }
        else if (totalPreSaleSupply >= 20000000e18 && totalPreSaleSupply <= maxCapPreSale){
            return  (spotRate.Mul(100)).Div(90);
        }
    }

    /**
     * @dev create tokens against the discounted price
     *
     * @param beneficiary who wants to purchase tokens
     */
    function createTokens(address beneficiary) internal isNotPaused respectTimeFrame {

        uint256 etherReceivedByContract = msg.value;
        // ether should be greater than 0
        require(etherReceivedByContract > 0);
        // check for zero address
        require(beneficiary != address(0));
        //slot number before transferring tokens
        uint256 currentSlotNumber = totalPreSaleSupply.Div(5000000e18) + 1;
        uint256 totalPreSaleSupplyBeforeTransfer = totalPreSaleSupply;

        // calculate how many tokens are to be given
        while(etherReceivedByContract > 0){
            //variable storing number of tokens to send
            uint256 roughNumberOfTokenToBeGiven = (etherReceivedByContract.Mul(getTokenRate())).Div(1e18);
            // Find how many tokens are available in this slot
            uint256 availableNumberOfTokens = (currentSlotNumber.Mul(5000000e18)).Sub(totalPreSaleSupply);
            if(roughNumberOfTokenToBeGiven <= availableNumberOfTokens){
                // Take all ether from investor. It would be equal to etherReceivedByContract.Sub(roughNumberOfTokenToBeGiven.Div(getTokenRate))
                etherReceivedByContract = 0;
                // Its okay, now we can transfer all roughNumberOfTokenToBeGiven to investor
                // that is handeled afer if-else block by updating totalPreSaleSupply
            }
            else{
                // Nopes! he probably gave more value to the contract than the number of tokens in the slot
                // Give all tokens from this slot, and then continue to next slot
                roughNumberOfTokenToBeGiven = availableNumberOfTokens;


                // take ether from investor
                etherReceivedByContract = etherReceivedByContract.Sub(roughNumberOfTokenToBeGiven.Div(getTokenRate().Div(1e18)));
                // to count tokens in next slot
                currentSlotNumber++;
            }
            // Increase the totalPreSaleSupply
            totalPreSaleSupply = totalPreSaleSupply.Add(roughNumberOfTokenToBeGiven);
        }
        assert(totalPreSaleSupply <= maxCapPreSale);
        // accumulate total token to be given
        uint256 totalNumberOfTokenTransferred = totalPreSaleSupply.Sub(totalPreSaleSupplyBeforeTransfer);

        //transfer ether to coinbase account
        coinbase.transfer(msg.value);

        //initializing structure for the address of the beneficiary
        Investor storage _investor = investors[beneficiary];
        //Update investor's balance
        _investor.tokenSent = _investor.tokenSent.Add(totalNumberOfTokenTransferred);
        _investor.weiReceived = _investor.weiReceived.Add(msg.value);

        // reduce the number of token to send from crowdsale address balance
        tokenMeditContract.reduceTokenBalance(totalNumberOfTokenTransferred);
        // Update tokens of beneficiary
        tokenMeditContract.addTokenBalance(beneficiary, totalNumberOfTokenTransferred);
        TokenSupplied(beneficiary, totalNumberOfTokenTransferred, msg.value);
    }
    /**
     * @dev payable function to accept ether.
     *
     */
    function () external payable {
        createTokens(msg.sender);
    }
}
