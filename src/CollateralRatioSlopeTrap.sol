// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface ICollateralRatioFeeder {
    function getSnapshot()
        external
        view
        returns (uint32 collateralRatioBps, uint64 timestamp);
}

contract CollateralRatioSlopeTrap is ITrap {
    address public constant FEEDER =
        0x0000000000000000000000000000000000000000; // set post-deploy

    // Configuration
    int256 public constant SLOPE_THRESHOLD = -300;   // −3% per block
    int256 public constant ACCEL_THRESHOLD = -150;   // acceleration worsening
    uint8 public constant MIN_BLOCKS = 4;

    struct Snap {
        uint32 cr;
        uint64 ts;
    }

    /* ---------------- collect ---------------- */

    function collect()
        external
        view
        override
        returns (bytes memory)
    {
        uint256 size;
        assembly { size := extcodesize(FEEDER) }
        if (size == 0) return bytes("");

        try ICollateralRatioFeeder(FEEDER).getSnapshot()
            returns (uint32 cr, uint64 ts)
        {
            return abi.encode(Snap(cr, ts));
        } catch {
            return bytes("");
        }
    }

    /* ---------------- shouldRespond ---------------- */

    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length < MIN_BLOCKS) return (false, "");

        Snap[] memory s = new Snap[](data.length);
        uint256 count;

        for (uint256 i = 0; i < data.length; i++) {
            if (data[i].length == 0) continue;
            s[count++] = abi.decode(data[i], (Snap));
        }

        if (count < MIN_BLOCKS) return (false, "");

        // First derivative (slope)
        int256 slope1 =
            int256(s[0].cr) - int256(s[1].cr);
        int256 slope2 =
            int256(s[1].cr) - int256(s[2].cr);

        // Second derivative (acceleration)
        int256 acceleration = slope1 - slope2;

        bool trendingDown =
            s[0].cr < s[1].cr &&
            s[1].cr < s[2].cr &&
            s[2].cr < s[3].cr;

        if (
            slope1 <= SLOPE_THRESHOLD &&
            acceleration <= ACCEL_THRESHOLD &&
            trendingDown
        ) {
            bytes memory payload = abi.encode(
                s[0].cr,
                slope1,
                acceleration,
                block.number
            );
            return (true, payload);
        }

        return (false, "");
    }
}

