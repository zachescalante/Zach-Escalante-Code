import io
import os
import boto3
import json
import sqlite3
import pandas as pd
import numpy as np

###############################################################################
#Set working directory and check for contents
os.chdir('/Users/zacharyescalante/Documents/data/fnma')  #Set the working directory 
cwd = os.getcwd()  #Get the current working directory (cwd)
files = os.listdir(cwd)  #Get all the files in that directory
print("Files in '%s': %s" % (cwd, files))  #print the files in that directory

###############################################################################
#Connect to the right database
fnma = 'fnma.db'
conn = sqlite3.connect(fnma)
c = conn.cursor()

###############################################################################
#Declare headers
headers = ['RecordType', 'PoolNumber', 'LoanCorrectionIndicator', 'LoanIdentifier', 
           'Channel', 'SellerName', 'ServicerName', 'OriginalInterestRate', 
           'CurrentInterestRate', 'CurrentNetInterestRate', 'OUPB', 'CUPB',
           'OriginalLoanTerm', 'FirstPaymentDate', 'LoanAge', 'RemainingMTM',
           'MaturityDate', 'LTV', 'CLTV', 'NumberofBorrowers', 'DTI', 'CreditScore',
           'FirstTimeHomeBuyerIndicator', 'LoanPurpose', 'PropertyType', 'NumberofUnits',
           'OccupancyStatus', 'State', 'MortgageInsurancePercentage', 'ProductType',
           'PrepaymentPremiumTerm', 'InterestOnlyIndicator', 'FirstPrincipalandInterestPmtDate',
           'MonthstoFirstScheduledAmortization', 'ConvertibilityIndicator', 'MortgageMargin',
           'NetMortgageMargin', 'Index', 'InterestRateLookBack', 'MaxInterestRate', 
           'NetMaximumInterestRate', 'MonthstoNextRateChange', 'NextRateChangeDate', 
           'RateAdjustmentFrequency', 'InitialFixedRatePeriod', 'InitialRateCapUpPercent',
           'InitialRateCapDownPercent', 'PeriodicCapUpPercent', 'PeriodicCapDownPercent',
           'DaysDelinquent', 'LoanPerformanceHistory', 'LoanAgeasModification', 'ModificationProgram', 
           'ModificationType','NumberofModifications', 'TotalCapitalizedAmount', 'OriginalMortgageLoanUPB', 'Filler', 
           'CurrentDeferredUPB', 'InterestRateStepIndicator', 'InitialStepFixedRatePeriod', 
           'TotalNumberofSteps', 'NumberofRemainingSteps', 'NextStepRate', 'TerminalStepRate',
           'DateofTerminalStep', 'StepRateAdjustmentFrequency', 'MonthstoNextStepRateChange',
           'NextStepRateChangeDate', 'PeriodicStepCapUpPercent', 'OriginationChannel', 'OriginationInterestRate',
           'OriginationUPB', 'OriginationLoanTerm', 'OriginationFirstPaymentDate',
           'OriginationMaturityDate', 'OrginationLTV', 'OriginationCLTV', 
           'OriginationDTI', 'OriginationCreditScore', 'OriginationLoanPurpose', 'OriginationOccupancyStatus',
           'OriginationProductType', 'OriginationIOIndicator']

###############################################################################
#Pull data from S3 bucket
def get_s3_keys(bucket):
    """Get a list of keys in an S3 bucket."""
    keys = []
    resp = s3.list_objects_v2(Bucket=bucket)
    for obj in resp['Contents']:
        keys.append(obj['Key'])
    return keys

s3 = boto3.client('s3')

get_s3_keys('fnma')

result = s3.list_objects(Bucket='fnma', Prefix='february/', Delimiter='/')
###############################################################################
#Input data into pandas dataframe and then push to SQL database


df = pd.DataFrame([])
for key in result['Contents'][1:2]:
    print(key['Key'])
    obj = s3.get_object(Bucket = 'fnma-test-data', Key = key['Key'])
    df = df.append(pd.read_csv(io.BytesIO(obj['Body'].read()), sep = "|", header = None))
df.columns = headers
#    obj = s3.get_object(Bucket = 'fnma-test-data', Key = key['Key'])
#    df = df.append(pd.read_csv(io.BytesIO(obj['Body'].read()), sep = "|", header = None))


# Edits for FNMA data set
# Replace blank strings with 'None', trim whitespace, and cast as categorical variable
#df['Channel'] = df['Channel'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
# Replace blank strings with a null-style date (01/1900), convert all strings to datetime object
#df['FirstPaymentDate'] = pd.to_datetime(df['FirstPaymentDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
# Convert LTV to percent
#df['LTV'] = pd.to_numeric(df['LTV'], errors='coerce') / 100
# Categorical variable, 'YES', 'NO', '   ' gets replaced with 'NONE'
#df['FirstTimeHomeBuyerIndicator'] = df['FirstTimeHomeBuyerIndicator'].str.strip().replace(r'', 'NONE', regex=True).astype('category')

