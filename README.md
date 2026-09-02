# Project Longshot: The Hidden Cost of Gambling

MATLAB models built for the 2026 MathWorks Math Modeling Challenge (M3).
**Honorable Mention — top ~4% of 770 international teams.** Team #19145,
written under the competition's 14-hour constraint.

The question: how much do sports bettors actually lose, who loses the most
relative to what they have, and what is that worth over a lifetime?

## What the model does

**Q1 — Disposable income.** Estimates disposable income for five demographic
personas across the U.S. and U.K. by working from gross income through
progressive tax logic and Engel-curve-based essential spending, segmented by
age, region, and housing status.

**Q2 — Monte Carlo simulation.** Simulates 52-week sportsbook account
trajectories, 3,000 trials per persona per risk tier. Betting frequency is
Poisson-distributed with market-specific rate categories; win probabilities are
calibrated to house edge (5% straight, 15% parlay); stake sizing and
straight-versus-parlay mix vary by risk tier. Withdrawal behaviour is drawn per
account from four behavioural types.

**Q3 — Foregone wealth.** Converts one-year losses into a 20-year compounded
opportunity cost at 6%, then normalizes it against disposable income as a
**Wealth Impact Ratio**. Reports empirical CDFs and tail statistics.

## Key findings

- Average simulated annual losses ran **10–15% of bankroll**
- **10th-percentile outcomes exceeded 40–50%** of bankroll
- Lower-income bettors face disproportionately larger *percentage* losses
  despite smaller absolute dollar amounts — the finding the Wealth Impact Ratio
  was built to surface

## Running it

Requires MATLAB with the Statistics and Machine Learning Toolbox
(`poissrnd`, `randsample`, `prctile`, `ecdf`).

```matlab
[US, UK] = Q1_RunModel_Embedded();   % disposable income tables
Q2_GraphRiskDistributions();         % outcome distributions by risk tier
Results = Q3_CDF_FromQ2();           % CDFs + summary table
```

`rng(1)` is set in Q2 and Q3, so results reproduce exactly.

## Files

| File | Purpose |
|---|---|
| `Q1_RunModel_Embedded.m` | Disposable income model (U.S. and U.K.) |
| `Q2_GraphRiskDistributions.m` | Monte Carlo distributions by risk tier |
| `Q3_CDF_FromQ2.m` | Foregone wealth CDFs and summary table |
| `simulate_one_year.m` | Single 52-week account trajectory |
| `q3_foregone_metrics.m` | Loss-to-foregone-wealth conversion |
| `model_params.m` | Shared parameters for Q2 and Q3 |

## Limitations

Written in 14 hours, and it shows in places worth naming honestly:

- **Tax "calibration" is back-fitting.** The bracket rates are fit through two
  known points rather than estimated from raw microdata, so the model
  reproduces the four target profiles by construction. It would not generalize
  to arbitrary incomes without re-fitting.
- **Essential-spending multipliers are anchored to single observations** per
  age and region rather than to a regression across the full Consumer
  Expenditure Survey.
- **Bettors are modelled as memoryless.** No chasing behaviour, no bankroll
  replenishment from income, no correlation between bets in a parlay.
- **Fixed house edge.** Real sportsbook holds vary by sport, market, and
  bet type.
- **U.K. National Insurance is fit through two points**, which is a linear
  approximation of a genuinely piecewise system.

## What I'd do differently

Estimate the income model from the underlying microdata rather than
back-fitting to summary targets, add bankroll replenishment and loss-chasing
to the behavioural model, and run sensitivity analysis on house edge and
compounding rate rather than fixing them.
