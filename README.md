# AIstronaut Smart Contract

## Overview
The **AIstronaut** smart contract is an **ERC-721** based NFT system that allows users to create AI agents as NFTs. Each agent has attributes such as **strength, intelligence, and survival instinct**. Users can also purchase points to enhance their agents' attributes. The contract maintains a **leaderboard** ranking agents based on their scores.

## Features
- **Mint AI Agents as NFTs**
- **Customize Agent Attributes**
- **Purchase Additional Points**
- **Automated Leaderboard Ranking**
- **Admin-Controlled Point Pricing & Withdrawals**

---

## Smart Contract Functions

### 1. **createAgent**
```solidity
function createAgent(
    string memory name,
    address ownerAddress,
    string memory avatarId,
    string memory bio
) external;
```
- Mints a new **AI Agent NFT** for the given owner.
- Initializes the agent with 10 **unused points**.
- Adds the agent to the leaderboard.
- Emits an `AgentCreated` event.

---

### 2. **updateAgent**
```solidity
function updateAgent(
    uint256 tokenId,
    uint256 strength,
    uint256 intelligence,
    uint256 survivalInstinct,
    uint256 unusedPoints,
    uint256 score
) external;
```
- Updates the attributes of an existing agent.
- Computes **total attributes** based on updated stats.
- Updates the leaderboard ranking.
- Emits an `AgentUpdated` event.

---

### 3. **purchasePoints**
```solidity
function purchasePoints(uint256 agentId) external payable;
```
- Allows users to **buy additional points** for their agent.
- Requires payment of **0.0001 ETH per point (10 points per purchase).**
- Emits a `PointsPurchased` event.

---

### 4. **updateLeaderboard**
```solidity
function updateLeaderboard() public;
```
- **Sorts** agents based on their **score** using Bubble Sort.
- Emits a `LeaderboardUpdated` event.

---

### 5. **getAgentDetails**
```solidity
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
);
```
- Returns the **complete details** of an AI agent.

---

### 6. **getAllAgents**
```solidity
function getAllAgents() external view returns (uint256[] memory);
```
- Returns an array containing all **minted agent IDs**.

---

### 7. **getLeaderboard**
```solidity
function getLeaderboard() external view returns (uint256[] memory tokenIds, uint256[] memory scores);
```
- Returns the **ranked leaderboard** of agents based on their scores.

---

### 8. **updatePointPrice** *(Admin Only)*
```solidity
function updatePointPrice(uint256 newPrice) external;
```
- **Admin-only** function to modify the **price of points**.

---

### 9. **withdrawIncome** *(Admin Only)*
```solidity
function withdrawIncome(address recipient) external;
```
- **Admin-only** function to withdraw ETH from the contract balance.

---

## Events
- `AgentCreated(uint256 indexed tokenId, string name, address indexed owner);`
- `AgentUpdated(uint256 indexed tokenId, uint256 strength, uint256 intelligence, uint256 survivalInstinct);`
- `PointsPurchased(uint256 indexed agentId, uint256 amount);`
- `LeaderboardUpdated(uint256[] rankedAgents);`

## License
This project is licensed under the **MIT License**.

