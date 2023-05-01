//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Voting{
    uint id=1;
    struct  Candidate{
        uint candidateId;
        string candidateName;
        uint candidateAge;
        string partyName;
        address candidateAddress;
        uint    votesRececieved;
    }
    struct Voter{
        uint voterId;
        address voterAddress;
        bool hasVoted;
    }
    struct Election {
        uint id;
        address organizerAddress;
        address[]  allCandidateAddresses;
        address[]  votedList;
        mapping(address=>Candidate)  candidates;
        mapping(address=>bool) candidateExists;
        mapping(address=>Voter)  voters;
        bool electionStarted;
        bool electionEnded;
    }
    address [] public organizersList;
   uint public organizersCount;
 
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
            organizersList.push(_organizer);
            organizersCount=organizersCount+1;
    
    }
 
    function startVoting(address _organizer) public isElectionOrganizer(_organizer){

        organizerOfElection[_organizer].electionStarted=true;
        organizerOfElection[_organizer].organizerAddress=_organizer;
        emit electionStartEvent("Election has now started");
    }
   
       function endVoting(address _organizer) public isElectionOrganizer(_organizer) {
        organizerOfElection[_organizer].electionStarted=false;
        organizerOfElection[_organizer].electionEnded=true;
         emit electionEndEvent("Election has now ended");
    }
    
    function checkStatusOfElection(address _organizer) external view returns(bool started, bool ended) {
                started=organizerOfElection[_organizer].electionStarted;
                ended=  organizerOfElection[_organizer].electionEnded;
                return (started,ended);
    }
    function setCandidate(string memory _name, uint _age, string memory _partyName, address _address, address _organizer) public isElectionOrganizer(_organizer){
        require(!organizerOfElection[_organizer].candidateExists[_address],"Already candidate exists");
        Candidate storage candidate= organizerOfElection[_organizer].candidates[_address];
        id=id+1;
        candidate.candidateId=id;
        candidate.candidateName=_name;
        candidate.candidateAge=_age;
        candidate.partyName=_partyName;
        candidate.candidateAddress=_address;
        organizerOfElection[_organizer].allCandidateAddresses.push(_address);
        emit candidateAddedEvent(_address,"Candidate has been added successfully");
    }
     
    function voteTo(address _candidateAddress ,address _organizer, address _voter,bool _ageEligibility) public {
        require(_ageEligibility,"Not eligible ");
         require(organizerOfElection[ _organizer].electionStarted,"Election not started...! ");
        Voter storage voter=organizerOfElection[_organizer].voters[_voter];
        require(!voter.hasVoted,"Already Voted");
        require(_voter!=_organizer,"Organizer can't vote");
        voter.voterAddress=_voter;
        organizerOfElection[_organizer].candidates[_candidateAddress].votesRececieved+=1;
        voter.hasVoted=true;
        organizerOfElection[_organizer].votedList.push(_voter);
        emit voterVotedEvent(msg.sender,"Voter has voted");
    }

      function displayCandidateDetails(address _organizer, uint _index) public view returns(string memory name , address candidateAddress, string memory party, uint votesGained, uint totalCandidates ){
         address [] memory allCandidates=organizerOfElection[_organizer].allCandidateAddresses;  
         name=organizerOfElection[_organizer].candidates[allCandidates[_index]].candidateName;
         candidateAddress=organizerOfElection[_organizer].candidates[allCandidates[_index]].candidateAddress;
         party=organizerOfElection[_organizer].candidates[allCandidates[_index]].partyName;
         votesGained=organizerOfElection[_organizer].candidates[allCandidates[_index]].votesRececieved;
         totalCandidates=allCandidates.length;
          return (name, candidateAddress,party,votesGained,totalCandidates); 
    }
}