# Edits for FNMA data set
import numpy as np

df['LoanCorrectionIndicator'] = df['LoanCorrectionIndicator'].replace(r'\s+', 0, regex=True).astype('category')
# Replace blank strings with 'None', trim whitespace, and cast as categorical variable
df['Channel'] = df['Channel'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['SellerName'] = df['SellerName'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['ServicerName'] = df['ServicerName'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
df['OriginalInterestRate'] = pd.to_numeric(df['OriginalInterestRate'], errors='coerce')
df['CurrentInterestRate'] = pd.to_numeric(df['CurrentInterestRate'], errors='coerce')
df['CurrentNetInterestRate'] = pd.to_numeric(df['CurrentNetInterestRate'], errors='coerce')
df['OUPB'] = pd.to_numeric(df['OUPB'], errors='coerce')
df['CUPB'] = pd.to_numeric(df['CUPB'], errors='coerce')
df['OriginalLoanTerm'] = pd.to_numeric(df['OriginalLoanTerm'], errors='coerce')
# Replace blank strings with a null-style date (01/1900), convert all strings to datetime object
df['FirstPaymentDate'] = pd.to_datetime(df['FirstPaymentDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
df['LoanAge'] = pd.to_numeric(df['LoanAge'], errors='coerce')
df['RemainingMTM'] = pd.to_numeric(df['RemainingMTM'], errors='coerce')
df['MaturityDate'] = pd.to_datetime(df['MaturityDate'].replace(r'       ', '01/1900', regex=True), format='%m/%Y')
# Convert LTV to percent
df['LTV'] = pd.to_numeric(df['LTV'], errors='coerce') / 100
df['CLTV'] = pd.to_numeric(df['CLTV'], errors='coerce') / 100
df['NumberofBorrowers'] = pd.to_numeric(df['NumberofBorrowers'], errors='coerce')
df['DTI'] = pd.to_numeric(df['DTI'], errors='coerce')
df['CreditScore'] = pd.to_numeric(df['CreditScore'], errors='coerce')
