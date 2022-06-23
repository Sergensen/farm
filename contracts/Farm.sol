//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Farm is AccessControl, ReentrancyGuard {
    bytes32 public constant FARMER_ROLE = keccak256("FARMER_ROLE");
    bytes32 public constant FARM_CHIEF_ROLE = keccak256("FARM_CHIEF_ROLE");
    uint32 constant minimumVotingPeriod = 20;
    uint256 proposalCounter;

    struct Proposal {
        uint256 id;
        uint256 livePeriod;
        uint256 votesFor;
        uint256 votesAgainst;
        string description;
        bytes callData;
        bool votingPassed;
        address target;
        address payable payableTarget;
        address proposer;
        bool executed;
        address executedBy;
        uint256 amount;
    }

    event Response (bool success, bytes data);
    event CornReceived(address indexed fromAddress, uint256 amount);
    event NewProposal(address indexed farmer);
    event SeedsSown(
        address indexed farmer,
        address indexed target,
        string callData
    );
    event SeedsTransfered(
        address indexed farmer,
        address indexed target,
        uint256 amount
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

    function becomeFarmer() external payable {
        address account = msg.sender;
        uint256 amountContributed = msg.value;
        if (!hasRole(FARMER_ROLE, account)) {
            if (amountContributed >= 0.1 ether) {
                farmers[account] = amountContributed;
                _setupRole(FARMER_ROLE, account);
            }
        } else {
            farmers[account] += amountContributed;
        }
    }

    function getProposals()
        public
        view
        returns (Proposal[] memory props)
    {
        props = new Proposal[](proposalCounter);

        for (uint256 index = 0; index < proposalCounter; index++) {
            props[index] = proposals[index];
        }
    }

    function getProposal(uint256 proposalId)
        public
        view
        returns (Proposal memory)
    {
        return proposals[proposalId];
    }

    function getFarmerVotes()
        public
        view
        onlyFarmer
        returns (uint256[] memory)
    {
        return farmerVotes[msg.sender];
    }

    function getFarmerBalance()
        public
        view
        onlyFarmer
        returns (uint256)
    {
        return farmers[msg.sender];
    }

    function isFamer() public view returns (bool) {
        return farmers[msg.sender] > 0;
    }

    function createProposal(
        bytes calldata callData,
        string calldata description,
        address target
    )
        external
        onlyFarmer
    {
        uint256 proposalId = proposalCounter++;
        Proposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.proposer = msg.sender;
        proposal.callData = callData;
        proposal.description = description;
        proposal.target = target;
        proposal.livePeriod = block.number + minimumVotingPeriod;

        emit NewProposal(msg.sender);
    }

    function createPayableProposal(
        uint256 amount,
        string calldata description,
        address payable target
    )
        external
        onlyFarmer
    {
        uint256 proposalId = proposalCounter++;
        Proposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.proposer = msg.sender;
        proposal.amount = amount;
        proposal.description = description;
        proposal.payableTarget = target;
        proposal.livePeriod = block.number + minimumVotingPeriod;

        emit NewProposal(msg.sender);
    }

    function vote(uint256 proposalId, bool supportProposal)
            external
            onlyFarmer
    {
        Proposal storage proposal = proposals[proposalId];

        votable(proposal);

        if (supportProposal) proposal.votesFor++;
        else proposal.votesAgainst++;

        farmerVotes[msg.sender].push(proposal.id);
    }

    function votable(Proposal storage proposal) private {
        if (
            proposal.votingPassed ||
            proposal.livePeriod <= block.number
        ) {
            proposal.votingPassed = true;
            revert("Voting period has passed on this proposal");
        }

        uint256[] memory tempVotes = farmerVotes[msg.sender];
        for (uint256 votes = 0; votes < tempVotes.length; votes++) {
            if (proposal.id == tempVotes[votes])
                revert("This stakeholder already voted on this proposal");
        }
    }

    function executeProposal(uint256 proposalId)
        external
        onlyFarmer

    {
        Proposal storage proposal = proposals[proposalId];

        if (proposal.amount > 0)
            revert("Proposal should not contain an amount.");

        if (proposal.executed)
            revert("Proposal already has been executed.");

        if (proposal.votesFor <= proposal.votesAgainst)
            revert(
                "The proposal does not have the required amount of votes to pass"
            );

        proposal.executed = true;
        proposal.executedBy = msg.sender;

        emit SeedsSown(
            msg.sender,
            proposal.target,
            proposal.description
        );

        (bool success, bytes memory data) = proposal.target.call(proposal.callData);
        require(success);

        emit Response(success, data);
    }

    function transfer(uint256 proposalId)
        external
        onlyFarmer
    {
        Proposal storage proposal = proposals[proposalId];

        if (proposal.executed)
            revert("Proposal already has been executed.");

        if (proposal.votesFor <= proposal.votesAgainst)
            revert(
                "The proposal does not have the required amount of votes to pass"
            );

        proposal.executed = true;
        proposal.executedBy = msg.sender;

        emit SeedsTransfered(
            msg.sender,
            proposal.target,
            proposal.amount
        );

        return proposal.payableTarget.transfer(proposal.amount);
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

    receive() external payable {
        emit CornReceived(msg.sender, msg.value);
    }
}
