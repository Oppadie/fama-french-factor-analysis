# =============================================================================
# 01_fetch_data.R
# Purpose: Pull equity price data (for portfolio construction) and Fama-French
#          factor data, then merge into a single monthly dataset.
#
# NOTE: Fama-French factors are downloaded directly from Kenneth French's
# data library (as zipped CSVs), NOT via tidyquant's famafrench wrapper,
# which has been unreliable (returns NULL with no error).
# =============================================================================

library(tidyquant)
library(tidyverse)
library(lubridate)

# ---- 1. Settings -----------------------------------------------------------
start_date <- "2000-01-01"
end_date   <- "2024-12-31"

tickers <- c("AAPL", "MSFT", "JNJ", "XOM", "JPM", "PG", "KO", "WMT",
             "DIS", "IBM", "GE", "CAT", "MMM", "VZ", "PFE",
             "HD", "CVX", "BA", "MCD", "NKE")

# ---- 2. Download equity prices ---------------------------------------------
prices <- tq_get(tickers, get = "stock.prices",
                  from = start_date, to = end_date)

monthly_returns <- prices %>%
  group_by(symbol) %>%
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = "monthly",
               col_rename = "ret") %>%
  ungroup() %>%
  mutate(month = floor_date(date, "month"))

write_csv(monthly_returns, "data/monthly_stock_returns.csv")

# ---- 3. Download Fama-French factors directly from source ------------------

# Helper: download a French data library zip, extract the CSV, and parse
# out just the monthly data block (these files have a text preamble and
# an annual-data block after the monthly block, separated by blank lines).
download_french_csv <- function(url, dest_name) {
  tmp_zip <- tempfile(fileext = ".zip")
  tmp_dir <- tempfile()
  dir.create(tmp_dir)

  download.file(url, tmp_zip, mode = "wb", quiet = TRUE)
  unzip(tmp_zip, exdir = tmp_dir)

  csv_file <- list.files(tmp_dir, pattern = "\\.csv$|\\.CSV$", full.names = TRUE)[1]
  lines <- readLines(csv_file)

  # Find the header row: first line whose second field (after a comma)
  # looks like a factor name (non-numeric), following a row of column names
  # Easiest robust approach: find the first line where the FIRST field is
  # exactly 6 digits (YYYYMM) -- that's the first monthly data row -- then
  # back up one line for the header.
  data_start <- which(grepl("^[0-9]{6},", lines))[1]
  header_line <- lines[data_start - 1]

  # Find where the monthly block ends: first blank line after data_start,
  # or a line whose first field is no longer a 6-digit date
  after_start <- lines[data_start:length(lines)]
  end_offset <- which(!grepl("^[0-9]{6},", after_start))[1]
  if (is.na(end_offset)) {
    data_end <- length(lines)
  } else {
    data_end <- data_start + end_offset - 2
  }

  block <- c(header_line, lines[data_start:data_end])
  df <- read_csv(paste(block, collapse = "\n"), show_col_types = FALSE)

  names(df)[1] <- "date"
  df <- df %>%
    mutate(date = ym(date),
           month = floor_date(date, "month")) %>%
    select(-date)

  write_csv(df, dest_name)
  df
}

ff5_url <- "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_5_Factors_2x3_CSV.zip"
umd_url <- "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Momentum_Factor_CSV.zip"

ff5_monthly <- download_french_csv(ff5_url, "data/ff5_raw.csv") %>%
  rename_with(tolower) %>%
  rename(mkt_rf = `mkt-rf`)

umd_monthly <- download_french_csv(umd_url, "data/umd_raw.csv") %>%
  rename_with(tolower)
# The momentum file's column is usually named "Mom" -- rename whatever
# the single non-month column is called to "umd" for consistency.
umd_col <- setdiff(names(umd_monthly), "month")
umd_monthly <- umd_monthly %>% rename(umd = all_of(umd_col))

factors <- ff5_monthly %>%
  left_join(umd_monthly, by = "month")

write_csv(factors, "data/ff_factors.csv")

# ---- 4. Merge stock returns with factors -----------------------------------
# Note: French library values are in percent (e.g. 1.23 = 1.23%), matching
# the scale of `ret` computed from periodReturn (also a decimal like 0.0123
# -- so convert factors to decimal to match).
merged <- monthly_returns %>%
  left_join(factors %>% mutate(across(-month, ~ .x / 100)), by = "month") %>%
  mutate(excess_ret = ret - rf) %>%
  filter(!is.na(excess_ret))

write_csv(merged, "data/merged_dataset.csv")

cat("Done. Rows in merged dataset:", nrow(merged), "\n")
