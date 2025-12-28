// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CollateralSlopeResponder {
    address public owner;
    address public caller;

    event CollateralRiskDetected(
        uint32 collateralRatioBps,
        int256 slope,
        int256 acceleration,
        uint256 blockNumber
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    modifier onlyCaller() {
        require(msg.sender == caller, "UNAUTHORIZED");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setCaller(address c)
        external
        onlyOwner
    {
        caller = c;
    }

    function handle(bytes calldata payload)
        external
        onlyCaller
    {
        (
            uint32 cr,
            int256 slope,
            int256 accel,
            uint256 blockNumber
        ) = abi.decode(
            payload,
            (uint32, int256, int256, uint256)
        );

        emit CollateralRiskDetected(
            cr,
            slope,
            accel,
            blockNumber
        );

        // Optional extensions:
        // restrictBorrowing();
        // flagAccount();
        // triggerPartialLiquidation();
    }
}

