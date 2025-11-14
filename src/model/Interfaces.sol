// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.20;

interface IEscrowManager {
    function getDeposit(
        address _offramper,
        address _token
    ) external view returns (uint256);

    function deposit(
        address _offramper,
        address _token,
        uint256 _amount
    ) external;

    function withdraw(
        address _offramper,
        address _token,
        uint256 _amount
    ) external;

    function consumeDeposit(
        address _offramper,
        address _token,
        uint256 _amount
    ) external;

    function trackFees(
        address _receiver,
        address _token,
        uint256 _fees
    ) external;
}

interface ITokenManager {
    function addValidTokens(address[] memory _tokens) external;

    function removeValidTokens(address[] memory _tokens) external;

    function isValidToken(address _token) external view returns (bool);

    function getValidTokens() external view returns (address[] memory);
}

interface IRamp {
    function tokenManager() external view returns (ITokenManager);

    function escrowManager() external view returns (IEscrowManager);

    function setIcpEvmCanister(address _icpBackend) external;
}
