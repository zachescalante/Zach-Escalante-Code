#Import necessary modules
import re
import os
import numpy as np
import pandas as pd
import datetime
import time
import calendar
import seaborn as sns
import seaborn.linearmodels 
from datetime import date
from datetime import datetime
from collections import Counter
from collections import defaultdict
import matplotlib.pyplot as plt
import matplotlib.cm as cm

#Set working directory
os.chdir('/Users/zacharyescalante/Desktop/RedOwl/RedOwl-Data-Science-Recruiting-Exam')

#################################PART 1####################################

#Import the enron.csv file with headers
enron = pd.read_csv("enron.csv", 
                  names = ["Time", "Identifier", "Sender", "Receivers", "None", "Email"])
enron.head()
#Count the senders using a defaultdict
senders = defaultdict(int)
for names in enron["Sender"]:
    senders[names] += 1
senders

#Convert to a dataframe
senders_df = pd.DataFrame.from_dict(senders, orient = 'index')
list(senders_df.columns.values)
#Change the column header name
senders_df.columns = ['Total']
senders_df

#Order the results in descending order
result_send = senders_df.sort_values(['Total'], ascending=[False])
#Final sorted dataframe of 'senders'
result_send

#Now work on the receivers part of the dataset by separating all the email addresses
receivers = enron["Receivers"].str.split('|')
#Exchange 'nan' with a string 'blank'
receivers_update = receivers.replace(np.nan,'blank', regex=True)

#Declare a dictionary using defaultdict that will add a new key if one is 
#not already present, and increment a key its already there
receivers = defaultdict(int)
for emails in receivers_update:
    for name in emails:
        receivers[name] += 1

receivers

#Create a dataframe from our dictionary that can be sorted
receivers_df = pd.DataFrame.from_dict(receivers, orient = 'index')
list(receivers_df.columns.values)
receivers_df.columns = ['Total']
receivers_df

#Sort the values in descending order
result_rec = receivers_df.sort_values(['Total'], ascending=[False])
result_rec
result_send

#Now we will use a full join on these two separate dataframes to give us the 
#final dataframe which can answer the first question
result_final = result_send.join(result_rec, how='outer', lsuffix='Sent', rsuffix='Received')
result_final.index[0]

result_final.to_csv('results.csv')

#################################PART 2####################################
#My thought is to plot the emails of the most prolific users by number of 
#emails sent per day. To do this, I first need to convert milliseconds to 
#seconds and then convert unix time to a date
datetime.fromtimestamp(enron["Time"][0]/1000).strftime('%Y-%m-%d %H:%M:%S')

def date_converter(x):
    date_object = datetime.fromtimestamp(x/1000).strftime('%Y-%m-%d')
    return date_object 

enron['time'] = enron['Time'].apply(lambda x: date_converter(x))
enron.head()

#Order the enron dataframe by date
enron.sort_values(['time'], ascending=[True])
enron.head()

#I create a dataframe to house the top 10 senders, from 
#which I'll create a Time Series graph. Choosing 10 is somewhat arbitrary,
#I could add more or less for analysis as need be. 

dict_ = {}
for i in range(0, 9):
    dict_[result_final.index[i]]= enron["Sender"][enron["Sender"]==result_final.index[i]].groupby(enron['time']).count()
ts = pd.DataFrame.from_dict(dict_)

#Graph the TS
#Could plot all the columns on one graph with this code, except that it 
#would recycle identical colors
#plt.figure(); ts.plot(); plt.legend(loc='best'); plt

#Instead I create a color palette here
N = len(ts.columns)
x = np.arange(N)
ys = [i+x+(i*x)**2 for i in range(N)]
colors = cm.rainbow(np.linspace(0, 1, len(ys)))

#And graph the time series with the unique colors here
for i in range(0, len(ts.columns)):
    ts.iloc[:,i].plot(color = colors[i])
plt.legend(loc='best')
plt.suptitle('Top Senders')
plt.show()

#Output the graph to a .png file and save in current directory
plt.savefig('time_series.png')

####################################Part 3#################################
#I start with adjusting the actual data frame 'enron' so that I can access
#each name in the 'Receivers' column. I could have done this to start but 
#I didn't want to adjust the raw dataframe. At this point it just seems 
#easiest however to adjust 'enron'
enron = enron.set_index("time")
enron
enron["Receivers"] = enron["Receivers"].str.split('|')
enron["Receivers"] = enron["Receivers"].replace(np.nan,'blank', regex=True)

