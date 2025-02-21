const Web3 = require('web3');
const TokenRequestGroup = artifacts.require("TokenRequestGroup");

module.exports = async function(callback) {
  try {
    const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    const accounts = await web3.eth.getAccounts();
    const instance = await TokenRequestGroup.deployed();

    // Grup üyesi ekleme
    await instance.addMember("0x789...", { from: accounts[0] });
    console.log("Yeni üye eklendi");

    // Token isteğinde bulunma
    await instance.createRequest("0x456...", "0xTokenAddress...", 100, { from: accounts[0] });
    console.log("Token isteğinde bulunuldu");

    // İsteği kabul etme
    await instance.acceptRequest(0, { from: "0x456..." });
    console.log("İstek kabul edildi");

    callback();
  } catch (error) {
    console.error(error);
    callback(error);
  }
};