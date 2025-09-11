//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IERC20{
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns(bool);
}

contract CrownFund{
    event Launch(
        uint256 id,
        address indexed creator,
        uint256 goal,
        uint32 startTime,
        uint32 endTime
    );
    event Cancel(uint256 id);
    event Pledge(uint256 indexed id, address indexed sender, uint256 amount);
    event CancelPledge(uint256 id);
    event Claim(uint256 indexed id, uint256 amount);
    event Refund(uint256 id, uint256 amount);

    IERC20 immutable token;
    struct Campaign{
        address creator;
        uint256 goal;
        uint256 pledged;
        uint32 startTime;
        uint32 endTime;
        bool claimed;
    }
    uint256 count;
    mapping(uint256=>Campaign) public campaigns;
    mapping(uint256=>mapping(address=>uint256)) public pledgedAmount;

    constructor(address _token){
        token = IERC20(_token);
    }

    function launch(uint256 _goal, uint32 _startTime, uint32 _endTime) external{
        require(_startTime>=block.timestamp, "start time is invalid");
        require(_endTime>= _startTime, "end time invalid");
        require(_endTime <= block.timestamp + 90 days, "end time still invalid");
        count++;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startTime: _startTime,
            endTime: _endTime,
            claimed: false
        });
        emit Launch(count, msg.sender, _goal, _startTime, _endTime);
    }

    function cancel(uint256 _id) external{
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(block.timestamp < campaign.startTime, "campaign started");
        delete campaigns[_id];

        emit Cancel(_id);
    }

    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startTime, "Campaign has not started");
        require(block.timestamp <= campaign.endTime, "Campaign ended");
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;

        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function cancelPledge(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endTime, "campaign ended");
        require(campaign.claimed == false, "campaign already closed");
        uint256 bal = pledgedAmount[_id][msg.sender];
        require(bal > 0, "no pledges made");
        campaign.pledged -= bal;
        pledgedAmount[_id][msg.sender] = 0;

        token.transfer(msg.sender, bal);

        emit CancelPledge(_id);
    }

    function claim(uint256 _id, uint256 _amount) external{
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not the creator");
        require(block.timestamp >= campaign.endTime, "not ended");
        require(campaign.pledged >= campaign.goal, "target not reached");
        require(campaign.claimed == false, "already claimed");
        
        campaign.claimed = true;
        token.transfer(campaign.creator, _amount);
        emit Claim(_id, _amount);
    }

    function refund(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endTime, "not ended");
        require(campaign.pledged < campaign.goal, "goal reached");
        uint256 bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;

        token.transfer(msg.sender, bal);

        emit Refund(_id, bal);
    }
}