#Import necessary modules
import re
import os
import pandas as pd
import datetime
import time
import calendar
from datetime import date
from datetime import datetime

#Set working directory
os.chdir('/Users/zacharyescalante/Desktop/Python/electricity')

########################################################################
#We will use these formulas throughout this exercise:
def month_string_to_number(string):
    m = {
        'jan': 1,
        'feb': 2,
        'mar': 3,
        'apr':4,
         'may':5,
         'jun':6,
         'jul':7,
         'aug':8,
         'sep':9,
         'oct':10,
         'nov':11,
         'dec':12
        }
    s = string.strip()[:3].lower()

    try:
        out = m[s]
        return out
    except:
        raise ValueError('Not a month')

def string_to_date(x):
    date_object = datetime.strptime(x, '%b %d %Y %I:%M %p')
    return date_object       

def dayOfWeek(num):
    list_ = ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
    return list_[num]
      
#########################################################################

#Open the csv file set in our working directory
usage = pd.read_csv("usage-table.csv", header = None)

usage.head

usage.drop(usage.columns[1:len(usage.columns)], axis=1, inplace=True)
usage[0] = usage[0].str.strip().str.replace(' ', '_')
usage[0]

#Declare our Regular Expression to extract the information
regex = re.compile(r"""(?P<hour>\d+)
                        \D*
                        (?P<AMPM>(AM|PM))
                        \D*
                        (?P<day>\d+)
                        \w*-
                        (?P<month>\w+)
                        -
                        (?P<year>\d+)
                        _+
                        (?P<kwh>\d+\.?\d*)
                        """, re.X)
usage_data = usage[0].str.extract(regex)
usage_data

#I get two columns with the 'AM/PM' value, so I drop one. If you see how to
#fix this in regex, please let me know!
usage_data = usage_data.drop([2], axis = 1) 

#Convert the new numeric month to a string so that all columns are strings
#This should make useing the datetime function easier
usage_data['month'] = usage_data.month.map(str)
type(usage_data.month[0])
#add a column that is a string of the time/date
usage_data['time'] = usage_data.month + " " + usage_data.day + ' ' + usage_data.year\
                        + ' ' + usage_data.hour + ':00 ' + usage_data['AMPM'] 
usage_data
#use apply+lambda to implement with a function to strptime function to convert
#each 'time' value to a datetime object
usage_data['time'] = usage_data['time'].apply(lambda x: string_to_date(x))

usage_data
#convert 'kwh' to float
usage_data['kwh'] = usage_data['kwh'].astype(float)

usage_data.dtypes

usage_data['weekday'] = usage_data['time'].dt.dayofweek
usage_data['weekday'] = map(dayOfWeek, usage_data['weekday'])

#Check the dataframe. We are now ready to begin answering the questions
usage_data

##########################################################################

#Question 1: 
#What is your average hourly electricity usage?
#To answer, let's calculate the total usage/total hours
sum(usage_data['kwh'])/len(usage_data)

##########################################################################
#Question 2
#What is your average electricity usage per hour in February?
numFeb = len(usage_data[(usage_data['month'] == 'Feb')]) 
hrsFeb = sum(usage_data['kwh'][usage_data['month'] == 'Feb'])
hrsFeb/numFeb

##########################################################################
#Question 3
#Which day of the week has the highest average usage?
days = set(usage_data['weekday'])
dict_ = {}
for day in days:
    dict_[day] = {'Day': sum((usage_data['kwh'][usage_data['weekday'] == day]))/len(usage_data['weekday']==day)}
days = pd.DataFrame.from_dict(dict_, orient = 'index')
days

##########################################################################
#Question 4
#What is the highest amount of electricity used in a continuous 4 hour period?
usage_data = usage_data.sort('time')
usage_data = usage_data.set_index(usage_data['time'])
usage_data
dict_ = {}
for i in range(3, len(usage_data)):
    dict_[usage_data.time[i]] = {'Usage': (usage_data.kwh[i] +\
                                                usage_data.kwh[i-1] +\
                                                usage_data.kwh[i-2] +\
                                                usage_data.kwh[i-3])}
df = pd.DataFrame.from_dict(dict_, orient = 'index')
df['Usage'].max()

