# =============================================================================
# 03_rolling_window.R
# Purpose: Robustness / extension analysis.
#          (a) Split sample pre- vs post-2020 and compare FF3 fit.
#          (b) Rolling 60-month window regression to show time-varying alpha
#              and R^2 for the market-cap-weighted "universe portfolio".
# =============================================================================

library(tidyverse)
library(broom)
library(slider)   # for rolling regressions
library(lubridate)

merged <- read_csv("data/merged_dataset.csv", show_col_types = FALSE)

# ---- (a) Pre/post 2020 split -------------------------------------------------
split_results <- merged %>%
  mutate(period = if_else(month < as.Date("2020-01-01"), "pre_2020", "post_2020")) %>%
  group_by(symbol, period) %>%
  group_modify(~{
    fit <- lm(excess_ret ~ mkt_rf + smb + hml, data = .x)
    broom::glance(fit) %>% select(r.squared, adj.r.squared)
  }) %>%
  ungroup()

write_csv(split_results, "output/pre_post_2020_comparison.csv")

# ---- (b) Build an equal-weighted "universe portfolio" -----------------------
universe_portfolio <- merged %>%
  group_by(month) %>%
  summarise(
    excess_ret = mean(excess_ret, na.rm = TRUE),
    mkt_rf   = first(mkt_rf),
    smb        = first(smb),
    hml        = first(hml)
  ) %>%
  arrange(month)

# ---- Rolling 60-month FF3 regression on the universe portfolio --------------
roll_width <- 60

rolling_fits <- slide_period_dfr(
  .x = universe_portfolio,
  .i = universe_portfolio$month,
  .period = "month",
  .f = function(window_df) {
    if (nrow(window_df) < roll_width) return(NULL)
    fit <- lm(excess_ret ~ mkt_rf + smb + hml, data = window_df)
    tidy_fit <- broom::tidy(fit)
    alpha_row <- tidy_fit %>% filter(term == "(Intercept)")
    tibble(
      window_end  = max(window_df$month),
      alpha       = alpha_row$estimate,
      alpha_tstat = alpha_row$statistic,
      r_squared   = summary(fit)$r.squared
    )
  },
  .before = roll_width - 1,
  .complete = TRUE
)

write_csv(rolling_fits, "output/rolling_window_alpha.csv")

cat("Robustness analysis complete.\n")
cat("Pre/post 2020 comparison saved to output/pre_post_2020_comparison.csv\n")
cat("Rolling window alpha saved to output/rolling_window_alpha.csv\n")
