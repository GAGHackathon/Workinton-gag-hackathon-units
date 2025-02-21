// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenRequestGroup {
    struct Request {
        address requester;
        address tokenAddress;
        uint256 amount;
        uint256 approvals;
        bool accepted;
    }

    struct Group {
        address[] members;
        mapping(address => bool) isMember;
    }

    struct MembershipRequest {
        address member;
        uint256 approvals;
        bool accepted;
        bool isAddition; // true for addition, false for removal
    }

    mapping(address => Request[]) public requests;
    Group private group;
    MembershipRequest[] public membershipRequests;

    event RequestCreated(address indexed requester, address indexed tokenAddress, uint256 amount, address indexed recipient);
    event RequestApproved(address indexed approver, address indexed recipient, uint256 requestIndex);
    event RequestAccepted(address indexed recipient, uint256 requestIndex);
    event MemberAdded(address indexed newMember);
    event MemberRemoved(address indexed removedMember);
    event MembershipRequestCreated(address indexed member, bool isAddition);
    event MembershipRequestApproved(address indexed approver, uint256 requestIndex);
    event MembershipRequestAccepted(address indexed member, bool isAddition);

    modifier onlyGroupMember() {
        require(group.isMember[msg.sender], "Not a group member");
        _;
    }

    constructor(address[] memory initialMembers) {
        for (uint256 i = 0; i < initialMembers.length; i++) {
            group.members.push(initialMembers[i]);
            group.isMember[initialMembers[i]] = true;
        }
    }

    function createMembershipRequest(address member, bool isAddition) public onlyGroupMember {
        if (isAddition) {
            require(!group.isMember[member], "Already a group member");
        } else {
            require(group.isMember[member], "Not a group member");
        }
        membershipRequests.push(MembershipRequest({
            member: member,
            approvals: 0,
            accepted: false,
            isAddition: isAddition
        }));
        emit MembershipRequestCreated(member, isAddition);
    }

    function approveMembershipRequest(uint256 requestIndex) public onlyGroupMember {
        MembershipRequest storage request = membershipRequests[requestIndex];
        require(!request.accepted, "Request already accepted");

        request.approvals += 1;
        emit MembershipRequestApproved(msg.sender, requestIndex);

        if (request.approvals >= group.members.length - 1) {
            request.accepted = true;
            if (request.isAddition) {
                group.members.push(request.member);
                group.isMember[request.member] = true;
                emit MemberAdded(request.member);
            } else {
                group.isMember[request.member] = false;
                for (uint256 i = 0; i < group.members.length; i++) {
                    if (group.members[i] == request.member) {
                        group.members[i] = group.members[group.members.length - 1];
                        group.members.pop();
                        break;
                    }
                }
                emit MemberRemoved(request.member);
            }
            emit MembershipRequestAccepted(request.member, request.isAddition);
        }
    }

    function createRequest(address recipient, address tokenAddress, uint256 amount) public onlyGroupMember {
        require(group.isMember[recipient], "Recipient is not a group member");
        requests[recipient].push(Request({
            requester: msg.sender,
            tokenAddress: tokenAddress,
            amount: amount,
            approvals: 0,
            accepted: false
        }));
        emit RequestCreated(msg.sender, tokenAddress, amount, recipient);
    }

    function approveRequest(address recipient, uint256 requestIndex) public onlyGroupMember {
        Request storage request = requests[recipient][requestIndex];
        require(!request.accepted, "Request already accepted");
        require(msg.sender != request.requester, "Requester cannot approve their own request");

        request.approvals += 1;
        emit RequestApproved(msg.sender, recipient, requestIndex);

        if (request.approvals >= group.members.length - 1) {
            request.accepted = true;
            IERC20 token = IERC20(request.tokenAddress);
            require(token.transferFrom(recipient, request.requester, request.amount), "Token transfer failed");
            emit RequestAccepted(recipient, requestIndex);
        }
    }

    function getRequests(address recipient) public view returns (Request[] memory) {
        return requests[recipient];
    }

    function getGroupMembers() public view returns (address[] memory) {
        return group.members;
    }

    function getMembershipRequests() public view returns (MembershipRequest[] memory) {
        return membershipRequests;
    }
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
