require("RPostgreSQL")
require("tidyverse")
require("stringr")
require("dplyr")
require("ggplot2")
require("lubridate")
require("modelr")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "progetto_basi",
                 host = "localhost", port = 5432,
                 user = "postgres", password = "postgres")