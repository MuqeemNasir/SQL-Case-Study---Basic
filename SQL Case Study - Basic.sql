Create Database DB2
Use DB2;
Create Table Customer
(
	customer_id int NOT NULL PRIMARY KEY,
	DOB DATE NOT NULL,
	Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
	city_code int NOT NULL
)
Create Table Transactions
(
	transaction_id varchar(11) NOT NULL ,
	cust_id int  NOT NULL ,
	tran_date DATE NOT NULL,
	prod_subcat_code int,
	prod_cat_code int,
	Qty int,
	Rate int,
	Tax NUMERIC(18, 5),
	total_amt NUMERIC(18, 5),
	Store_type VARCHAR(50)
)
Alter Table Transactions
Create Table prod_cat_info
(
	prod_cat_code int,
	prod_cat VARCHAR(20),
	prod_sub_cat_code int,
	prod_subcat VARCHAR(20)
)

Select * From  Customer
Select * From  Transactions
Select * From  prod_cat_info

----- Data Preparation AND Understanding -----------------------

--Q1.
Select count(*) Row_count
From Customer
Union All Select count(*)
From Transactions
Union All Select count(*)
From prod_cat_info

--Q2.
Select count(*) As Return_Transaction
From Transactions
Where total_amt < 0

--Q3.
SET DATEFORMAT DMY --(OR) SET DATEFORMAT YMD
Declare @Existingdate Datetime
Set @Existingdate=GETDATE()
Select CONVERT(Varchar,@Existingdate,5) As [DD-MM-YY]

Select convert(date,DOB,105) As DOB From Customer;
Select convert(date,tran_date,105) As tran_date From Transactions


--Q4.
Select
DATEDIFF(YEAR,Min(convert(date,tran_date,105)),Max(convert(date,tran_date,105))) As Year_diff,
DATEDIFF(MONTH,Min(convert(date,tran_date,105)),Max(convert(date,tran_date,105))) As Month_diff,
DATEDIFF(DAY,Min(convert(date,'22-02-2011',105)),Max(convert(date,'28-02-2014',105))) As Day_diff
From Transactions

--Q5.
Select prod_cat
From prod_cat_info
where prod_subcat = 'DIY'


-----------------------------------------------------------------------------------------------------------------------

--- DATA ANALYSIS

--Q1.
Select Top 1 Store_type, count(Store_type) As [No. of Stores]
From Transactions
Group By Store_type
Order By count(*) desc

--Q2.
Select Gender, count(*) As [No. of Customers] 
From Customer where Gender <>''
Group By Gender

--Q3.
Select Top 1 city_code, count(customer_id) As [No. of Customer]
From Customer
Group by city_code

--Q4.
Select prod_cat, count(prod_subcat) As [sub categories]
From prod_cat_info
where prod_cat = 'Books'
Group By prod_cat

--Q5.
Select max(Qty) As Quantity
From Transactions

--Q6.
Select SUM(Try_Convert(float,total_amt)) as Net_Revenue
From  Transactions  T1
			INNER JOIN
	  prod_cat_info P1      ON T1.prod_cat_code = P1.prod_cat_code and T1.prod_subcat_code = P1.prod_sub_cat_code
Where prod_cat IN ('Electronics', 'Books')
--Group By prod_cat

--Q7.
Select count(*) FROM(Select cust_id As Count_of_Transactions
From Transactions
Where Qty >= 0
Group By cust_id
Having count(transaction_id) > 10) As T

--Q8.
Select Store_type,Sum(Try_Convert(float, total_amt)) As [Combined Revenue]
From  Transactions  T1
			INNER JOIN
	  prod_cat_info P1      ON T1.prod_cat_code = P1.prod_cat_code and T1.prod_subcat_code = P1.prod_sub_cat_code
Where prod_cat IN ('Electronics', 'Clothing') AND Store_type=('Flagship store')
Group By Store_type

--Q9.
Select prod_subcat, Sum(Try_Convert(float, total_amt)) As [Tot_Revenue]
From  Customer  T1
			INNER JOIN
	  Transactions P1      ON T1.customer_Id = P1.cust_id
		    INNER JOIN
	  prod_cat_info   C1   ON P1.prod_cat_code = C1.prod_cat_code and P1.prod_subcat_code = C1.prod_sub_cat_code