#This function will tell me if the desired name is in the 'Receivers' column
def inObject(x, y):
    if x in y:
        return True
    else: 
        return False
#Test on a specific cell
inObject('mary hain', enron.iloc[1,3])

#Create a list of the ten names we used for our TS analysis
names = (ts.columns.values.tolist())
len(names)

#I'm creating a dictionary of a filterd dataframe where each dataframe is 
#filtered such that one of our names is in the 'Receiver column'
diction = {}
for name in names:
    diction[name] = enron[enron['Receivers'].apply(lambda x: inObject(name, x))]

diction

#I filter diction by the name[0] key and group by the index which is now
#the date. I then calculate the number of unique senders with this piece of code:
#['Sender'].nunique(), and convert th series to a pandas dataframe
ts_receive = diction[names[0]].groupby(diction[names[0]].index)['Sender'].nunique().to_frame(name=names[0])

#I now update 'ts_receive' to be a full outer join with every other data frame
#that was stored in 'diction'
for i in range(1,9):
    ts_receive = ts_receive.join(diction[names[i]].groupby(diction[names[i]].index)['Sender'].nunique().to_frame(name=names[i]), how = 'outer')

ts_receive

#Output a time series graph of unique senders to these recipients over time
for i in range(0, len(ts_receive.columns)-1):
    ts_receive.iloc[:,i].plot(color = colors[i])
plt.legend(loc='best')
plt.suptitle('Unique Senders To These Recipients (Weekly)')
plt.show()
plt.savefig('Unique Senders To These Recipients (Weekly)')

#ts_receive is a clean dataframe, so I declare another one that I will use
#to calculate the sum of unique senders to each of the 10 email recipients
ts_receive_sum = ts_receive

ts_receive_sum
#Add a column that is the sum of each row
ts_receive_sum['Total'] = ts_receive.sum(axis=1)

############################Correlation Matrix#############################
fig = plt.figure(figsize=(15,15))
seaborn.linearmodels .corrplot(ts_receive_sum)
plt.title("Correlation Matrix Visualization",fontsize=18)
plt.savefig('Correlation Matrix.png')

###########################Observations & Insights#########################
#Observation 1:
#Pete Davis has nan values. I looked into the data and saw 
#that on only 45 days did Pete Davis receive emails, and they were from
#only one account - hence the sd of his unique senders was 0 - unable to compute.
#Perhaps his job included sending standard reports and hence he never 
#received many emails, but he was a top sender. I'm content not to explore this 
#further.
ts_receive_sum['pete davis'].sum()
len(ts_receive_sum['pete davis'])
#The max - min = 0, so it's the same value
ts_receive_sum['pete davis'].max() - ts_receive_sum['pete davis'].min()
#The value is 1.0
ts_receive_sum['pete davis'].max() 

#Observation 2:
#Sarah Shackleton is most highly correlated with that total for these ten
#individuals. This is not surprising since she was in the top 5 for both
#inbound and outbound emails

#Observation 3:
#The email account 'notes' and Vince Kaminski were the only strong negative
#correlation. This implies that when peopl were sending Vince emails, they 
#were not sending them to the 'notes' account and vice versa. If we look
#at the TS graph of unique senders, we see that the emails to vince taper off
#as the amount to notes increases. Perhaps a task that Vince was once accountable
#for was replaced with 'notes' account.

#Observation 4:
#Matt Lenhart is also negatively correlated with Vince Kaminski and also 
#positively correlated with the 'notes' account. Perhaps he took over some
#of the responsibilities that belonged to Vince. 

#My initial thought looking at the Correlation Matrix was that Vince Kaminski
#may have left Enron and his responsibiliites were split between Matt Lenhart
#and whoever was on the other end of the 'notes' account. However if we look
#at the TS graph of unique senders, we see that Vince receives a smaller 
#number of emails through the end of the time period. As a result I believe
#that Vince was promoted, Matt stepped into his role. 


#"being confident of this very thing, that He who has begun a good work in 
#you will complete it until the day of Jesus Christ;" Phil. 1:6