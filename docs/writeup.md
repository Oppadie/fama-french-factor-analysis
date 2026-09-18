# Does the Fama-French 3-Factor Model Still Hold Up?
### A Rolling-Window Test with Momentum, 2000–2024

## 1. Motivation

The Fama-French 3-factor model (Fama and French, 1993) remains a workhorse
in empirical asset pricing, but markets have changed substantially since its
introduction — most recently through the COVID-19 crash, an unprecedented
monetary tightening cycle (2022), and a concentrated tech-driven recovery.
This project asks a simple question: **has the model's explanatory power for
individual stock returns changed in the post-2020 period, and does adding a
momentum factor change the picture?**

## 2. Data

- **Universe**: 20 large-cap US equities spanning multiple sectors (tech,
  healthcare, energy, financials, consumer staples/discretionary,
  industrials, telecom).
- **Sample period**: January 2000 – December 2024, monthly frequency.
- **Factors**: Fama-French 5-factor data (Mkt-RF, SMB, HML, RMW, CMA) and
  the momentum factor (UMD), downloaded directly from Kenneth French's Data
  Library. Only Mkt-RF, SMB, HML, and UMD are used in this analysis (RMW and
  CMA are included in the merged dataset for potential future extensions
  but not used in the core models here).

## 3. Method

Three nested time-series regressions are run **per stock**:

1. **CAPM**: `excess_ret ~ Mkt-RF`
2. **FF3**: `excess_ret ~ Mkt-RF + SMB + HML`
3. **FF3+UMD**: `excess_ret ~ Mkt-RF + SMB + HML + UMD`

For each, we record the intercept (alpha), its t-statistic, and R².

**Robustness checks:**
- A pre-/post-2020 subsample split, re-running the FF3 regression on each
  half for every stock.
- A rolling 60-month FF3 regression on an equal-weighted portfolio of the
  full universe, to visualize how alpha and fit evolve over time.

## 4. Results

### 4.1 Core model comparison (full sample, all 20 stocks)

| Model    | Mean Alpha | % Significant Alpha | Mean R² | Mean Adj. R² |
|----------|-----------:|---------------------:|--------:|--------------:|
| CAPM     | 0.00315    | 5%                    | 0.278   | 0.276          |
| FF3      | 0.00284    | 5%                    | 0.342   | 0.336          |
| FF3+UMD  | 0.00309    | 5%                    | 0.349   | 0.340          |

Adding SMB and HML raises average R² by about 6.4 percentage points over
CAPM alone — a meaningful improvement. Momentum adds a further ~0.7
percentage points on average: a real but modest incremental gain, in line
with prior literature showing momentum's importance varies substantially
across periods and market regimes.

Only 5% of stocks (1 of 20) show a statistically significant alpha in any
model — close to what would be expected under the null of no true
mispricing at a 95% confidence level. This suggests the factor models are,
on average, doing a reasonable job pricing this universe.

### 4.2 Pre- vs. post-2020 comparison

Perhaps the most striking finding: **16 of 20 stocks show a higher FF3 R²
in the post-2020 period than pre-2020** — the opposite of what a "model
breakdown" hypothesis would predict.

| Stock | Pre-2020 R² | Post-2020 R² | Change |
|-------|------------:|---------------:|-------:|
| AAPL  | 0.341       | 0.658           | +0.317 |
| PG    | 0.069       | 0.369           | +0.300 |
| KO    | 0.162       | 0.467           | +0.305 |
| MSFT  | 0.404       | 0.722           | +0.318 |
| XOM   | 0.256       | 0.557           | +0.301 |
| JPM   | 0.523       | 0.783           | +0.260 |
| GE    | 0.464       | 0.394           | −0.070 |
| IBM   | 0.427       | 0.376           | −0.051 |
| PFE   | 0.242       | 0.194           | −0.048 |
| VZ    | 0.285       | 0.274           | −0.012 |

(Full table in `output/pre_post_2020_comparison.csv`.)

Only 4 stocks (GE, IBM, PFE, VZ) show a decline, and all are modest. The
remaining 16 show increases, several of them large.

### 4.3 Rolling-window alpha

See `output/rolling_alpha.png`. The 60-month rolling FF3 alpha for the
equal-weighted universe portfolio fluctuates around zero for most of the
sample, with visible deviations coinciding with major market events
(notably around 2020 and 2022) before reverting — consistent with
short-lived mispricing during stress periods rather than a persistent,
exploitable pattern.

## 5. Discussion

The rise in R² post-2020 is more likely a story about **markets**, not
about the **model**. Several candidate explanations, none mutually
exclusive:

1. **Elevated market-wide co-movement.** The COVID crash, 2022 rate-hike
   selloff, and subsequent recovery were macro-dominated events that moved
   most stocks in the same direction at the same time — exactly the kind of
   systematic risk that Mkt-RF, SMB, and HML are built to capture. Higher
   factor variance mechanically tends to raise R² when the true factor
   loadings are stable.
2. **Universe effect.** This sample is large-cap and liquid; such stocks
   may track systematic factors more closely than smaller or less liquid
   names, and this tendency could be more pronounced in stressed or
   momentum-driven markets.
3. **Small sample size.** Twenty stocks is illustrative, not
   representative of the full market. A broader universe (e.g. S&P 500
   constituents) would be a natural robustness check.

## 6. Limitations

- The 20-stock universe is not representative of the broader market and
  is tilted toward large, liquid, well-known names.
- No transaction costs, delisting, or survivorship-bias adjustments are
  applied.
- The post-2020 subsample is short (5 years) relative to the pre-2020
  subsample (20 years), so estimates for the post-2020 period are noisier.
- Momentum's known structural breaks (e.g. the 2009 "momentum crash") are
  not explicitly modeled; the UMD factor is used as-is.

## 7. References

Fama, E. F., & French, K. R. (1993). Common risk factors in the returns on
stocks and bonds. *Journal of Financial Economics*, 33(1), 3–56.

Carhart, M. M. (1997). On persistence in mutual fund performance. *The
Journal of Finance*, 52(1), 57–82. (Momentum factor construction.)

Data: Kenneth R. French Data Library,
https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html
