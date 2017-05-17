#Import necessary modules
import re
import os
import pandas as pd

#Set working directory
os.chdir('/Users/zacharyescalante/Desktop/Python')

#Open the log file set in our working directory
logs_file = open('test.log', 'rb')

#To test the regular expression, I create a text file with the first n-lines
#from the log file. 
n = 20
testfile = open("test.txt", "w")
for i in range(0, n):
    testfile.write(logs_file.readline())
testfile.close()

#Declare regular expression
#First 'regexM' tests what type of regular expession to run by looking to match
#the type of the data entry as either 'OM' or 'SE' 
regexM = re.compile(r".*?\t(?P<type>\w+)")
#The first regular expession pulls data if 'type' = 'OM'
regexOM = re.compile(r"""(?P<time>.*?\.?\d+)
                        \s
                        (?P<type>\w+)
                        \s\w+:
                        (?P<optionId>\d+)
                        \s\w+:
                        (?P<OrderID>\d+)
                        \s\w+:
                        (?P<OrderEvent>\w+)""", re.X)
#The second regular expession pulls data if 'type' = 'SE'
regexSE = re.compile(r"""(?P<time>.*?\.?\d+)
                        \s
                        (?P<type>\w+)
                        \t\w+:
                        (?P<optionId>\d+)
                        \t\w+:
                        (?P<Symbol>\w+)
                        \t\w+:
                        (?P<Expiry>\d+\-?\d+\-?\d+)
                        \s\w+:
                        (?P<Strike>\d+\.?\d*)
                        \s\w+:
                        (?P<CallPut>\w+)
                        \s\w+:
                        (?P<Side>\w+)
                        \s\w+:
                        (?P<Size>\d+)
                        \s\w+:
                        (?P<Price>\d+\.?\d*)
                        \s\w+:
                        (?P<Exchange>\w+)
                        \s\w+:
                        (?P<MarketSize>\d+)""", re.X)
#When we are testing our regular expression, we first iterate over 'sample'
#sample = open('test.txt', 'r')
#When we have our regular expression complete, we iterate over the full log file
logs_file = open('test.log', 'rb')
logsSE = []
logsOM = []
for line in logs_file:
    #Test to see what type of regex(SE/OM) we should use
    matchesM = regexM.match(line)
    type_ = matchesM.group('type')
    #If we have an 'SE' type, we match the 'regexSE' expression
    if type_ == 'SE':
        matches = regexSE.match(line)
        time_SE = matches.group('time')
        type_SE = matches.group('type')
        optionId_SE = matches.group('optionId')
        expiry_SE = matches.group('Expiry')
        strike_SE = matches.group('Strike')
        callPut_SE = matches.group('CallPut')
        side_SE = matches.group('Side')
        size_SE = matches.group('Size')
        price_SE = matches.group('Price')
        exchange_SE = matches.group('Exchange')
        marketSize_SE = matches.group('MarketSize')
    #If the type is 'OM', we match the 'regexOM' expression
    else:
        matches = regexOM.match(line)
        time_OM = matches.group('time')
        type_OM = matches.group('type')
        optionId_OM = matches.group('optionId')
        orderId_OM = matches.group('OrderID')
        eventType_OM = matches.group('OrderEvent')
        
    #Append the data into the respective lists
    logsSE.append([time_SE, type_SE, optionId_SE, expiry_SE, float(strike_SE),
                callPut_SE, side_SE, int(size_SE), float(price_SE), exchange_SE,
                int(marketSize_SE)])
    logsOM.append([time_OM, type_OM, optionId_OM, int(orderId_OM), eventType_OM])#, type_OM, optionId_OM, orderId_OM, eventType_OM])
#Convert to two dataframes
SE_DF = pd.DataFrame(logsSE, columns=['Time', 'Type', 'Option_ID',
                                    'Expiration', 'Strike', 'CallPut',
                                    'Side', 'Size', 'Price', 'Exchange',
                                    'MarketSize'])
OM_DF = pd.DataFrame(logsOM, columns = ['Time', 'Type', 'Option_ID', 'Order_ID',
                                        'Event_Type'])
#Output to CSV files in the working directory
SE_DF.to_csv('SE_Orders.csv')
OM_DF.to_csv('OM_Orders.csv')

#This code prints 'test.txt' to help visualive what data we need to pull
sample = open('test.txt', 'r')   
for line in sample:
    print line
    

