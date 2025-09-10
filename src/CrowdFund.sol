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
}