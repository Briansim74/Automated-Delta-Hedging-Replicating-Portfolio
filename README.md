# Automated-Delta-Hedging-Replicating-Portfolio

In this notebook, I will describe the processes of creating an Automated Delta Hedging Replicating Portfolio of shorting an NVDA European call option by trading in the underlying stock and bank account.

<br/>

Yahoo Finance will be the website to scrape the financial data.

https://sg.finance.yahoo.com/

<br/>
The Nvidia call option will be assumed to be a European type call option. The risk-free interest rate r is calculated from subtracting the inflation rate of Singapore from the yield of a 1-Year Singapore T-bill (r = 0.0034, as of Oct-2024).

<br/>
<br/><b>Underlying stock and option used in this replicating portfolio:</b>

<br/>
<br/>
Underlying: NVDA (Nvidia Stock, with dividends)<br/>
https://sg.finance.yahoo.com/quote/NVDA/<br />

<br/>
Option: NVDA250117C00000500 (Nvidia Call Option with maturity 17-Jan-2025, assumed to be a European call)
https://sg.finance.yahoo.com/quote/NVDA250117C00000500/

<br />
<br />
The automation of the script can be seen in my personal portfolio:

https://briansim74-portfolio.webflow.io/projects/hedgingportfolio


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
1. Yahoo_Full_Script.ipynb (Creation of Replicating Portfolio)
2. Yahoo.py (Script)
3. NVDA.csv
4. NVDA_Query.sql
5. cron.txt

<br/><b>Developing the script</b>

First, I installed Selenium and Chromium Driver onto my Google Colab as well as Ubuntu Virtual Machine. Selenium and ChromeDriver are plug-ins to automate the execution of parsing XML data from the Yahoo Finance website.
Using Selenium, I scraped all the relevant data from the NVDA stock as well as the NVDA250117C00000500 call option. These include:

1. Stock Price
2. Strike Price
3. Annual Dividend Yield
4. Maturity of option
5. Annual Volatility (Calculated using 20-day volatility of NVDA stock)

After gathering all the relevant data from the underlying and call, I proceeded to calculate the remaining variables needed to create a replicating portfolio. These are:

1. Black-Scholes-Merton (BSM) price of the call option
2. Delta of option
3. Time to maturity of option (Years)

To calculate the time to maturity of the option, I used the pytz library to compute the current local time in New York and pegging it to the maturity time of 11:59:00 on 25-Jan-2025 as the maturity date and time.

<br/><b>Creating the replicating portfolio</b>

To create the replicating portfolio, I first calculated the delta of the option, which turned out to be 0.507 on 24-Oct-2024 11:21:59 (GMT -4). The replicating portfolio is made by shorting 1 NVDA NVDA250117C00000500 call option, and buying long 0.507 shares of the underlying. The remaining difference would be covered by shorting (borrowing from) the bank.

<br/>
Current call price: 14.70
<br/>
Delta: 0.534355093723429
<br/>
Value of shares = 0.534355093723429 x 139.79 = 74.69749855
<br/>
Amount borrowed from bank = 69.98 - Call Price = 74.69749855 - 14.70 = 59.99749855

<br />
The value of the replicating portfolio X(0) would then be delta number of shares - amount borrowed from bank = 0.534355093723429 * 139.79 - 59.99749855 = 14.70.

<br/><br/>
After that, I processed the relevant data into a Pandas DataFrame with relevant column names. I then exported the DataFrame into a CSV file to be stored in my Ubuntu Desktop.

Using the pyodbc driver, I then connected to the Microsoft Azure SQL cloud database where the dbo.NVDA SQL Table exists.

In the same script, I added a command to execute the BCP utility to bulk copy the updated CSV file into the dbo.NVDA SQL Table in the Microsoft Azure SQL database, whereby the database would then be updated with the most recent CSV file.

<br/><b>Running and Automation of the script</b>

I utilised Ubuntu Linux for the automation of the script. I started a new Cronjob on Crontab, an automatic task scheduler, whereby I set the Python script to run every minute, thus updating the Azure SQL database every minute with new data.

Each time the script is ran, it will rebalance the hedge, by calculating the current stock price, call price, time to maturity and delta. Each time the delta changes, the current number of shares would be updated to the value of the new delta, and the profit from selling the change in delta of shares would be paid back to the bank to cover the debt incurred, with interest.

<br/>
Current stock price = 144.10
<br/>
Current call price = 16.75
<br/>
Current delta: 0.599720535384939 (25-Oct-2024 11:22:27)
<br/>
New delta: 0.600312444512223 (25-Oct-2024 11:27:25)
<br/>
Change in delta = current delta - new delta = 0.599720535384939 - 0.600312444512223 = -0.0005919091273
<br/>
Profit from selling -0.0005919091273 shares = -0.0005919091273 * 144.10 = -0.08529410524
<br/>
Current amount owed to bank before / after interest (r = 0.0034) = 69.35388371 / 69.35388594
<br/>
New amount owed to bank = Amount after interest - profit from selling shares = 69.35388594 - (-0.08529410524) = 69.439180045658
<br/>
Current value of replicating portfolio = 0.600312444512223 * 144.10 - 69.439180045658 = 17.0658432085533
<br/>
Profit without hedging = Initial call price - current call price = 14.70 - 16.75 = -2.05
<br/>
Profit with hedging = Replicating portfolio - current call price = 17.0658432085533 - 16.75 = 0.3158432086

<br/><br/>
Each time, the profit would be calculated from the cost of closing the short position of the NVDA250117C00000500 option, by subtracting the current value of the replicating portfolio (wealth) by the current call price of the option.

As shown above, if there was no hedging, the current profit of the portfolio after closing the short position of the call would be much less or even negative compared with the hedged position.

The current profit can be then analysed and set to automatically close this position once it reaches above a certain threshold (Eg. profit >= $12.00)

Finally, the automation of the Web Scraping Script can be seen by the updating of the Azure SQL database every 5 minutes by quering the Security Wise Holdings SQL Table from the Microsoft Azure Portal, preferably set to operating during the trading hours of the US stock market (9:30am to 4:00pm GMT-04).
