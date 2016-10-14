import "Rules.sol";
import "examples/StandardTokenFreezer.sol";
import "BoardRoom.sol";

contract TokenFreezerRules is Rules {
  function TokenFreezerRules(address _freezer) {
    token = StandardTokenFreezer(_freezer);
  }

  function hasWon(uint _proposalID) constant returns (bool) {
    BoardRoom board = BoardRoom(msg.sender);
    var (name, destination, proxy, value, hash, executed, debatePeriod, created) = board.proposals(_proposalID);
    uint nay = board.positionWeightOf(_proposalID, 0);
    uint yea = board.positionWeightOf(_proposalID, 1);

    if((yea + nay) > StandardToken(token.token()).totalSupply() / 20
      && yea > nay) {
      return true;
    }
  }

  function canVote(address _sender, uint _proposalID) constant returns (bool) {
    BoardRoom board = BoardRoom(msg.sender);
    var (name, destination, proxy, value, hash, executed, debatePeriod, created) =  board.proposals(_proposalID);

    if(votingWeightOf(_sender, _proposalID) > 0
      && now < (created + debatePeriod)
      && token.frozenUntil(_sender) > (created + debatePeriod)
      && board.hasVoted(_proposalID, _sender) == false) {
      return true;
    }
  }

  function canPropose(address _sender) constant returns (bool) {
    if(token.balanceOf(_sender) > 0) {
      return true;
    }
  }

  function votingWeightOf(address _sender, uint _proposalID) constant returns (uint) {
    return token.balanceOf(_sender);
  }

  StandardTokenFreezer public token;
}
