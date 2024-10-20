# Automated-Delta-Hedging-Portfolio

In this notebook, I will describe the processes of creating an Automated Delta Hedging Portfolio of shorting a European call option by trading in the underlying stock and bank account.

<br/>

Yahoo Finance will be the website to scrape the financial data.

https://sg.finance.yahoo.com/

<br/>
For demonstration purposes, multiple assumptions will be used when pricing the options and creating the replicating portfolio, which are listed below. The risk-free interest rate r is calculated from subtracting the inflation rate of Singapore from the yield of a 1-Year Singapore T-bill (r = 0.0034, as of Oct-2024).

<br/><b>Underlying stock and option used in this replicating portfolio:</b>

Underlying: NVDA (Nvidia Stock, assumed to be a non dividend-paying stock)
https://sg.finance.yahoo.com/quote/NVDA/

Option: NVDA250117C00000500 (Nvidia Call Option with maturity 17-Jan-2025, assumed to be a European call)
https://sg.finance.yahoo.com/quote/NVDA250117C00000500/

<br/>
The automation of the script can be seen in my personal portfolio:

https://briansim74-portfolio.webflow.io/projects/xml

<br/>

<br/><b>This script utilises the following programs & languages:</b>

<b>Languages:</b>
1. Python
2. XML
3. Bash
4. SQL

<b>Programs:</b>
1. Google Colab - Developing the script
2. Selenium & ChromeDriver - Automation of XML Web Scraping
3. Ubuntu Linux - Running the script
4. Cron - Automation of script
5. pyodbc (Python Open Database Connectivity) - To truncate outdated data from SQL Azure database using SQL Query
6. BCP (Bulk Copy Program) Utility - Rapid bulk insert updated data into SQL Azure database
7. Microsoft Azure SQL Database - SQL Cloud database for updating replicating portfolio

<br/><b>The following files for reference for this script are:</b>
1. Yahoo.ipynb
2. NVDA.csv
3. NVDA_Query.sql

<br/><b>Developing the script</b>

First, I installed Selenium and Chromium Driver onto my Google Colab as well as Ubuntu Virtual Machine. Selenium and ChromeDriver are plug-ins to automate the execution of parsing XML data from the Yahoo Finance website.
Using Selenium, I scraped all the relevant data from the NVDA stock as well as the NVDA250117C00000500 call option. These include:

1. Stock Price
2. Strike Price
3. Maturity of option
4. Annual Volatility (Calculated using 20-day volatility of NVDA stock)

After gathering all the relevant data from the underlying and call, I proceeded to calculate the remaining variables needed to create a replicating portfolio. These are:

1. Black-Scholes-Merton (BSM) price of the call option
2. Delta of option
3. Time to Maturity of option (Years)

To calculate the time to maturity of the option, I used the pytz library to compute the current local time in New York and pegging it to the maturity time of 11:59:00 on 25-Jan-2025 as the maturity date and time.

Creating the replicating portfolio

To create the replicating portfolio, I first calculated the delta of the option, which turned out to be 0.507 on 19-Oct-2024 00:44:57 (GMT -4). The replicating portfolio is made by shorting 1 NVDA NVDA250117C00000500 call option, and buying long 0.507 shares of the underlying. The remaining difference would be covered by shorting (borrowing from) the bank.

Delta: 0.507
Value of Shares = 0.507 x 138.00 = 69.98
Amount borrowed from bank = 69.98 - Call Price = 69.98 - 13.97 = 56.01

The value of the replicating portfolio X(0) would then be delta number of shares - amount borrowed from bank = 0.507 * S - 56.01.

After that, I processed the relevant data into a Pandas DataFrame with relevant column names. I then exported the DataFrame into a CSV file to be stored in my Ubuntu Desktop.

Using the pyodbc driver, I then connected to the Microsoft Azure SQL cloud database where the dbo.NVDA SQL Table exists.

In the same script, I added a command to execute the BCP utility to bulk copy the updated CSV file into the dbo.NVDA SQL Table in the Microsoft Azure SQL database, whereby the database would then be updated with the most recent CSV file.

<br/><b>Running and Automation of the script</b>

I utilised Ubuntu Linux for the automation of the script. I started a new Cronjob on Crontab, an automatic task scheduler, whereby I set the Python script to run every minute, thus updating the Azure SQL database every minute with new data.

Each time the script is ran, it will calculate the current stock price, call price, time to maturity and delta. Each time the delta changes, the current number of shares would be updated to the value of the new delta, and the profit from selling the change in delta of shares would be paid back to the bank to cover the debt incurred, with interest.

Current stock price = 138.00
Current call price = 13.97
Current delta: 0.507 (19-Oct-2024 00:44:57)
New delta: 0.507 (19-Oct-2024 01:10:15)
Change in delta = New delta - current delta = 0.507 - 0.507 = 0.000
Profit from selling 0.000 shares = 0.000
Current amount owed to bank before / after interest (r = 0.0034) = 56.01 / 56.01
New amount owed to bank = Amount after interest - profit from selling shares = 56.01 - 0.000 = 56.01
Current value of replicating portfolio = 0.507 * 138.00 - 56.01 = 13.97
Profit = Replicating portfolio - current call price = 13.97 - 13.97 = 0.00

Each time, the profit would be calculated from the cost of closing the short position of the NVDA250117C00000500 option, by subtracting the current value of the replicating portfolio (wealth) by the current call price of the option.

The current profit can be then analysed and set by a system to automatically close this position once it reaches above a certain threshold (Eg. profit >= $12.00)

Finally, the automation of the Web Scraping Script can be seen by the updating of the Azure SQL database every 30 minutes by quering the Security Wise Holdings SQL Table from the Microsoft Azure Portal, preferably set to operating during the trading hours of the US stock market (9:30am to 4:00pm GMT-04).