Where Gender = 'M' AND prod_cat='Electronics'
Group By prod_subcat

--Q10.
Select Top 5 prod_subcat,Sum(case WHEN Try_Convert(float,total_amt) > 0 THEN 1 ELSE 0 END) As 'Sales',
Sum(case WHEN Try_Convert(float,total_amt) > 0 THEN 1.0 ELSE 0 END) /Count(*) *100 As 'Sales_%cent',
Sum(case WHEN Try_Convert(float,total_amt) < 0 THEN 1 ELSE 0 END) As 'Returns',
Sum(case WHEN Try_Convert(float,total_amt) < 0 THEN 1.0 ELSE 0 END) /Count(*) *100 As 'Return_%cent'
From Transactions As T1
			INNER JOIN
	 prod_cat_info As P1  ON T1.prod_subcat_code = P1.prod_sub_cat_code and T1.prod_cat_code = P1.prod_cat_code
Group By prod_subcat 
Order By sales desc

--Q11.
Select DOB,DATEDIFF(YEAR,Try_Convert(date,DOB,105), GetDate()) As Age_btw_25_to_35,Sum(Try_Convert(float,total_amt)) As Tot_Revenue,
DATEAdd(DAY,-30,Max(Try_Convert(date,tran_date,105))) As Last_Transac
From Customer As T1
		Full OUTER JOIN
	 Transactions As P2 ON T1.customer_Id = P2.cust_id
Where (DATEDIFF(YEAR,Try_Convert(date,DOB,105), GetDate()) between 25 and 35)
Group By DOB,tran_date
Having Try_Convert(date,tran_date,105)> = DATEAdd(DAY,-30,Max(Try_Convert(date,tran_date,105)))
Order By last_transac

--Q12.
Select Top 1 prod_cat, Sum(Try_Convert(float,total_amt)) As Max_Return, DATEAdd(MONTH,-3,Max(Try_Convert(date,tran_date,105))) As Last_3_Months
From prod_cat_info As T1 
		Full OUTER JOIN Transactions As P1 ON T1.prod_cat_code = P1.prod_cat_code and T1.prod_sub_cat_code = P1.prod_subcat_code
Where Try_Convert(float,total_amt)<0 
Group By prod_cat,tran_date
Having Try_Convert(date,tran_date,105)>=DATEAdd(MONTH,-3,Max(Try_Convert(date,tran_date,105)))
Order By Max_Return

 --Q13.
Select Top 1 Store_type, Sum(Try_Convert(float,total_amt)) As Sales_Amount,Qty As Sell_Quantity
From Transactions
Where Try_Convert(float,total_amt)>0
Group By Store_type,Qty
Having qty>0
Order By Qty desc,Sales_Amount desc

--Q14.
Select prod_cat, Avg(Try_Convert(float,total_amt)) As Avg_Revenue
From prod_cat_info As T1
		 Full OUTER JOIN  Transactions As P1  ON  T1.prod_cat_code = P1.prod_cat_code and T1.prod_sub_cat_code = P1.prod_subcat_code
Group By prod_cat
Having Avg(Try_Convert(float,total_amt)) > (Select Avg(Try_Convert(float,total_amt)) As Overall_Avg_Revenue From Transactions)

--Q15.
Select prod_subcat, Sum(Try_Convert(float,total_amt)) As Tot_Revenue, Avg(Try_Convert(float,total_amt)) As Avg_Revenue 
From prod_cat_info As T1
		 Full OUTER JOIN  Transactions As P1  ON  T1.prod_cat_code = P1.prod_cat_code and T1.prod_sub_cat_code = P1.prod_subcat_code
Where exists
(
	Select Top 5 prod_cat, Sum(Try_Convert(float,Qty)) As Net_Qty 
	From prod_cat_info As C1
			 Full OUTER JOIN  Transactions As D1   ON  C1.prod_cat_code = D1.prod_cat_code and C1.prod_sub_cat_code = D1.prod_subcat_code
	Group By prod_cat
	Order By  Net_Qty desc
)
Group By prod_subcat


------------------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$----------------------------------------------------;  