######################################################################################################################################
df['LoanCorrectionIndicator'] = df['LoanCorrectionIndicator'].replace(r'\s+', 0, regex=True).astype('category')
df['Channel'] = df['Channel'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['SellerName'] = df['SellerName'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['ServicerName'] = df['ServicerName'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['OriginalInterestRate'] = pd.to_numeric(df['OriginalInterestRate'], errors='coerce')
df['CurrentInterestRate'] = pd.to_numeric(df['CurrentInterestRate'], errors='coerce')
df['CurrentNetInterestRate'] = pd.to_numeric(df['CurrentNetInterestRate'], errors='coerce')
df['OUPB'] = pd.to_numeric(df['OUPB'], errors='coerce')
df['CUPB'] = pd.to_numeric(df['CUPB'], errors='coerce')
df['OriginalLoanTerm'] = pd.to_numeric(df['OriginalLoanTerm'], errors='coerce')
df['FirstPaymentDate'] = pd.to_datetime(df['FirstPaymentDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['LoanAge'] = pd.to_numeric(df['LoanAge'], errors='coerce')
df['RemainingMTM'] = pd.to_numeric(df['RemainingMTM'], errors='coerce')
df['MaturityDate'] = pd.to_datetime(df['MaturityDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['LTV'] = pd.to_numeric(df['LTV'], errors='coerce') / 100
df['CLTV'] = pd.to_numeric(df['CLTV'], errors='coerce') / 100
df['NumberofBorrowers'] = pd.to_numeric(df['NumberofBorrowers'], errors='coerce')
df['DTI'] = pd.to_numeric(df['DTI'], errors='coerce') / 100
df['CreditScore'] = pd.to_numeric(df['CreditScore'], errors='coerce')
df['FirstTimeHomeBuyerIndicator'] = df['FirstTimeHomeBuyerIndicator'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['LoanPurpose'] = df['LoanPurpose'].str.strip().astype('category')
df['PropertyType'] = df['PropertyType'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['NumberofUnits'] = pd.to_numeric(df['NumberofUnits'], errors='coerce')
df['OccupancyStatus'] = df['OccupancyStatus'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['State'] = df['State'].astype('category')
df['MortgageInsurancePercentage'] = pd.to_numeric(df['MortgageInsurancePercentage'], errors='coerce') / 100
df['ProductType'] = df['ProductType'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['PrepaymentPremiumTerm'] = df['PrepaymentPremiumTerm'].str.strip().replace(r'', 'NULL', regex=True).astype('category')
df['InterestOnlyIndicator'] = df['InterestOnlyIndicator'].str.strip().astype('category')
df['FirstPrincipalandInterestPmtDate'] = pd.to_datetime(df['FirstPrincipalandInterestPmtDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['MonthstoFirstScheduledAmortization'] = pd.to_numeric(df['MonthstoFirstScheduledAmortization'], errors='coerce')
df['ConvertibilityIndicator'] = df['ConvertibilityIndicator'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['MortgageMargin'] = pd.to_numeric(df['MortgageMargin'], errors='coerce')
df['NetMortgageMargin'] = pd.to_numeric(df['NetMortgageMargin'], errors='coerce')
df['Index'] = df['Index'].str.strip().replace(r'', 'NULL', regex=True).astype('category')
df['InterestRateLookBack'] = df['InterestRateLookBack'].str.strip().replace(r'', 'NULL', regex=True).astype('category')
df['MaxInterestRate'] = pd.to_numeric(df['MaxInterestRate'], errors='coerce')
df['NetMaximumInterestRate'] = pd.to_numeric(df['NetMaximumInterestRate'], errors='coerce')
df['MonthstoNextRateChange'] = pd.to_numeric(df['MonthstoNextRateChange'], errors='coerce')
df['NextRateChangeDate'] = pd.to_datetime(df['NextRateChangeDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['RateAdjustmentFrequency'] = pd.to_numeric(df['RateAdjustmentFrequency'], errors='coerce')
df['RateAdjustmentFrequency'] = pd.to_numeric(df['RateAdjustmentFrequency'], errors='coerce')
df['InitialFixedRatePeriod'] = pd.to_numeric(df['InitialFixedRatePeriod'], errors='coerce')
df['InitialRateCapUpPercent'] = pd.to_numeric(df['InitialRateCapUpPercent'], errors = 'coerce')
df['InitialRateCapDownPercent'] = pd.to_numeric(df['InitialRateCapDownPercent'], errors = 'coerce')
df['PeriodicCapUpPercent'] = pd.to_numeric(df['PeriodicCapUpPercent'], errors = 'coerce')
df['PeriodicCapDownPercent'] = pd.to_numeric(df['PeriodicCapDownPercent'], errors = 'coerce')
df['DaysDelinquent'] = pd.to_numeric(df['DaysDelinquent'], errors = 'coerce')
df['LoanPerformanceHistory'] = df['LoanPerformanceHistory'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['LoanAgeasModification'] = pd.to_numeric(df['LoanAgeasModification'], errors = 'coerce')
df['ModificationProgram'] = df['ModificationProgram'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['ModificationType'] = df['ModificationType'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['NumberofModifications'] = pd.to_numeric(df['NumberofModifications'], errors = 'coerce')
df['TotalCapitalizedAmount'] = pd.to_numeric(df['TotalCapitalizedAmount'], errors = 'coerce')
df['OriginalMortgageLoanUPB'] = pd.to_numeric(df['OriginalMortgageLoanUPB'], errors = 'coerce')
#df['Filler'] --> Skip this one
#df['CurrentDeferredUPB'] --> Skip this one for now, although maybe delete the column since the values are: {'     ', 0.0, '0000000.00'}
df['InterestRateStepIndicator'] = df['InterestRateStepIndicator'].str.strip().replace(r'', 'NA', regex=True).astype('category')
df['InitialStepFixedRatePeriod'] = pd.to_numeric(df['InitialStepFixedRatePeriod'], errors = 'coerce')
df['TotalNumberofSteps'] = pd.to_numeric(df['TotalNumberofSteps'], errors = 'coerce')
df['NumberofRemainingSteps'] = pd.to_numeric(df['NumberofRemainingSteps'], errors = 'coerce')
df['NextStepRate'] = df['NextStepRate'].str.strip().replace(r'', 'NA', regex=True).astype('category')
df['TerminalStepRate'] = pd.to_numeric(df['TerminalStepRate'], errors = 'coerce')
df['DateofTerminalStep'] = pd.to_datetime(df['DateofTerminalStep'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['StepRateAdjustmentFrequency'] = df['StepRateAdjustmentFrequency'].str.strip().replace(r'', 'NULL', regex=True)
df['MonthstoNextStepRateChange'] = df['MonthstoNextStepRateChange'].str.strip().replace(r'', 'NULL', regex=True)
df['NextStepRateChangeDate'] = df['NextStepRateChangeDate'].str.strip().replace(r'', 'NULL', regex=True)
df['PeriodicStepCapUpPercent'] = pd.to_numeric(df['PeriodicStepCapUpPercent'], errors = 'coerce')
df['OriginationChannel'] = df['OriginationChannel'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['OriginationInterestRate'] = pd.to_numeric(df['OriginationInterestRate'], errors = 'coerce')
df['OriginationUPB'] = pd.to_numeric(df['OriginationUPB'], errors = 'coerce')
df['OriginationLoanTerm'] = pd.to_numeric(df['OriginationLoanTerm'], errors = 'coerce')
df['OriginationFirstPaymentDate'] = pd.to_datetime(df['OriginationFirstPaymentDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['OriginationMaturityDate'] = pd.to_datetime(df['OriginationMaturityDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['OrginationLTV'] = pd.to_numeric(df['OrginationLTV'], errors='coerce') / 100
df['OriginationCLTV'] = pd.to_numeric(df['OriginationCLTV'], errors='coerce') / 100
df['OriginationDTI'] = pd.to_numeric(df['OriginationDTI'], errors='coerce') / 100
df['OriginationCreditScore'] = pd.to_numeric(df['OriginationCreditScore'], errors='coerce')
df['OriginationLoanPurpose'] = df['OriginationLoanPurpose'].str.strip().replace(r'', 'NULL', regex=True).astype('category')
df['OriginationOccupancyStatus'] = df['OriginationOccupancyStatus'].str.strip().replace(r'', 'NULL', regex=True).astype('category')
df['OriginationProductType'] = df['OriginationProductType'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['OriginationIOIndicator'] = df['OriginationIOIndicator'].str.strip().replace(r'', 'NONE', regex=True).astype('category')

df = df.set_index('LoanIdentifier')
df.to_sql("february", conn, if_exists="append")   #"append" if table already exists
conn.commit()

c1 = "PRAGMA table_info(february)"
c2 = "SELECT CUPB/OUPB FROM february"
c.execute(c2)
c.fetchall()
c.close()
