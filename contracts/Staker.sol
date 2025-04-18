// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";

contract Staker is Ownable {
    using SafeMath for uint256;
    using Address for address;

    uint256 public tier_01 = 100 ; // Bronze
    uint256 public tier_02 = 400 ; // Sliver
    uint256 public tier_03 = 1000 ; // Gold
    uint256 public tier_04 = 3000 ; // Emerald
    uint256 public tier_05 = 6000 ; // Ruby
    uint256 public tier_06 = 15000 ; // Pearl

    uint256 public tier_coefficient_01 = 1 ;
    uint256 public tier_coefficient_02 = 1 ;
    uint256 public tier_coefficient_03 = 1 ;
    uint256 public tier_coefficient_04 = 3 ;
    uint256 public tier_coefficient_05 = 6 ;
    uint256 public tier_coefficient_06 = 15 ;

    uint256 public totalPortions = 520 ;

    IERC20 _token;
    mapping (address => uint256) _balances;
    mapping (address => uint256) _unlockTime;
    mapping (address => bool) _isIDO;
    mapping (address => uint256) tier;
    bool halted;

    event Stake(address indexed account, uint256 timestamp, uint256 value);
    event Unstake(address indexed account, uint256 timestamp, uint256 value);
    event Lock(address indexed account, uint256 timestamp, uint256 unlockTime, address locker);

    constructor(address _stakeToken) public {

        _token = IERC20(_stakeToken);
    }

    function getTotalPortions() external returns (uint256) {
        return totalPortions;
    }

    function setTotalPortions(uint256 _totalPortions) external onlyOwner {
        totalPortions = _totalPortions;
    }

    function allocation(address account) external view returns (uint256) {

      return _balances[account];

    }

    function stakedBalance(address account) public view returns (uint256) {
        return _balances[account];
    }

    // function stakedBalance(address account) internal view returns (uint256) {
    //     return _balances[account];
    // }

    function tierLevel(address account) external view returns (uint256) {
      if(stakedBalance(account) >= tier_06){
        return tier_coefficient_06;
      }
      if(stakedBalance(account) >= tier_05){
        return tier_coefficient_05;
      }
      if(stakedBalance(account) >= tier_04){
        return tier_coefficient_04;
      }
      if(stakedBalance(account) >= tier_05){
        return tier_coefficient_05;
      }
      return tier_coefficient_06;

    }

    function unlockTime(address account) external view returns (uint256) {
        return _unlockTime[account];
    }

    function isIDO(address account) external view returns (bool) {
        return _isIDO[account];
    }

    function stake(uint256 value) external notHalted {
        require(value > 0, "Staker: stake value should be greater than 0");
        _token.transferFrom(owner, address(this), value);

        _balances[owner] = _balances[owner].add(value);
        emit Stake(owner,now,value);
    }

    function unstake(uint256 value) external lockable {
        require(_balances[owner] >= value, 'Staker: insufficient staked balance');

        _balances[owner] = _balances[owner].sub(value);
        _token.transfer(owner, value);
        emit Unstake(owner,now,value);
    }

    function lock(address user, uint256 __unlockTime) external onlyIDO {
        require(__unlockTime > now, "Staker: unlock is in the past");
        if (_unlockTime[user] < __unlockTime) {
            _unlockTime[user] = __unlockTime;
            emit Lock(user,now,__unlockTime,owner);
        }
    }

    function halt(bool status) external onlyOwner {
        halted = status;
    }

    function addIDO(address account) external onlyOwner {
        require(account != address(0), "Staker: cannot be zero address");
        _isIDO[account] = true;
    }

    modifier onlyIDO() {
        require(_isIDO[owner],"Staker: only IDOs can lock");
        _;
    }

    modifier lockable() {
        require(_unlockTime[owner] <= now, "Staker: account is locked");
        _;
    }

    modifier notHalted() {
        require(!halted, "Staker: Deposits are paused");
        _;
    }
}
