# Edits for FNMA data set
import numpy as np

df['LoanCorrectionIndicator'] = df['LoanCorrectionIndicator'].replace(r'\s+', 0, regex=True).astype('category')
#Replace blank strings with 'None', trim whitespace, and cast as categorical variable
df['Channel'] = df['Channel'].str.strip().replace(r'', 'NONE', regex=True).astype('category')
