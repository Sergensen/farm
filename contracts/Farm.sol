//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Farm is AccessControl, ReentrancyGuard {
    bytes32 public constant FARMER_ROLE = keccak256("FARMER_ROLE");
    bytes32 public constant FARM_CHIEF_ROLE = keccak256("FARM_CHIEF_ROLE");
    uint32 constant minimumVotingPeriod = 1 weeks;
    uint256 proposalCounter;

    struct Proposal {
        uint256 id;
        uint256 livePeriod;
        uint256 votesFor;
        uint256 votesAgainst;
        string description;
        string callData;
        bool votingPassed;
        address target;
        address proposer;
    }

    event Response (bool success, bytes data);
    event CornReceived(address indexed fromAddress, uint256 amount);
    event NewProposal(address indexed farmer, uint256 amount);
    event SeedsSown(
        address indexed farmer,
        address indexed target,
        string callData
    );

    mapping(uint256 => Proposal) private proposals;
    mapping(address => uint256[]) private farmerVotes;
    mapping(address => uint256) private farmers;

    modifier onlyFarmer() {
        require(hasRole(FARMER_ROLE, msg.sender), "Restricted to farmers.");
        _;
    }

    modifier onlyFarmChief() {
        require(hasRole(FARM_CHIEF_ROLE, msg.sender), "Restricted to farm chiefs.");
        _;
    }
    


    function execute(address target, bytes calldata callData) public onlyFarmChief {
        (bool success, bytes memory data) = target.call(callData);
        require(success);

        emit Response(success, data);
    }

    function addFarmChief(address account) public {
        grantRole(FARM_CHIEF_ROLE, account);
    }

    function removeFarmChief(address account) public {
        require(hasRole(FARM_CHIEF_ROLE, account), "Provided account is no admin.");
        renounceRole(FARM_CHIEF_ROLE, account);
    }
}
