//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
@dev An instance of a proposal
 */

contract Proposal {

    //state variables
    uint public percentageAcceptance;
    bool private isProposalOn;
    uint256 private numberOfApprovals;
    uint256 private approvedPercent;
    address public ownerContract;
    address public proposalOwner;

    address[] public agreeingOwners;
    string public proposalInformation;
    

    //mapping
    mapping(address => bool) public agreeingOwnersList;


    constructor() {
        percentageAcceptance = 60;
        ownerContract = msg.sender;
    }

    //MODIFIERS
    
    modifier onlyWallet {
        require(msg.sender == ownerContract); //the wallet contract can only call the proposal
        _;
    }

    

    //EVENTS
    event ChangeAcceptance(uint256 _percentage);
    event CreateProposal(address indexed sender, uint256 id);
    event ApproveProposal(address indexed sender);
    event ExecuteApproval(address indexed sender);

    //change the percentage
    function changePercent(uint256 _percentage) 
    external 
    onlyWallet {
        assert(_percentage <= 100);
        percentageAcceptance = _percentage;

        emit ChangeAcceptance(_percentage);
    }

    //approve a proposal
    function approve(address _sender) 
    external
    onlyWallet {
        require(isProposalOn);
        require(!agreeingOwnersList[_sender]);
        agreeingOwnersList[_sender] = true;
        agreeingOwners.push(_sender);
        numberOfApprovals = numberOfApprovals + 1;
        
        
        emit ApproveProposal(msg.sender);
    }

    //execute proposal
    function execute(address _sender,uint256 _totalNumberOwners)
    external
    onlyWallet {
        //function can only be called by the owner who made the proposal
        if(_sender != proposalOwner) {
            revert("Caller is no allowed!!");
        } else {
        // calculate the percentage of acceptance
        //check that the specified percentage condition is met
        approvedPercent = numberOfApprovals/_totalNumberOwners*100;
        require(approvedPercent >= percentageAcceptance);

        //EXECUTE 

        for(uint256 i; i < agreeingOwners.length; i++) {
            agreeingOwnersList[agreeingOwners[i]] = false; //reset the list of owners that approved the proposal
        }
        //reset 
        isProposalOn = false; 
        numberOfApprovals = 0;

        emit ExecuteApproval(msg.sender);
        }
        
        
    }

    
    function setProposalInfo(string memory _info, address _adr)
    external
    onlyWallet
    returns(bool) {
        proposalOwner = _adr;
        proposalInformation = _info;
        return true;
    }

    function getProposerAddress()
    external
    view
    returns(address) {
        return proposalOwner;
    }

    function getPercent()
    external
    view
    returns(uint256) {
        return percentageAcceptance;
    }
    




    
}
