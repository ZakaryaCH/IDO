// const Migrations = artifacts.require("Migrations");
const Staker = artifacts.require("Staker");
const Factory = artifacts.require("Factory");

// const polr = ""
// const router = ""
// const feeAddress = ""

// InvestToken =

// Factory owner =

// IDO guy =

// Investor =

/*
  createCampaign:
   -token: 0x34ddD3E0A9B9E1F2FA246716cd68C314Ff6B532C
   - _subIndex: 0
   - Campaignowner: 0x0546B1a8B083128F29673ea036aD4474bc043E11
   - stats[5]:
    ["10000000000000000","1000000000000000000","1000000000000000000000","10000","100000000000000000000"]
    - dates:
    [1623497361,1623499261,1623697261]
    - buy limits:
    ["1000000000000000","1000000000000000000"]
    - access:
    0
    - liquidity:
    ["1000000000000000","100000000000000","1000"]
    -burnUnSold:
     true
     - tokenLockTime
     600

*/

module.exports = function (deployer) {
  // deployer.deploy(Migrations);
  deployer.deploy(Staker)
  .then(() => Staker.deployed())
  .then(_instance => {
    console.log("staker address: ",_instance.address)
    deployer.deploy(Factory, _instance.address, polr, feeAddress, uniswapRouter);
  })

};
