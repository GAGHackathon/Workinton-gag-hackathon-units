const ShareWithMe = artifacts.require("TokenRequestGroup");

module.exports = (deployer) => {
    deployer.deploy(ShareWithMe,["0x0aeEd69C2CCF320aCDC58785c7381eccaC4211B9"]);
};