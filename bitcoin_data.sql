 /*
Analysis of bitcoin data taken from 2014-04-09 until 2022-12-22
*/

--- Creating the table from bitcoin_data.csv
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
--- Copying data from bitcoin_data.csv
COPY bitcoin_data
FROM '/Users/justindeangel/Downloads/bitcoin_data.csv'
WITH (FORMAT CSV,HEADER);

--- Check initial data for cleanliness
SELECT * FROM bitcoin_data;

--- Analyzing code size in relation to transaction volume
SELECT trans_date, code_size, transactions, code_size / transactions AS difficulty
FROM bitcoin_data
ORDER BY difficulty DESC;

--- Calculating daily transaction cost based on median fee
SELECT 	trans_date, 
		median_transaction_fee, 
		transactions, 
		median_transaction_fee / transactions AS daily_cost
FROM bitcoin_data
ORDER BY daily_cost;

--- Comparing average and median transaction values
SELECT trans_date, sentinusd / transactions AS average_transaction, mediantransactionvalue
FROM bitcoin_data;

--- Determining average Bitcoin price from 2014 to 2022
SELECT avg(priceusd) AS avg_price
FROM bitcoin_data;

--- Summing total transactions from 2014 to 2022
SELECT sum(transactions) AS total_transactions
FROM bitcoin_data;

--- Identifying the peak market capitalization
SELECT max(marketcap) AS max_cap
FROM bitcoin_data;

--- Calculating average daily tweet volume
SELECT avg(tweets) AS avg_daily_tweets
FROM bitcoin_data;

--- Assessing year-over-year market cap growth
WITH YearlyMarketCap AS (
    SELECT
        EXTRACT(YEAR FROM trans_date) AS year,
        SUM(marketcap) AS yearly_market_cap
    FROM
        bitcoin_data
    WHERE
        EXTRACT(YEAR FROM trans_date) BETWEEN 2014 AND 2022
    GROUP BY
        year
)
SELECT
    year,
    yearly_market_cap,
    ((yearly_market_cap - LAG(yearly_market_cap) OVER (ORDER BY year)) / LAG(yearly_market_cap) OVER (ORDER BY year)) * 100 AS yoy_growth_percentage
FROM
    YearlyMarketCap
ORDER BY
    year;
	
--- Examining how tweet volume impacts market cap
SELECT
    DATE_TRUNC('month', trans_date) AS month,
    SUM(tweets) AS total_tweets,
    AVG(marketcap) AS average_market_cap
FROM
    bitcoin_data
GROUP BY
    month
ORDER BY
    month;

--- Analyzing yearly influence of tweets on Bitcoin's average price
SELECT
    EXTRACT(YEAR FROM trans_date) AS year,
    SUM(tweets) AS total_tweets,
    AVG(priceUSD) AS average_price
FROM
    bitcoin_data
GROUP BY
    year
ORDER BY
    year;
	
--- Exploring the relationship between Google Trends and Bitcoin price volatility
WITH MonthlyVolatility AS (
    SELECT
        DATE_TRUNC('month', trans_date) AS month,
        STDDEV(priceUSD) AS price_volatility
    FROM
        bitcoin_data
    GROUP BY
        month
)
SELECT
    m.month,
    m.price_volatility,
    AVG(b.google_trends) AS avg_google_trends
FROM
    MonthlyVolatility m
JOIN
    bitcoin_data b ON DATE_TRUNC('month', b.trans_date) = m.month
GROUP BY
    m.month, m.price_volatility
ORDER BY
    m.month;

--- Tracking monthly market cap changes in percentage
WITH MonthlyData AS (
    SELECT
        DATE_TRUNC('month', trans_date) AS month,
        SUM(marketcap) AS monthly_market_cap
    FROM
        bitcoin_data
    GROUP BY
        month
)
SELECT
    month,
    monthly_market_cap,
    (monthly_market_cap - LAG(monthly_market_cap) OVER (ORDER BY month)) / LAG(monthly_market_cap) OVER (ORDER BY month) * 100 AS month_over_month_change
FROM
    MonthlyData
ORDER BY
    month;
	
--- Correlating transaction volume with market cap
SELECT
    CORR(transactions, marketcap) AS transactions_marketcap_correlation
FROM
    bitcoin_data;
	
--- Comparing monthly average transaction values with mining profitability
SELECT
    DATE_TRUNC('month', trans_date) AS month,
    AVG(transactionvalue) AS avg_transaction_value,
    AVG(mining_profitability) AS avg_mining_profitability
FROM
    bitcoin_data
GROUP BY
    month
ORDER BY
    avg_mining_profitability DESC;
	
--- Yearly active address growth rate

WITH YearlyActiveAddresses AS (
    SELECT
        EXTRACT(YEAR FROM trans_date) AS year,
        AVG(activeaddresses) AS avg_active_addresses
    FROM
        bitcoin_data
    GROUP BY
        year
)
SELECT
    year,
    avg_active_addresses,
    (avg_active_addresses - LAG(avg_active_addresses) OVER (ORDER BY year)) / LAG(avg_active_addresses) OVER (ORDER BY year) * 100 AS yoy_growth_rate
FROM
    YearlyActiveAddresses
ORDER BY
    year;