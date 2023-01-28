/*
Analysis of bitcoin data taken from 2014-04-09 until 2022-12-22
*/

---Creating the table from bitcoin_data.csv

CREATE TABLE bitcoin_data(trans_date date,
					 priceUSD float(6),
					 code_size integer,
					 sentbyaddress integer,
					 transactions integer,
					 mining_profitability float(5),
					 sentinusd bigint,
					 transactionfees float(6),
					 median_transaction_fee float(5),
					 confirmationtime float(5),
					 marketcap bigint,
					 transactionvalue integer,
					 mediantransactionvalue numeric(10,3),
					 tweets integer,
					 google_trends float(6),
					 fee_to_reward float(5),
					 activeaddresses integer,
					 top100cap numeric(5,3)
					);
---copying data from bitcoin_data.csv

COPY bitcoin_data
FROM '/Users/justindeangel/Downloads/bitcoin_data.csv'
WITH (FORMAT CSV,HEADER);

---using SELECT * FROM to check out if the data needs to be cleaned. 
---the data is actually really clean to work with. 

SELECT * FROM bitcoin_data;

---testing the significance of code size per amount of transactions 

SELECT trans_date, code_size, transactions, code_size / transactions AS difficulty
FROM bitcoin_data
ORDER BY difficulty DESC;

--seeing with the daily cost of transactions are with the median transaction fee

SELECT 	trans_date, 
		median_transaction_fee, 
		transactions, 
		median_transaction_fee / transactions AS daily_cost
FROM bitcoin_data
ORDER BY daily_cost;

---comparing the average trancation to the median transaction alue

SELECT trans_date, sentinusd / transactions AS average_transaction, mediantransactionvalue
FROM bitcoin_data;

---finding the average price of bitcoin from 2014 - 2022

SELECT avg(priceusd) AS avg_price
FROM bitcoin_data;

---computing the total number of transactions from 2014 - 2022

SELECT sum(transactions) AS total_transactions
FROM bitcoin_data;

---segregating the max market cap of bitcoin

SELECT max(marketcap) AS max_cap
FROM bitcoin_data;

---on average, how many people talk about bitcoin?

SELECT avg(tweets) AS avg_daily_tweets
FROM bitcoin_data;