##########################################################################
#Question 5
#Based on your historic electricity usage, what would your annual cost 
#of electricity be under the "Monthly Flex" contract?
#First I'll create a function to add the cost per month for each hour
#January	0.2	$/kWh
#February	0.19	$/kWh
#March	0.17	$/kWh
#April	0.18	$/kWh
#May	0.22	$/kWh
#June	0.27	$/kWh
#July	0.24	$/kWh
#August	0.19	$/kWh
#September	0.18	$/kWh
#October	0.15	$/kWh
#November	0.14	$/kWh
#December	0.19	$/kWh

def costMonth(month):
    cost = 0
    if month == 'Jan':
        cost += 0.2
    elif month == 'Feb':
        cost += 0.19
    elif month == 'Mar':
        cost += 0.17
    elif month == 'Apr':
        cost += 0.18
    elif month == 'May':
        cost += 0.22
    elif month == 'Jun':
        cost += 0.27
    elif month == 'Jul':
        cost += 0.24
    elif month == 'Aug':
        cost += 0.19
    elif month == 'Sep':
        cost += 0.18
    elif month == 'Oct':
        cost += 0.15
    elif month == 'Nov':
        cost += 0.14
    else:
        cost += 0.19
    return cost
    
usage_data['costMonth'] = usage_data['month'].apply(lambda x: costMonth(x))
#Sum the costMonth * kwh
sum(usage_data['costMonth']*usage_data['kwh'])

##########################################################################
#Question 6
#Based on your historic electricity usage, what would your annual cost of 
#electricity be under the "Hourly Flex" contract?
#First I'm going to add a column that is hour + AM/PM
usage_data['hour24'] = usage_data.hour + " " + usage_data['AMPM'] 
unique_hrs = set(usage_data['hour24'])

#Next I'll write a function to add the price/hour for each hour 
# in our dataframe. This is the pricing scheduel for quick reference

#12AM until 1AM	0.1	$/kWh
#1AM until 2AM	0.1	$/kWh
#2AM until 3AM	0.1	$/kWh
#3AM until 4AM	0.1	$/kWh
#4AM until 5AM	0.15	$/kWh
#5AM until 6AM	0.2	$/kWh
#6AM until 7AM	0.24	$/kWh
#7AM until 8AM	0.24	$/kWh
#8AM until 9AM	0.26	$/kWh
#9AM until 10AM	0.2	$/kWh
#10AM until 11AM	0.2	$/kWh
#11AM until 12PM	0.26	$/kWh
#12PM until 1PM	0.26	$/kWh
#1PM until 2PM	0.2	$/kWh
#2PM until 3PM	0.24	$/kWh
#3PM until 4PM	0.18	$/kWh
#4PM until 5PM	0.15	$/kWh
#5PM until 6PM	0.3	$/kWh
#6PM until 7PM	0.24	$/kWh
#7PM until 8PM	0.24	$/kWh
#8PM until 9PM	0.12	$/kWh
#9PM until 10PM	0.11	$/kWh
#10PM until 11PM	0.1	$/kWh
#11PM until 12AM	0.1	$/kWh

ten = ['12 AM', '1 AM', '2 AM', '3 AM', '10 PM', '11 PM']
fifteen = ['4 AM', '4 PM']
twenty = ['5 AM', '9 AM', '10 AM', '1 PM']
twentyFour = ['6 AM', '7 AM', '2 PM', '6 PM','7 PM']
twentySix = ['8 AM','11 AM', '12 PM']
eighteen = ['3 PM']
thirty = ['5 PM']
twelve = ['8 PM']
eleven = ['9 PM']
def costHour(hour):
    cost = 0
    if hour in ten:
        cost += 0.1
    elif hour in fifteen:
        cost += 0.15
    elif hour in twenty:
        cost += 0.2
    elif hour in twentyFour:
        cost += 0.24
    elif hour in twentySix:
        cost += 0.26
    elif hour in eighteen:
        cost += 0.18
    elif hour in thirty:
        cost += 0.3
    elif hour in twelve:
        cost += 0.12
    else:
        cost += 0.11
    return cost

#Apply the formula across all hours and add a column with the values    
usage_data['costHour'] = usage_data['hour24'].apply(lambda x: costHour(x))
#Sum the costHour * kwh
sum(usage_data['costHour']*usage_data['kwh'])
 
##########################################################################       
#Question 7
#Based on your historic electricity usage, which of the three contracts 
#would produce the lowest annual cost?
#The only thing we have left to do is count the annual cost:
sum(0.21*usage_data['kwh'])   

#The cheapest alternative is the Hourly Flex plan! 

##########################################################################















