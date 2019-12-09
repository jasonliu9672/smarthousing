var Users = artifacts.require("./Users.sol");
var HouseContract = artifacts.require("./HouseContract.sol");

module.exports = function(deployer) {
    deployer.deploy(HouseContract);
};