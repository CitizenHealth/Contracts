// importing the package
var bip39 = require("bip39");
var hdkey = require('ethereumjs-wallet/hdkey');
var ProviderEngine = require("web3-provider-engine");
var WalletSubprovider = require('web3-provider-engine/subproviders/wallet.js');
var Web3Subprovider = require("web3-provider-engine/subproviders/web3.js");
var Web3 = require("web3");

//importing the wallet data
var mnemonic = "";//change here
var hdwallet = hdkey.fromMasterSeed(bip39.mnemonicToSeed(mnemonic));

//extracting the address of deploy account
var wallet_hdpath = "m/44'/60'/0'/0/";
var wallet = hdwallet.derivePath(wallet_hdpath + "0").getWallet();//change here if required
var address = "0x" + wallet.getAddress().toString("hex");
var accessToken = "";//change here
const FilterSubprovider = require('web3-provider-engine/subproviders/filters.js');

//Setting up the Mainnet engine
var providerUrlMainnet = "https://mainnet.infura.io/" + accessToken;
var engineMainnet = new ProviderEngine();
engineMainnet.addProvider(new WalletSubprovider(wallet, {}));
// const FilterSubprovider = require('web3-provider-engine/subproviders/filters.js');
engineMainnet.addProvider(new FilterSubprovider());
engineMainnet.addProvider(new Web3Subprovider(new Web3.providers.HttpProvider(providerUrlMainnet)));
// network connectivity error
engineMainnet.on('error', function(err) {
    // report connectivity errors
    console.error(err.stack);
});
engineMainnet.start();


module.exports = {
  networks: {
    "mainnet" : {
      network_id : 1,
      provider: engineMainnet,
      from: address
    }
  }
};
