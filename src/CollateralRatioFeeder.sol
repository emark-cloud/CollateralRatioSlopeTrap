// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICollateralSource {
    function getCollateralRatioBps(address account)
        external
        view
        returns (uint256);
}

contract CollateralRatioFeeder {
    address public immutable source;
    address public immutable target;

    constructor(address _source, address _target) {
        source = _source;
        target = _target;
    }

    function getSnapshot()
        external
        view
        returns (
            uint32 collateralRatioBps,
            uint64 timestamp
        )
    {
        uint256 cr = ICollateralSource(source)
            .getCollateralRatioBps(target);

        require(cr > 0 && cr < type(uint32).max, "BAD_CR");

        collateralRatioBps = uint32(cr);
        timestamp = uint64(block.timestamp);
    }
}

