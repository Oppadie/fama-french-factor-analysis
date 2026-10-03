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
on average, doing a reasonable job pricing this universe. The one
exception is **AAPL**, which shows a significant positive alpha in all
three models (CAPM: t = 3.02, p = 0.003; FF3: t = 3.43, p < 0.001; FF3+UMD:
t = 3.41, p < 0.001), with an estimated FF3 alpha of about **1.8% per
month** — a large, persistent, and statistically robust abnormal return
that none of the factors (including momentum) explain away.

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
equal-weighted universe portfolio tells a more structured story than a
simple fluctuation around zero:

- **2005–2012: a long, strong climb to a clear peak.** Alpha rises from
  roughly 0.004–0.005 in the mid-2000s to a sample maximum of **0.0088
  (0.88% per month) for the window ending January 2012** (t = 5.71, highly
  significant). Because each point reflects the trailing 5 years, this
  window is dominated by the 2008 financial crisis and the sharp 2009–2011
  recovery — a period in which this portfolio earned real excess return
  beyond what the FF3 factors explain.
- **2012–2017: a steady decay back to zero.** Alpha falls almost
  continuously as the crisis/recovery period rolls out of the trailing
  window, reaching essentially zero (0.0001, t = 0.10) by January 2017.
- **2017–2023: small, mostly positive fluctuations.** Alpha oscillates in a
  narrow band, with local upticks around 2019–2020 and 2022–2023 (reaching
  about 0.0017 by January 2023), but never regains statistical
  significance.
- **2023–2024: a sharp decline into negative territory.** Alpha falls
  below zero for the first time in the sample, bottoming at **−0.0014**
  (window ending June 2024) and ending at −0.0011 by December 2024 — the
  COVID-era and subsequent return data have now fully entered, and begun
  to dominate, the trailing 5-year window.

**Interpretation:** this portfolio earned a large, statistically
significant positive alpha for most of the 2008–2013 window — likely
reflecting crisis-era mispricing and an unusually strong recovery — which
has since fully decayed and, most recently, turned slightly negative. This
is a more notable finding than "no persistent mispricing": it suggests
abnormal performance was real and economically large in one specific era,
not a constant feature of the portfolio.

### 4.4 Cumulative factor returns

See `output/cumulative_factor_returns.png`. **Note:** this plot uses the
full history available from Kenneth French's data library (extending well
before 2000), not just the 2000–2024 regression sample — it's included for
long-run context on each factor's behavior, not as a regression input. Two
things stand out:

- **Momentum (UMD) dwarfs the other factors in cumulative terms**,
  compounding to roughly 6,000–7,000% at its peak versus a few hundred to
  ~4,000% for the market, value, and size factors. This reflects momentum's
  historically high long-run average return, but that figure is driven by
  compounding over many decades and is not representative of a single
  investable strategy's realistic returns.
- **A sharp, visible drawdown in UMD around 2008–2009** (the cumulative
  line drops substantially before recovering) — this is the well-documented
  "momentum crash," a known structural break where momentum strategies
  suffer large, sudden losses during sharp market reversals. This is the
  exact risk flagged as a limitation in Section 6, visible directly in the
  data here.

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
- Momentum's known structural breaks (e.g. the 2009 "momentum crash",
  visible in Section 4.4's cumulative return plot) are not explicitly
  modeled; the UMD factor is used as-is in the regressions.
- The rolling-window alpha's 2008–2013 peak overlaps with the global
  financial crisis and its recovery — a single unusual historical episode
  that should not be read as a repeatable or exploitable strategy.

## 7. References

Fama, E. F., & French, K. R. (1993). Common risk factors in the returns on
stocks and bonds. *Journal of Financial Economics*, 33(1), 3–56.

Carhart, M. M. (1997). On persistence in mutual fund performance. *The
Journal of Finance*, 52(1), 57–82. (Momentum factor construction.)

Data: Kenneth R. French Data Library,
https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html
