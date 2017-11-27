
# Changes Required for deployment

## Open file `truffle.js` inside the root folder and perform the following changes :-

`var mnemonic = " "`, enter the seed word for the wallet, inside the quotes `" "`(the seed word is a combination of random words used to identify the wallet).

`var wallet = hdwallet.derivePath(wallet_hdpath + "0").getWallet();` ,  instead of "0" in `wallet_hdpath + "0"`, enter the index  of the account in the wallet to be used for deployment. The first address in wallet has index 0, second account has index 1 and so on.

`var accessToken = " "`, enter the access Token provided by infura on registration. [visit [here](https://infura.io/register.html) and enter the details. On successful registration, a token will be provided which is to be entered as stated above]
`


## Open file `migrations/2_deploy_presale.js` and change the following:- 

Change the following addresses,
```
  var crowdsaleAddress = "";
  var communityAddress = "";
  var teamAddress = "";
  var foundationAddres = "";
  var charityAddress = "";
  var partnershipsAddress = "";
  var advisorsAddress = "";
  var coinbase = "";
  var controlUser = "";
```
to the role accordingly. 

`var crowdsaleAddress` will have the address of the address holding crowdsale tokens, `var communityAddress` will have the address holding the community tokens and so on. 

`var coinbase = ""`, enter the address of the account which will receive the ether during the presale

`var controlUser = ""`, enter the address of the account which will be able to perform owner actions in presale


# Deployment :- 

In the root folder of the medit-truffle( RUN THIS COMMAND ONLY ONCE ), run
```
./deploy.sh
```

To deploy to mainnet , run
```
truffle migrate --network mainnet
```

# Interacting with the contract for integration of presale into crowdsale:-

1. Copy the contract address from `console`.
2. Open `https://wallet.ethereum.org/`.
3. Go into the Contracts section.
4. under Custom contracts, select `WATCH CONTRACT`.
5. Copy the contents of `ABI/presale.json` file present inside the root folder.
6. Paste the contract address(Copied in Step 1) under `CONTRACT ADDRESS`, give the contract name as required and paste the content copied in Step 5 inside `JSON INTERFACE`.
7. Open the contract. 
8. Select the `startPresale` function and pass in parameter the price of token.