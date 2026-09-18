# Does the Fama-French 3-Factor Model Still Hold Up? A Rolling-Window Test with Momentum

**Research question:** Does the Fama-French 3-factor model's explanatory power for
US equity returns hold steady over time, or has it weakened in the post-2020
period once momentum is added as a fourth factor?

## Key finding
Across a 20-stock large-cap US universe (2000–2024), adding size and value
factors to CAPM meaningfully improves explanatory power: mean R² rises from
0.278 (CAPM) to 0.342 (FF3), with momentum adding only a modest further gain
(0.349). Contrary to the initial hypothesis that factor models might explain
returns *less* well after 2020, the opposite held: 16 of 20 stocks show
**higher** FF3 R² in the post-2020 period than pre-2020, several nearly
doubling (e.g. AAPL: 0.34 → 0.66; PG: 0.07 → 0.37). This is consistent with
elevated market-wide co-movement during 2020–2024 (COVID crash, 2022
rate-hike selloff, subsequent recovery) rather than a breakdown of the
factor model.

## Method
1. **Data**: Monthly returns for 20 large-cap US stocks (2000–2024) plus
   Fama-French 5-factor and momentum data from Kenneth French's data library.
2. **Core test**: Time-series regressions of excess stock returns on CAPM,
   FF3, and FF3+Momentum, per stock.
3. **Robustness**: (a) pre-/post-2020 subsample comparison, (b) rolling
   60-month regression on an equal-weighted universe portfolio to show
   time-varying alpha.

## Repo structure
```
R/
  01_fetch_data.R        # download and merge stock + factor data
  02_run_regressions.R   # CAPM / FF3 / FF3+UMD regressions per stock
  03_rolling_window.R    # pre/post-2020 split + rolling-window alpha
  04_plots.R              # generates the two figures below
data/                     # raw + merged data (generated, not committed if large)
output/                   # regression results, summary tables, plots
docs/                     # write-up (PDF or Rmd/Quarto)
```

## Reproducing
```r
# Install dependencies
install.packages(c("tidyquant", "tidyverse", "lubridate", "broom", "slider", "scales"))

# Run in order
source("R/01_fetch_data.R")
source("R/02_run_regressions.R")
source("R/03_rolling_window.R")
source("R/04_plots.R")
```

## Results
See `output/model_summary.csv` for the headline comparison across CAPM, FF3,
and FF3+Momentum, and `output/rolling_alpha.png` for the time-varying alpha
plot. Full discussion in `docs/writeup.pdf`.

## Limitations
- Universe is 20 liquid large-cap stocks, not the full market — results are
  illustrative, not a claim about market-wide efficiency.
- Momentum factor (UMD) is known to have structural breaks (e.g. the 2009
  "momentum crash"), which should be kept in mind when interpreting the
  post-2020 comparison.

## Author
Agyei Padmond Kofi— undergraduate project, submitted as part of a research
portfolio.
