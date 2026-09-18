# =============================================================================
# 04_plots.R
# Purpose: Generate the two key plots for the write-up:
#          (1) Cumulative factor returns over the sample period
#          (2) Rolling 60-month alpha of the universe portfolio
# =============================================================================

library(tidyverse)
library(scales)

factors <- read_csv("data/ff_factors.csv", show_col_types = FALSE)
rolling_fits <- read_csv("output/rolling_window_alpha.csv", show_col_types = FALSE)

# ---- Plot 1: Cumulative factor returns --------------------------------------
factors_cum <- factors %>%
  arrange(month) %>%
  mutate(across(c(mkt_rf, smb, hml, umd), ~ cumprod(1 + .x / 100) - 1)) %>%
  pivot_longer(cols = c(mkt_rf, smb, hml, umd),
               names_to = "factor", values_to = "cum_return")

p1 <- ggplot(factors_cum, aes(x = month, y = cum_return, color = factor)) +
  geom_line(linewidth = 0.8) +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "Cumulative Factor Returns",
       x = NULL, y = "Cumulative Return", color = "Factor") +
  theme_minimal(base_size = 13)

ggsave("output/cumulative_factor_returns.png", p1, width = 8, height = 5, dpi = 150)

# ---- Plot 2: Rolling alpha ----------------------------------------------------
p2 <- ggplot(rolling_fits, aes(x = window_end, y = alpha)) +
  geom_line(color = "#2C3E50", linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  labs(title = "Rolling 60-Month FF3 Alpha (Universe Portfolio)",
       x = NULL, y = "Monthly Alpha") +
  theme_minimal(base_size = 13)

ggsave("output/rolling_alpha.png", p2, width = 8, height = 5, dpi = 150)

cat("Plots saved to output/\n")
