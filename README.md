# 🧮 Collateralization Ratio Slope Trap

### DeFi Liquidation Predictor (Drosera Trap)

## Overview

The **Collateralization Ratio Slope Trap** is a predictive risk-monitoring trap designed to detect accounts or vaults that are rapidly approaching undercollateralization.

Instead of relying on static collateral thresholds, this trap analyzes **how fast collateral health is deteriorating over time**, allowing protocols to act *before* forced liquidations occur.

---

## Why This Matters

Liquidations are expensive and destabilizing:

* High slippage
* MEV extraction
* Bad debt risk
* Cascading liquidations

Most protocols only react **after** a collateral ratio crosses a hard limit. This trap provides **early warning**, enabling safer, proactive risk management.

---

## What the Trap Detects

For a given account, vault, or aggregate pool, the trap monitors:

* Collateralization ratio per block
* **Slope** (first derivative): how fast the ratio is falling
* **Acceleration** (second derivative): whether the fall is speeding up
* Consistent downward trends across multiple blocks

The trap triggers when deterioration is both **fast** and **accelerating**.

---

## Architecture

This system follows the standard **Drosera feeder → trap → responder** model.

### 1. Feeder

* Computes the collateralization ratio (in basis points)
* Can target:

  * a single high-risk account
  * a vault
  * an aggregated borrower pool
* Exposes a clean snapshot every block

### 2. Trap

* `collect()` reads the feeder snapshot safely
* `shouldRespond()` performs time-series analysis
* Pure, deterministic logic
* No state writes or side effects

### 3. Responder

When triggered, the responder can:

* Emit risk events
* Flag risky positions
* Restrict further borrowing
* Trigger partial liquidations
* Alert off-chain risk systems

---

## Detection Logic (Simplified)

1. Read collateral ratios over the last N blocks
2. Compute slope (Δ collateral ratio)
3. Compute acceleration (change in slope)
4. Verify a persistent downward trend
5. Trigger if thresholds are exceeded

This avoids false positives from short-lived price movements.

---

## Example Scenario

| Block | Collateral Ratio |
| ----- | ---------------- |
| N-3   | 190%             |
| N-2   | 175%             |
| N-1   | 155%             |
| N     | 138%             |

The account is not liquidatable yet, but deterioration is rapid. The trap triggers **before liquidation bots act**.

---

## Key Properties

* ✅ Predictive, not reactive
* ✅ Time-series and derivative-based
* ✅ Drosera-compliant and deterministic
* ✅ Reduces liquidation severity and bad debt
* ✅ Improves protocol risk management

---

## Summary

**The Collateralization Ratio Slope Trap identifies positions that are becoming unsafe quickly, giving protocols time to intervene before forced liquidations occur.**

It enables smarter, earlier, and safer responses to market stress.
