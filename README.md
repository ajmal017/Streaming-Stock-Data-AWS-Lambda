# Streaming-Stock-Data-AWS-Lambda

## I. Data Collector
### Lambda Function URL
* API Endpoint https://c7p29dr104.execute-api.us-east-2.amazonaws.com/default/chau-function-02

### Lambda Function Sourcecode
* `collector.py`
```python
import json
import boto3
import os
import subprocess
import sys

subprocess.check_call([sys.executable, "-m", "pip", "install", "--target", "/tmp", 'yfinance'])
sys.path.append('/tmp')

import yfinance as yf

tickers = ['FB', 'SHOP', 'BYND', 'NFLX', 'PINS', 'SQ', 'TTD', 'OKTA', 'SNAP', 'DDOG']
start = '2020-05-14'
end = '2020-05-15'

def lambda_handler(event, context):
    fh = boto3.client("firehose", "us-east-2")
    for ticker in tickers:
        data = yf.download(ticker, start=start, end=end, interval = "1m")
        for datetime, row in data.iterrows():
            output = {'name': ticker}
            output['high'] = row['High']
            output['low'] = row['Low']
            output['ts'] = str(datetime)
            as_jsonstr = json.dumps(output)
            fh.put_record(
                DeliveryStreamName="chau-stream-processor", 
                Record={"Data": as_jsonstr.encode('utf-8')})
    return {
        'statusCode': 200,
        'body': json.dumps(f'Done! Recorded: {as_jsonstr}')
    }
 ```
 ![Chau](https://github.com/qchau96/Streaming-Finance-Data-AWS-Lambda/blob/master/images/lambda%20function.png)
 
 ## II. Data Transformer
 ### AWS Kinesis Firehose Delivery Stream
 ![abc](https://github.com/qchau96/Streaming-Finance-Data-AWS-Lambda/blob/master/images/kinesis.png)
 
 ### III. Data Analyzer
 * `query.sql`
 ```sql
SELECT name, ts, hour, high
FROM
  (SELECT name, ts, SUBSTRING(ts, 12, 2) AS hour, high, RANK () OVER ( 
			PARTITION BY name, SUBSTRING(ts, 12, 2)
			ORDER BY high DESC, ts DESC
		) price_rank 
  FROM "20") t1
WHERE t1.price_rank = 1
ORDER BY 1, 3
```
