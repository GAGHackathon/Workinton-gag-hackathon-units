var contractAddress = '0xdf58f56e743de48d40b50e59123f1622c5a96502';
const contractABI = [/* YOUR_CONTRACT_ABI */];
document.getElementById('connectWallet').addEventListener('click', async () => {
    if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        await window.ethereum.enable();
        const accounts = await web3.eth.getAccounts();
        document.getElementById('walletAddress').innerText = `Bağlı hesap: ${accounts[0]}`;
        loadGroupMembers();
        loadMembershipRequests();
    } else {
        alert('Metamask yüklü değil!');
    }
});



const contract = new web3.eth.Contract( contractAddress);
console.log(contract.methods[0]);
async function loadGroupMembers() {
    const members = await contract.methods.getGroupMembers().call();
    const membersList = document.getElementById('groupMembers');
    membersList.innerHTML = '';
    members.forEach(member => {
        const li = document.createElement('li');
        li.innerText = member;
        membersList.appendChild(li);
    });
}

/* async function loadMembershipRequests() {
    const requests = await contract.methods.getMembershipRequests().call();
    const requestsList = document.getElementById('membershipRequests');
    requestsList.innerHTML = '';
    requests.forEach((request, index) => {
        const li = document.createElement('li');
        li.innerText = `Adres: ${request.member}, Onaylar: ${request.approvals}, Kabul Edildi: ${request.accepted}`;
        requestsList.appendChild(li);
    });
} */

document.getElementById('createMembershipRequest').addEventListener('click', async () => {
    const newMemberAddress = document.getElementById('newMemberAddress').value;
    await contract.methods.createMembershipRequest(newMemberAddress, true).send({ from: web3.eth.accounts[0] });
    loadMembershipRequests();
});