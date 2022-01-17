// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// This contract is used to implement a voting application for small enterprises.
// The voting application is a simple mechanism to allow users to vote on a set of proposals.
// It is designed to be used in a decentralized manner.

// Parameters:
// - Voting period: The period of time in which the voting period is open (in seconds)
// - The voter: The voter is the address of the user who is voting.
// - The proposal: The proposal is the entity that's been voted for.
// - The voteCount: The number of casted vote.
// - owner: The address that deploys the contract
// -  voteAmountLimit: The amount of tokens that can be spent on a vote.

interface IVotingInterface {
    //  this function allows you to vote for the proposal.
    function vote() external payable;
}

contract voting is IVotingInterface {
    uint256 public voteCount;
    address public owner;
    uint256 public votingPeriod;
    uint256 public voteAmountLimit;

    mapping(address => uint256) public voters;
    string public proposal;

    constructor(
        uint256 _votingPeriod,
        uint256 _voteAmountLimit,
        string memory _proposal
    ) {
        votingPeriod = block.timestamp + _votingPeriod;
        proposal = _proposal;
        owner = msg.sender;
        voteAmountLimit = _voteAmountLimit;
    }

    receive() external payable {}

    modifier preventMultipleVotes() {
        if (voters[msg.sender] != 0) {
            revert("You have already voted");
        }
        _;
    }

    error customLimitError(string message);

    // This function allows you to vote on the proposal
    function vote() external payable override preventMultipleVotes {
        require(msg.sender != owner, "Owner can not vote");
        if (
            msg.value > voteAmountLimit ||
            msg.value == 0 ||
            msg.value < voteAmountLimit
        ) {
            revert customLimitError("Invalid vote");
        }

        // Check if the voting period is open
        require(block.timestamp < votingPeriod, "Voting period is closed");
        
        // Increase voteCount
        voteCount++;
        // transfer funds to the contract
        payable(msg.sender).transfer(msg.value);
        // add vote
        voters[msg.sender] = msg.value;
    }
}
