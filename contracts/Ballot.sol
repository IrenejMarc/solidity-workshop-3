pragma solidity ^0.4.10;

contract Ballot {
  address public owner;
  uint votingStartTime;
  uint votingEndTime;
  string description;

  mapping(address => bool) voters;
  mapping(bool => uint) votes;

  enum BallotState {
    Waiting,
    Voting,
    Ended
  }

  BallotState ballotState = BallotState.Waiting;

  modifier onlyState(BallotState state) {
    require(ballotState == state);
    _;
  }

  modifier notVotedYet {
    require(voters[msg.sender] == false);
    _;
  }

  modifier timedStateTransition() {
    if (ballotState == BallotState.Waiting && now >= votingStartTime) {
      advanceState();
    } else if (ballotState == BallotState.Voting && now >= votingEndTime) {
      advanceState();
    }
    _;
  }

  function Ballot(string _description, uint _startTime, uint _endTime) public payable {
    owner = msg.sender;

    description = _description;
    votingStartTime = _startTime;
    votingEndTime = _endTime;
  }

  function vote(bool _choice) public notVotedYet timedStateTransition onlyState(BallotState.Voting) {
    voters[msg.sender] = true;
    votes[_choice] += 1;
  }

  function advanceState() internal {
    require(ballotState != BallotState.Ended);

    ballotState = BallotState(uint(ballotState) + 1);
  }

  function getResult() constant public returns(string) {
    if (votes[true] > votes[false])
      return "Proposition passed";
    else
      return "Propositoin failed";
  }
}
