pragma solidity 0.4.15;

import './LordCoin.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract LordCoinPreICO is Ownable {
    using SafeMath for uint256;

    string public name = "Lord Coin Pre-ICO";

    LordCoin public LC;
    address public beneficiary;

    uint256 public priceETH;
    uint256 public priceLC;

    uint256 public weiRaised = 0;
    uint256 public investorCount = 0;

    uint public startTime;
    uint public endTime;

    bool public crowdsaleFinished = false;

    event GoalReached(uint amountRaised);
    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);

    modifier onlyAfter(uint time) {
        require(now > time);
        _;
    }

    modifier onlyBefore(uint time) {
        require(now < time);
        _;
    }

    function LordCoinPreICO (
        address _lcAddr,
        address _beneficiary,
        uint256 _priceETH,
        uint256 _priceLC,

        uint _startTime,
        uint _duration
    ) {
        LC = LordCoin(_lcAddr);
        beneficiary = _beneficiary;
        priceETH = _priceETH;
        priceLC = _priceLC;

        startTime = _startTime;
        endTime = _startTime + _duration * 1 days;
    }

    function () payable {
        require(msg.value >= 0.01 * 1 ether);
        doPurchase(msg.sender, msg.value);
    }

    function withdraw(uint256 _value) onlyOwner {
        beneficiary.transfer(_value);
    }

    function finishCrowdsale() onlyOwner {
        LC.transfer(beneficiary, LC.balanceOf(this));
        crowdsaleFinished = true;
    }

    function doPurchase(address _sender, uint256 _value) private onlyAfter(startTime) onlyBefore(endTime) {
        
        require(!crowdsaleFinished);

        uint256 lcCount = _value.mul(priceLC).div(priceETH);

        require(LC.balanceOf(this) >= lcCount);

        if (LC.balanceOf(_sender) == 0) investorCount++;

        LC.transfer(_sender, lcCount);

        weiRaised = weiRaised.add(_value);

        NewContribution(_sender, lcCount, _value);

        if (LC.balanceOf(this) == 0) {
            GoalReached(weiRaised);
        }
    }
}