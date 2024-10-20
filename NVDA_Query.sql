TRUNCATE TABLE dbo.NVDA; --delete all rows in table

SELECT * FROM dbo.NVDA -- view table

CREATE TABLE NVDA (
	Date_Time VARCHAR(50),
	Maturity VARCHAR(50),
	Stock_Price FLOAT(50),
	Strike_Price FLOAT(50),
	Amount_Borrowed_from_Bank FLOAT(50),
	r FLOAT(50),
	Dividend_Yield FLOAT(50),
	Vol FLOAT(50),
	BSM_Price FLOAT(50),
	Call_Price FLOAT(50), 
	Delta FLOAT(50),
	Wealth FLOAT(50),
	Profit FLOAT(50),
);  --create table

DROP TABLE dbo.NVDA --delete table