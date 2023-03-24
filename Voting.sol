// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Voting {
    
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }
    
    mapping(address => bool) public hasVoted;
    mapping(uint256 => Candidate) public candidates;
    uint256 public candidatesCount;
    
    event Voted(uint256 indexed candidateId, address indexed voter);
    
    constructor(string[] memory _candidateNames) {
        for (uint256 i = 0; i < _candidateNames.length; i++) {
            addCandidate(_candidateNames[i]);
        }
    }
    
    function addCandidate(string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }
    
    function vote(uint256 _candidateId) public {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID.");
        require(!hasVoted[msg.sender], "You have already voted.");
        candidates[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;
        emit Voted(_candidateId, msg.sender);
    }
    
    function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID.");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    function getCandidatesCount() public view returns (uint256) {
        return candidatesCount;
    }
}


