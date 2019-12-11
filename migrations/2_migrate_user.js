var SmartHousing = artifacts.require("./SmartHousing.sol");
const bcrypt = require('bcrypt');
const saltRounds = 10;
const landlord_name = "Yuan Tai Liu";
const landlord_pid = "A123456789";

module.exports = function(deployer,accounts) {
    hash = bcrypt.hashSync(landlord_pid,saltRounds);
    deployer.deploy(SmartHousing,landlord_name,hash);
}