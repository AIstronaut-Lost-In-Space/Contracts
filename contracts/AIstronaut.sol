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
    
    // Mapping from owner address to their agent IDs
    mapping(address => uint256[]) private _ownerAgents;

    // Events
    event AgentCreated(uint256 indexed tokenId, string name, address indexed owner);
    event AgentUpdated(uint256 indexed tokenId, uint256 strength, uint256 intelligence, uint256 survivalInstinct);
    event PointsPurchased(uint256 indexed agentId, uint256 amount);
    event LeaderboardUpdated(uint256[] rankedAgents);

    // Constructor with proper inheritance and admin address parameter
    constructor(address adminAddress) ERC721("AIstronaut Agent", "AIAG") Ownable(adminAddress) ReentrancyGuard() {
        contractAdmin = adminAddress;
    }

    // Create new agent with initial attribute allocation
    function createAgent(
        string memory name,
        address ownerAddress,
        string memory avatarId,
        string memory bio,
        uint256 strength,
        uint256 intelligence,
        uint256 survivalInstinct
    ) external {
        require(msg.sender == contractAdmin, "Only owner can create agent");
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        
        // Calculate total attributes and validate against initial points
        uint256 totalAllocated = strength + intelligence + survivalInstinct;
        require(totalAllocated <= 40, "Cannot allocate more than 40 initial points");
        uint256 unusedPoints = 40 - totalAllocated;
        
        agents[newTokenId] = Agent({
            name: name,
            ownerAddress: ownerAddress,
            avatarId: avatarId,
            bio: bio,
            strength: strength,
            intelligence: intelligence,
            survivalInstinct: survivalInstinct,
            unusedPoints: unusedPoints,
            score: 0,
            totalAttributes: totalAllocated
        });

        _safeMint(ownerAddress, newTokenId);
        rankedAgents.push(newTokenId);
        allAgentIds.push(newTokenId);
        
        // Track this agent for the owner
        _ownerAgents[ownerAddress].push(newTokenId);
        
        emit AgentCreated(newTokenId, name, ownerAddress);
        updateLeaderboard();
    }

    // Update agent attributes - only for existing agents
    function updateAgent(
        uint256 tokenId,
        uint256 strength,
        uint256 intelligence, 
        uint256 survivalInstinct,
        uint256 unusedPoints,
        uint256 score
    ) external {
        // Verify agent exists
        require(tokenId > 0 && tokenId <= _tokenIds, "Agent does not exist");
        require(agents[tokenId].ownerAddress != address(0), "Agent does not exist");
        require(msg.sender == agents[tokenId].ownerAddress, "Only owner can update agent");
        
        Agent storage agent = agents[tokenId];
        
        // Validate that the total points don't exceed what's available
        uint256 currentTotal = agent.strength + agent.intelligence + agent.survivalInstinct + agent.unusedPoints;
        uint256 newTotal = strength + intelligence + survivalInstinct + unusedPoints;
        require(newTotal == currentTotal, "Total points cannot change");
        
        // Update attributes with provided values
        agent.strength = strength;
        agent.intelligence = intelligence;
        agent.survivalInstinct = survivalInstinct;
        agent.unusedPoints = unusedPoints;
        agent.score = score;
        agent.totalAttributes = strength + intelligence + survivalInstinct;
        
        emit AgentUpdated(tokenId, strength, intelligence, survivalInstinct);
        updateLeaderboard();
    }

    function purchasePoints(uint256 agentId) external payable {
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
    function getAgentDetails(uint256 tokenId) public view returns (
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

    // Get all agents with basic information
    function getAllAgents() external view returns (
        uint256[] memory tokenIds,
        string[] memory names,
        address[] memory owners
    ) {
        uint256 length = allAgentIds.length;
        tokenIds = new uint256[](length);
        names = new string[](length);
        owners = new address[](length);
        
        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = allAgentIds[i];
            tokenIds[i] = tokenId;
            names[i] = agents[tokenId].name;
            owners[i] = agents[tokenId].ownerAddress;
        }
        
        return (tokenIds, names, owners);
    }
    
    // Get all agents belonging to a specific owner with complete details
    function getAgentsByOwner(address owner) external view returns (
        uint256[] memory tokenIds,
        string[] memory names,
        string[] memory avatarIds,
        string[] memory bios,
        uint256[] memory strengths,
        uint256[] memory intelligences,
        uint256[] memory survivalInstincts,
        uint256[] memory unusedPoints,
        uint256[] memory scores,
        uint256[] memory totalAttributes
    ) {
        uint256[] memory ownerTokens = _ownerAgents[owner];
        uint256 length = ownerTokens.length;
        
        // Initialize return arrays
        tokenIds = new uint256[](length);
        names = new string[](length);
        avatarIds = new string[](length);
        bios = new string[](length);
        strengths = new uint256[](length);
        intelligences = new uint256[](length);
        survivalInstincts = new uint256[](length);
        unusedPoints = new uint256[](length);
        scores = new uint256[](length);
        totalAttributes = new uint256[](length);
        
        // Populate arrays with agent details
        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = ownerTokens[i];
            Agent memory agent = agents[tokenId];
            
            tokenIds[i] = tokenId;
            names[i] = agent.name;
            avatarIds[i] = agent.avatarId;
            bios[i] = agent.bio;
            strengths[i] = agent.strength;
            intelligences[i] = agent.intelligence;
            survivalInstincts[i] = agent.survivalInstinct;
            unusedPoints[i] = agent.unusedPoints;
            scores[i] = agent.score;
            totalAttributes[i] = agent.totalAttributes;
        }
        
        return (
            tokenIds,
            names,
            avatarIds,
            bios,
            strengths,
            intelligences,
            survivalInstincts,
            unusedPoints,
            scores,
            totalAttributes
        );
    }
    
    // Check if an address owns a specific agent
    function isAgentOwner(address owner, uint256 tokenId) external view returns (bool) {
        return agents[tokenId].ownerAddress == owner;
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
    function withdrawIncome(address recipient) external {
        require(msg.sender == contractAdmin, "Only admin can withdraw");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(recipient).transfer(balance);
    }
}