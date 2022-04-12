// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract BlackBox {

	uint256 public deadline;
	uint256 public prizePool;
	address creator;
    bytes32 answer;
	address payable dead = payable(address(0x000000000000000000000000000000000000dEaD));
	
	event AddTime(uint256 newPool, uint256 _deadline);
    event timeFinished(string _string);
	event prizeClaimed(address _winner);

	modifier notFinished {

		require (gameFinished() == false);
		_;
	}

	constructor(uint256 _deadline, bytes32 _answer) {

		deadline = _deadline;
		creator = address(payable(msg.sender));
		answer = _answer;
	}

	function addTime() public payable notFinished {
  	
  		if (msg.value != 0) {

  			deadline += msg.value * 60 / 10000000000000000;
  			prizePool += msg.value;
  			emit AddTime(deadline, prizePool);
  		} 
    }

	function claimPrize(string memory keyphrase) public notFinished {
        
        if (keccak256(abi.encodePacked(keyphrase)) == answer) {
            
            address payable winner = payable(msg.sender);
		    uint256 winnerPrize = (prizePool / 100) * 5;
            prizePool -= winnerPrize;

			(bool sent, ) = winner.call{value: winnerPrize}("");
        	require(sent, "Failed to send Ether");
            
            deadline = 0;
            
            emit prizeClaimed(msg.sender);
        }
    }

	function gameFinished() private returns (bool) {

		if (block.timestamp < deadline) {
			return false;

		} else {

			emit timeFinished("time's up");
			selfdestruct(dead);
			return true;
		}
	}

	receive() external payable {

		prizePool += msg.value;
	}
}

