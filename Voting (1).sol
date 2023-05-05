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
 

    mapping(address => mapping(uint => Election)) public organizerElections;

    event electionStartEvent(string message);
    event electionEndEvent(string message);
    event candidateAddedEvent(address candidate,string message);
    event voterVotedEvent(address voter,string message);
  
    modifier isElectionOrganizer(address _electionOrganizer){
        _;
        require(msg.sender==_electionOrganizer,"Only organizer allowed");
    }
    
    modifier electionHasEnded(address _electionOrganizer ,uint _id){
        _;
        require(organizerElections[ _electionOrganizer][_id].electionEnded,"Election not Ended ");
    }

    function addOrganizer(address _organizer,uint _id)public{
   
            Election storage election= organizerElections[_organizer][_id];
            election.electionStarted=false;
            election.electionEnded=false;
            organizersList.push(_organizer);
            organizersCount=organizersCount+1;
    }
 
    function startVoting(address _organizer,uint _id) public isElectionOrganizer(_organizer){
        organizerElections[_organizer][_id].electionStarted=true;
        organizerElections[_organizer][_id].organizerAddress=_organizer;
        emit electionStartEvent("Election has now started");
    }
   
    function endVoting(address _organizer,uint _id) public isElectionOrganizer(_organizer) {
       organizerElections[_organizer][_id].electionStarted=false;
        organizerElections[_organizer][_id].electionEnded=true;
         emit electionEndEvent("Election has now ended");
    }
    
    function checkStatusOfElection(address _organizer,uint _id) external view returns(bool started, bool ended) {
                started= organizerElections[_organizer][_id].electionStarted;
                ended=   organizerElections[_organizer][_id].electionEnded;
                return (started,ended);
    }
    function setCandidate(string memory _name, uint _age, string memory _partyName, address _address, address _organizer,uint _id) public isElectionOrganizer(_organizer){
        require(! organizerElections[_organizer][_id].candidateExists[_address],"Already candidate exists");
        Candidate storage candidate=  organizerElections[_organizer][_id].candidates[_address];
        id=id+1;
        candidate.candidateId=id;
        candidate.candidateName=_name;
        candidate.candidateAge=_age;
        candidate.partyName=_partyName;
        candidate.candidateAddress=_address;
       organizerElections[_organizer][_id].allCandidateAddresses.push(_address);
        organizerElections[_organizer][_id].candidateExists[_address]=true;
        emit candidateAddedEvent(_address,"Candidate has been added successfully");
    }
     
    function voteTo(address _candidateAddress ,address _organizer, address _voter,uint _id) public {
         require( organizerElections[_organizer][_id].electionStarted,"Election not started...! ");
        Voter storage voter= organizerElections[_organizer][_id].voters[_voter];
        require(!voter.hasVoted,"Already Voted");
        require(_voter!=_organizer,"Organizer can't vote");
        voter.voterAddress=_voter;
      organizerElections[_organizer][_id].candidates[_candidateAddress].votesRececieved+=1;
        voter.hasVoted=true;
       organizerElections[_organizer][_id].votedList.push(_voter);
        emit voterVotedEvent(msg.sender,"Voter has voted");
    }

      function displayCandidateDetails(address _organizer,uint _id, uint _index) public view returns(string memory name , address candidateAddress, string memory party,  uint totalCandidates ){
         address [] memory allCandidates=  organizerElections[_organizer][_id].allCandidateAddresses;  
         name= organizerElections[_organizer][_id].candidates[allCandidates[_index]].candidateName;
         candidateAddress=  organizerElections[_organizer][_id].candidates[allCandidates[_index]].candidateAddress;
         party=  organizerElections[_organizer][_id].candidates[allCandidates[_index]].partyName;
         totalCandidates=allCandidates.length;
          return (name, candidateAddress,party,totalCandidates); 
    }
    function displayCandidateResults(address _organizer,uint _id, uint _index) public view  electionHasEnded(_organizer,_id) returns (string memory name , address candidateAddress, string memory party, uint votesGained, uint totalCandidates){
        address [] memory allCandidates=  organizerElections[_organizer][_id].allCandidateAddresses;  
         name= organizerElections[_organizer][_id].candidates[allCandidates[_index]].candidateName;
         candidateAddress=  organizerElections[_organizer][_id].candidates[allCandidates[_index]].candidateAddress;
         party=  organizerElections[_organizer][_id].candidates[allCandidates[_index]].partyName;
         votesGained= organizerElections[_organizer][_id].candidates[allCandidates[_index]].votesRececieved;
         totalCandidates=allCandidates.length;
        return (name, candidateAddress,party,votesGained,totalCandidates); 
    }
}