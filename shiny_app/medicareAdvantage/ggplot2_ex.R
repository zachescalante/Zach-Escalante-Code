#install.packages("ggplot2")

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