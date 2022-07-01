//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Proposal.sol";

/**
 Multisig Wallet smart constract for approving proposals
@dev Smart contract allows for the following:
    1. one administrator who adds/remove member, determine the percentage
    2. Multiple owners
    3. every owner can make a proposal
    4. only co-owners can agree/disagree to a propsal
    5. The approval is executed only when a stated percentage of other members approve

 */
contract Wallet {

    //state variables
    address public owner;
    uint256 private proposalId;
    uint256 private totalNumberOwners;
    Proposal private proposal;
    

    //mapping
    mapping(address => bool) public ownersList; //address of all owners mapped to true
    mapping(uint => Proposal) public listOfProposals; //
    

    constructor() {
        owner = msg.sender;
    }

    //MODIFIERS
    modifier onlyAdmin {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwners {
        require(ownersList[msg.sender]);
        _;
    }

    //EVENTS
    event CreateProposal(address indexed sender, uint256 id);
    event AddOwners(address indexed member);
    event RemoveOwners(address indexed member);


    //FUNCTIONS
    /**
    @dev function calls to add owners to the proposals owners list
    @dev function calls to remove owners address to the proposals owners list
    @dev only Admin can run this
     */


    function addAdr(address _adr) 
    external {
        require(!ownersList[_adr]);
        ownersList[_adr] = true;
        totalNumberOwners = totalNumberOwners + 1;
        emit AddOwners(_adr);
    }

    function removeAdr(address _adr) 
    external {
        require(ownersList[_adr]);
        ownersList[_adr] = false;
        totalNumberOwners = totalNumberOwners - 1;
        emit RemoveOwners(_adr);
    }

    /**
    @dev funtion change the percentage accepted for each proposal
    @dev only admin can run this
     */
    function changePercentage(uint256 _percentage, uint256 _proposalId) 
    external
    onlyAdmin {
    
        listOfProposals[_proposalId].changePercent(_percentage);

    }

    /**
    @dev create a new instance of a proposal smart contract.
    @dev takes in information about the proposal as its constructor arguments
    @dev sets the calling address as the owner of the proposal
     */
    function createProposal(string memory _info) 
    external 
    onlyOwners {
        Proposal myProposal = new Proposal();
        listOfProposals[proposalId] = myProposal;
        listOfProposals[proposalId].setProposalInfo(_info,msg.sender);
        proposalId = proposalId + 1;
       emit CreateProposal(msg.sender, proposalId);
    }

    /**
    @dev function calls the approve function in Id'd proposal
    @dev only owners can run this
     */
    function approveProposal(uint256 _proposalId) 
    external
    onlyOwners {
        listOfProposals[_proposalId].approve(msg.sender);
    }

    /**
    @dev function calls a proposal by id and run its exection function
    @dev only owners can run this
     */
    function executeProposal(uint256 _proposalId)
    external
    onlyOwners {
    
        listOfProposals[_proposalId].execute(msg.sender, totalNumberOwners);
        
    }

    //get the the proposer of a proposal
    function getProposer(uint256 _proposalId) 
    public 
    view
    returns(address) {
        return listOfProposals[_proposalId].getProposerAddress();
    }  

    //returns the percentage of a proposal
    function getPercentage(uint256 _proposalId) 
    public 
    view
    returns(uint256) {
        return listOfProposals[_proposalId].getPercent();
    }
}
