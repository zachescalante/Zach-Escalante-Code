#install.packages("ggplot2")

library(dplyr)
library(ggplot2)
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

county.data <- read.csv('county_payer_stats_t12mo.csv', header=TRUE, sep = ",")

county.df <- county.data %>%
  filter(State == "AL" & FIPS.State.County.Code == "1001") %>% # filter based on state and FIPS code
  arrange(desc(Sep.19)) %>%                                    # sort based on last months' values
  select (-c(X, State, FIPS.State.County.Code))                # Make sure to drop unnecessary columns

# Take the top 10 
county.df <- head(county.df, 10)

# Create ggplot2 graph
county.df <- melt(county.df, "Parent.Organization")
ggplot(county.df, aes(variable, value, group = Parent.Organization, color = Parent.Organization)) +
  geom_line()