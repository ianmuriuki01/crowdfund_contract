CrownFund Smart Contract
Overview

The CrownFund contract is a crowdfunding platform built on Ethereum-compatible blockchains using ERC20 tokens.
It allows creators to launch campaigns with funding goals and deadlines, while supporters can pledge tokens toward these campaigns.

If a campaign succeeds (meets or exceeds its funding goal by the end date), the creator can claim the funds. Otherwise, backers can withdraw their pledges as refunds.

Features

Campaign Launching: Creators can define funding goals and timelines.

Cancel Campaign: Campaigns can be canceled by their creators before they start.

Pledge & Cancel Pledge: Backers can pledge ERC20 tokens to campaigns and withdraw before the deadline.

Claim Funds: Creators can withdraw funds if the goal is met.

Refunds: Backers get their funds back if the campaign fails.

Event Logging: Important actions emit events for off-chain indexing.

Contract Details
State Variables

IERC20 immutable token: The ERC20 token used for pledges.

uint256 count: Number of campaigns launched.

mapping(uint256 => Campaign) campaigns: Stores campaign details.

mapping(uint256 => mapping(address => uint256)) pledgedAmount: Tracks pledges per user per campaign.

Struct: Campaign

address creator – Campaign creator.

uint256 goal – Target funding amount.

uint256 pledged – Current pledged amount.

uint32 startTime – Campaign start timestamp.

uint32 endTime – Campaign end timestamp.

bool claimed – Whether funds have been claimed.

Functions
constructor(address _token)

Initializes the contract with the ERC20 token used for pledges.

launch(uint256 _goal, uint32 _startTime, uint32 _endTime)

Creates a new campaign.

Requires:

_startTime ≥ current block time.

_endTime ≥ _startTime.

_endTime ≤ 90 days from now.

Emits: Launch.

cancel(uint256 _id)

Cancels a campaign before it starts. Only the creator can cancel.

Emits: Cancel.

pledge(uint256 _id, uint256 _amount)

Backers pledge tokens to an active campaign.

Transfers tokens from backer to contract.

Emits: Pledge.

cancelPledge(uint256 _id)

Allows backers to withdraw their pledge before campaign ends (if unclaimed).

Refunds tokens to backer.

Emits: CancelPledge.

claim(uint256 _id, uint256 _amount)

Allows campaign creator to claim funds after campaign ends, if successful.

Requires that the goal is met.

Transfers tokens to creator.

Emits: Claim.

refund(uint256 _id)

Backers can claim refunds if the campaign failed.

Transfers pledged tokens back to supporter.

Emits: Refund.

Events

Launch(uint256 id, address creator, uint256 goal, uint32 startTime, uint32 endTime)

Cancel(uint256 id)

Pledge(uint256 id, address sender, uint256 amount)

CancelPledge(uint256 id)

Claim(uint256 id, uint256 amount)

Refund(uint256 id, uint256 amount)

Usage Flow

Creator launches a campaign.

Backers pledge ERC20 tokens.

If the goal is met:

After the end date, the creator calls claim() to withdraw.

If the goal is not met:

Backers can call refund() to retrieve funds.

Backers may also cancel their pledge before the campaign ends.

Security Considerations

ERC20 Dependency: Contract relies on correct ERC20 token behavior.

Reentrancy: Mitigated by updating balances before transfers.

Timelocks: Campaign start and end times are enforced.

Claim Safety: Creators cannot claim more than pledged.

License

This project is licensed under the MIT License
