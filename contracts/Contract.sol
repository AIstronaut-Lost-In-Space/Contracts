// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AIstronaut is ERC721, Ownable, ReentrancyGuard {
    // Structs
    struct Agent {
        string name;
        address ownerAddress;
        string avatarId;
        string bio;
        uint256 strength;
        uint256 intelligence;
        uint256 survivalInstinct;
        uint256 unusedPoints;
        uint256 score;
        uint256 totalAttributes;
    }

    // State variables
    mapping(uint256 => Agent) public agents;
    uint256 private _tokenIds;
    uint256[] public rankedAgents;
    uint256 public pointPrice = 0.0001 ether; // 1 point costs 0.001 ETH
    uint256[] public allAgentIds;
    address public contractAdmin;

    // Events
    event AgentCreated(uint256 indexed tokenId, string name, address indexed owner);
    event AgentUpdated(uint256 indexed tokenId, uint256 strength, uint256 intelligence, uint256 survivalInstinct);
    event PointsPurchased(uint256 indexed agentId, uint256 amount);
    event LeaderboardUpdated(uint256[] rankedAgents);

    // Constructor with proper inheritance and admin address parameter
    constructor(address adminAddress) ERC721("AIstronaut Agent", "AIAG") Ownable(adminAddress) ReentrancyGuard() {
    contractAdmin = adminAddress;
}



    // Create new agent with provided attributes
    function createAgent(
        string memory name,
        address ownerAddress,
        string memory avatarId,
        string memory bio
    ) external {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        
        agents[newTokenId] = Agent({
            name: name,
            ownerAddress: ownerAddress,
            avatarId: avatarId,
            bio: bio,
            strength: 0,
            intelligence: 0,
            survivalInstinct: 0,
            unusedPoints: 10,
            score: 0,
            totalAttributes: 0
        });

        _safeMint(ownerAddress, newTokenId);
        rankedAgents.push(newTokenId);
        allAgentIds.push(newTokenId);
        emit AgentCreated(newTokenId, name, ownerAddress);
        updateLeaderboard();
    }

    // Update agent attributes
    function updateAgent(
        uint256 tokenId,
        uint256 strength,
        uint256 intelligence, 
        uint256 survivalInstinct,
        uint256 unusedPoints,
        uint256 score
    ) external {
        Agent storage agent = agents[tokenId];
        
        // Directly update attributes with provided values
        agent.strength = strength;
        agent.intelligence = intelligence;
        agent.survivalInstinct = survivalInstinct;
        agent.unusedPoints = unusedPoints;
        agent.score = score;
        agent.totalAttributes = strength + intelligence + survivalInstinct;
        
        emit AgentUpdated(tokenId, strength, intelligence, survivalInstinct);
        updateLeaderboard();
    }

    function purchasePoints(uint256 agentId) external payable{
        require(agentId > 0 && agentId <= _tokenIds && agents[agentId].ownerAddress != address(0), "Agent does not exist");
        require(msg.value >= pointPrice * 10, "Insufficient ETH sent");
        uint256 pointsToAdd = 10;
        agents[agentId].unusedPoints += pointsToAdd;
        emit PointsPurchased(agentId, pointsToAdd);
    }

    // Update leaderboard based on score
    function updateLeaderboard() public {
        uint256 length = rankedAgents.length;
        
        // Sort agents by score (bubble sort)
        for (uint256 i = 0; i < length - 1; i++) {
            for (uint256 j = 0; j < length - i - 1; j++) {
                if (agents[rankedAgents[j]].score < agents[rankedAgents[j + 1]].score) {
                    uint256 temp = rankedAgents[j];
                    rankedAgents[j] = rankedAgents[j + 1];
                    rankedAgents[j + 1] = temp;
                }
            }
        }
        
        emit LeaderboardUpdated(rankedAgents);
    }

    // Get agent details
    function getAgentDetails(uint256 tokenId) external view returns (
        string memory name,
        address ownerAddress,
        string memory avatarId,
        string memory bio,
        uint256 strength,
        uint256 intelligence,
        uint256 survivalInstinct,
        uint256 unusedPoints,
        uint256 score,
        uint256 totalAttributes
    ) {
        Agent memory agent = agents[tokenId];
        return (
            agent.name,
            agent.ownerAddress,
            agent.avatarId,
            agent.bio,
            agent.strength,
            agent.intelligence,
            agent.survivalInstinct,
            agent.unusedPoints,
            agent.score,
            agent.totalAttributes
        );
    }

    // Get all agent IDs
    function getAllAgents() external view returns (uint256[] memory) {
        return allAgentIds;
    }

    // Get leaderboard
    function getLeaderboard() external view returns (uint256[] memory tokenIds, uint256[] memory scores) {
        uint256 length = rankedAgents.length;
        tokenIds = new uint256[](length);
        scores = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            tokenIds[i] = rankedAgents[i];
            scores[i] = agents[rankedAgents[i]].score;
        }
        
        return (tokenIds, scores);
    }

    // Update point price
    function updatePointPrice(uint256 newPrice) external {
        require(msg.sender == contractAdmin, "Only admin can update price");
        pointPrice = newPrice;
    }

    // Withdraw contract balance
    function withdrawIncome(address recipient) external {
        require(msg.sender == contractAdmin, "Only admin can withdraw");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(recipient).transfer(balance);
    }
}