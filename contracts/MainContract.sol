// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
contract MainContract{

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public noOfRequests;

    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor(uint _target,uint _deadline) {
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=10 wei;
        manager=msg.sender;
    }    
    modifier onlyManager{
        require(msg.sender==manager,"You are not the manager");
        _;
    }
    modifier onlyContributors{
        require(contributors[msg.sender]>0,"You are not a contributor");
        _;
    }
    function createRequest(string calldata _description,address payable _receipient, uint _value) public onlyManager{
        Request storage newRequest=requests[noOfRequests];
        noOfRequests++;
        newRequest.description=_description;
        newRequest.recipient=_receipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }
    function contrubution() public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum contribution required is 10 Wei");
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;

    }
    function checkBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public onlyContributors{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund now");
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;

    }
    function voteRequest(uint _requestNo) public onlyContributors{
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;

    }
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target,"Target has no been reached");
        Request storage thisrequest=requests[_requestNo];
        require(thisrequest.completed==false,"The request has been completed");
        require(thisrequest.noOfVoters>(noOfContributors/2),"Majority does not support the request");
        thisrequest.recipient.transfer(thisrequest.value);
        thisrequest.completed=true;


    }
}
