#install.packages("ggplot2")
install.packages("janitor")

library(readxl)
library(rlang)
library(dplyr)
library(ggplot2)
library(janitor)
library(reshape2)


set.seed(111)
mydf <- data.frame(value_1 = sample.int(n = 1000000, size = 100),
                   value_2 = sample.int(n = 1000000, size = 100),
                   value_3 = sample.int(n = 1000000, size = 100),
                   value_4 = sample.int(n = 1000000, size = 100))

mydf <- t(mydf)
df <- melt(mydf)
df$rowid <- 1:length(mydf)
colnames(df)
head(df)

ggplot(df, aes(Var2, value, group=factor(Var1))) + geom_line(aes(color=factor(Var1)))

#### Implement on real data ####

county.data <- read_excel('./data/county_payer_stats_t12mo.xlsx')

head(county.data)
county.df <- county.data %>%
  filter(State == "AL" & FIPS == "1001") %>%                  # filter based on state and FIPS code
  arrange(desc(!! sym(colnames(county.data)[5]))) %>%  # sort based on last months' values
  select (-c(State, State_FIPS, FIPS))                        # Make sure to drop unnecessary columns

# Take the top 10 
county.df <- head(county.df, 10)
head(county.df)

# Melt dataframes
county.df <- melt(county.df, "Parent_Organization")
county.df$variable <- as.Date( as.numeric (as.character(county.df$variable) ),origin="1899-12-30")
head(county.df)

pct <- function(x) {x/lag(x)}
test <- county.df %>% group_by(Parent_Organization) %>% mutate(lvar = 100*(lag(value) - value)/lag(value))

# Create ggplot2 graph
ggplot(test, aes(variable, lvar, group = Parent_Organization, color = Parent_Organization)) +
  geom_line()

# Create ggplot2 graph
ggplot(county.df, aes(variable, value, group = Parent_Organization, color = Parent_Organization)) +
  geom_line()