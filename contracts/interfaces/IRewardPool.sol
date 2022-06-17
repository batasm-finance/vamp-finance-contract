pragma solidity 0.6.12;

interface IRewardPool {
  function pae() external view returns (address);
  function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
}
