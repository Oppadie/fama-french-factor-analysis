# =============================================================================
# 02_run_regressions.R
# Purpose: Run time-series factor regressions per stock:
#          - CAPM (1-factor)
#          - Fama-French 3-factor
#          - 3-factor + Momentum (4-factor)
#          Summarize alphas, t-stats, and R^2 across the universe.
# =============================================================================

library(tidyverse)
library(broom)

merged <- read_csv("data/merged_dataset.csv", show_col_types = FALSE)

# ---- Helper: run one model spec for one stock -------------------------------
run_model <- function(df, formula) {
  fit <- lm(formula, data = df)
  glance_fit <- broom::glance(fit)
  tidy_fit   <- broom::tidy(fit)

  alpha_row <- tidy_fit %>% filter(term == "(Intercept)")

  tibble(
    alpha       = alpha_row$estimate,
    alpha_tstat = alpha_row$statistic,
    alpha_pval  = alpha_row$p.value,
    r_squared   = glance_fit$r.squared,
    adj_r_squared = glance_fit$adj.r.squared
  )
}

# ---- Run each model spec across all stocks ----------------------------------
results <- merged %>%
  group_by(symbol) %>%
  group_modify(~{
    capm  <- run_model(.x, excess_ret ~ mkt_rf) %>% mutate(model = "CAPM")
    ff3   <- run_model(.x, excess_ret ~ mkt_rf + smb + hml) %>% mutate(model = "FF3")
    ff3_umd <- run_model(.x, excess_ret ~ mkt_rf + smb + hml + umd) %>% mutate(model = "FF3+UMD")
    bind_rows(capm, ff3, ff3_umd)
  }) %>%
  ungroup()

write_csv(results, "output/regression_results.csv")

# ---- Summary across the universe --------------------------------------------
summary_table <- results %>%
  group_by(model) %>%
  summarise(
    mean_alpha        = mean(alpha, na.rm = TRUE),
    pct_significant_alpha = mean(abs(alpha_tstat) > 1.96, na.rm = TRUE),
    mean_r_squared     = mean(r_squared, na.rm = TRUE),
    mean_adj_r_squared = mean(adj_r_squared, na.rm = TRUE)
  )

write_csv(summary_table, "output/model_summary.csv")

print(summary_table)
