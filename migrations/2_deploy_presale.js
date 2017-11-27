var safeMath = artifacts.require("./SafeMath.sol");
var metadata = artifacts.require("./metadata.sol");
var tokenMedit = artifacts.require("./tokenMedit.sol");
var PresaleMedit = artifacts.require("./PresaleMedit.sol");


module.exports = function(deployer) {
  //change here
  var crowdsaleAddress = "";
  var communityAddress = "";
  var teamAddress = "";
  var foundationAddres = "";
  var charityAddress = "";
  var partnershipsAddress = "";
  var advisorsAddress = "";
  var coinbase = "";
  var controlUser = "";

  deployer.deploy(safeMath); 

  deployer.link(safeMath, tokenMedit);  
  deployer.link(safeMath, PresaleMedit);

  deployer.deploy(metadata).then(function(){
    return deployer.deploy(tokenMedit, metadata.address, crowdsaleAddress, communityAddress, teamAddress, foundationAddres, charityAddress, partnershipsAddress, advisorsAddress);    
  }).then(function(){
    return deployer.deploy(PresaleMedit,metadata.address, coinbase, controlUser);
  })


  
};
