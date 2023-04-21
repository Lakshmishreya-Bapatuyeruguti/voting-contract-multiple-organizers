//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Voting{
    uint id=1;
    struct  Candidate{
        uint candidateId;
        string candidateName;
        uint candidateAge;
        string partyName;
        address candiadateAddress;
        uint    votesRececieved;
    }
    struct Voter{
        uint voterId;
        string voterName;
        address voterAddress;
        uint voterAge;
        bool hasVoted;
    }
    struct Election {
        uint id;
        address organizerAddress;
        address[]  allCandidateAddresses;
        address[]  allVoterAddresses;
        address[]  votedList;
        mapping(address=>Candidate)  candidates;
        mapping(address=>bool) candidateExists;
        mapping(address=>Voter)  voters;
        bool electionStarted;
        bool electionEnded;
    }

    mapping(address => Election) public organizerOfElection;
    mapping (address=>bool)allowedOrganizer;

    event electionStartEvent(string message);
    event electionEndEvent(string message);
    event candidateAddedEvent(address candidate,string message);
    event voterVotedEvent(address voter,string message);
  
    modifier isElectionOrganizer(address _electionOrganizer){
        _;
        require(msg.sender==_electionOrganizer,"Only organizer allowed");
    }
    modifier electionHasStarted(address _electionOrganizer){
        _;
        require(organizerOfElection[ _electionOrganizer].electionStarted,"Election not started ");
    }
    modifier electionHasEnded(address _electionOrganizer){
        _;
        require(organizerOfElection[ _electionOrganizer].electionEnded,"Election not Ended ");
    }

    function addOrganizer(address _organizer)public{
        require(!allowedOrganizer[_organizer],"1 election per organizer");
        Election storage election= organizerOfElection[_organizer];
            election.electionStarted=false;
            election.electionEnded=false;
            allowedOrganizer[_organizer]=true;
    
    }

    function startVoting(address _organizer) public isElectionOrganizer(_organizer){
        organizerOfElection[_organizer].electionStarted=true;
        organizerOfElection[_organizer].organizerAddress=_organizer;
        emit electionStartEvent("Election has now started");
    }
   
       function endVoting(address _organizer) public isElectionOrganizer(_organizer) electionHasStarted(_organizer){
        require( organizerOfElection[_organizer].organizerAddress==_organizer,"Not allowed");
        organizerOfElection[_organizer].electionStarted=false;
        organizerOfElection[_organizer].electionEnded=true;
        allowedOrganizer[_organizer]=false;
         emit electionEndEvent("Election has now ended");
    }
 
    function setCandidate(string memory _name, uint _age, string memory _partyName, address _address, address _organizer) public isElectionOrganizer(_organizer){
        require(!organizerOfElection[_organizer].candidateExists[_address],"Already candidate exists");
        Candidate storage candidate= organizerOfElection[_organizer].candidates[_address];
        id=id+1;
        candidate.candidateId=id;
        candidate.candidateName=_name;
        candidate.candidateAge=_age;
        candidate.partyName=_partyName;
        candidate.candiadateAddress=_address;
        organizerOfElection[_organizer].allCandidateAddresses.push(_address);
         emit candidateAddedEvent(_address,"Candidate has been added successfully");
    }
   
    function addVoter(string memory _name,uint _age,address _address, address _organizer) public isElectionOrganizer(_organizer){
        require(_age>=18,"Not eligible ");
        id=id+1;
        Voter storage voter = organizerOfElection[_organizer].voters[_address];
        voter.voterId=id;
        voter.voterName=_name;
        voter.voterAge=_age;
        voter.voterAddress=_address;
        voter.hasVoted=false;
        organizerOfElection[_organizer].allVoterAddresses.push(_address);
    }   
    function voteTo(address _candidateAddress ,address _organizer) public electionHasStarted(_organizer){
        Voter storage voter=organizerOfElection[_organizer].voters[msg.sender];
        require(!voter.hasVoted,"Already Voted");
        require(msg.sender!=_organizer,"Organizer can't vote");
        organizerOfElection[_organizer].candidates[_candidateAddress].votesRececieved+=1;
        voter.hasVoted=true;
        organizerOfElection[_organizer].votedList.push(msg.sender);
        emit voterVotedEvent(msg.sender,"Voter has voted");
    }
    function showWinner(address _organizer) public view electionHasEnded(_organizer) returns (Candidate memory) {
        uint256 winningVotes = 0;
        uint256 winningCandidateIndex = 0;
        address [] memory allCandidates=organizerOfElection[_organizer].allCandidateAddresses;
        bool electionEnded=organizerOfElection[_organizer].electionEnded;
        require(electionEnded,"Election didn't end");
        for (uint256 i = 0; i < allCandidates.length; i++) {
            if (organizerOfElection[_organizer].candidates[allCandidates[i]].votesRececieved > winningVotes) {
                winningVotes = organizerOfElection[_organizer].candidates[allCandidates[i]].votesRececieved;
                winningCandidateIndex = i;
            }
        }  

        return organizerOfElection[_organizer].candidates[allCandidates[winningCandidateIndex]];
    }
}