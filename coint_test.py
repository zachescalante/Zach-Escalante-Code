import pandas as pd
import statsmodels.tsa.stattools as ts

df = pd.read_excel('data.xlsx', index_col='Dates')
df['GTII10'] = df['GTII10']*-1

date_1, date_2 = '2016-01-01', '2017-01-01'
df_filtered = df.loc[date_1:date_2]

print(ts.coint(df_filtered['GTII10'], df_filtered['GOLDS'])[1])
