/* Assignment 1 Question 1 Solution */

use AdventureWorks2017;
WITH CTE AS (SELECT    YEAR(OrderDate) AS OrderYear,  DATEPART(quarter, OrderDate) AS OrderQuarter, SUM(TotalDue) AS Sales
			 FROM Sales.SalesOrderHeader
			 WHERE (YEAR(OrderDate) = 2011 OR
					YEAR(OrderDate) = 2012 OR
					YEAR(OrderDate) = 2013 OR
					YEAR(OrderDate) = 2014)
			 GROUP BY  YEAR(OrderDate), DATEPART(quarter, OrderDate)
			),
CTE_1 AS (
    SELECT  OrderYear, SUM(Sales) AS AnnualSales
    FROM CTE
    GROUP BY OrderYear
		)
SELECT 
    CTE.OrderYear,
    RIGHT(ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 1 THEN CTE.Sales ELSE NULL END), 'N0'), ' '), 10) AS "1st Quarter",
	(SUM(CASE WHEN CTE.OrderQuarter = 1 THEN CTE.Sales ELSE 0 END) / CTE_1.AnnualSales) * 100 AS "Annual %",
    ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 1 THEN CTE.Sales ELSE NULL END) - ISNULL(LAG(SUM(CASE WHEN CTE.OrderQuarter = 4 THEN CTE.Sales ELSE NULL END)) OVER (ORDER BY CTE.OrderYear),0), 'N0'), ' ') AS "4 to 1Change",
    RIGHT(ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 2 THEN CTE.Sales ELSE NULL END), 'N0'), ' '),10) AS "2nd Quarter",
    (SUM(CASE WHEN CTE.OrderQuarter = 2 THEN CTE.Sales ELSE 0 END) / CTE_1.AnnualSales) * 100 AS "Annual %",
	ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 2 THEN CTE.Sales ELSE NULL END) - SUM(CASE WHEN CTE.OrderQuarter = 1 THEN CTE.Sales ELSE NULL END), 'N0'), ' ') AS "1 to 2Change",
	ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 3 THEN CTE.Sales ELSE NULL END), 'N0'), ' ') AS "3rd Quarter",
    ISNULL((SUM(CASE WHEN CTE.OrderQuarter = 3 THEN CTE.Sales ELSE NULL END) / CTE_1.AnnualSales) * 100,' ') AS "Annual %",
	ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 3 THEN CTE.Sales ELSE NULL END) - SUM(CASE WHEN CTE.OrderQuarter = 2 THEN CTE.Sales ELSE NULL END), 'N0'), ' ') AS "2 to 3Change",
	ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 4 THEN CTE.Sales ELSE NULL END), 'N0'), ' ') AS "4th Quarter",
    (SUM(CASE WHEN CTE.OrderQuarter = 4 THEN CTE.Sales ELSE 0 END) / CTE_1.AnnualSales) * 100 AS "Annual %",
	ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 4 THEN CTE.Sales ELSE NULL END) - SUM(CASE WHEN CTE.OrderQuarter = 3 THEN CTE.Sales ELSE NULL END), 'N0'), ' ') AS "3 to 4Change",
	ISNULL(FORMAT(SUM(CASE WHEN CTE.OrderQuarter = 1 THEN CTE.Sales ELSE 0 END) + SUM(CASE WHEN CTE.OrderQuarter = 2 THEN CTE.Sales ELSE 0 END) + SUM(CASE WHEN CTE.OrderQuarter = 3 THEN CTE.Sales ELSE 0 END) + SUM(CASE WHEN CTE.OrderQuarter = 4 THEN CTE.Sales ELSE 0 END), 'N0'), ' ') as "Annual Sales"
FROM CTE
JOIN CTE_1 ON CTE.OrderYear = CTE_1.OrderYear
GROUP BY CTE.OrderYear,CTE_1.AnnualSales
ORDER BY CTE.OrderYear

/* Assignment 1 Question 2 Solution */

select distinct sh.SalesPersonID, pp.FirstName,pp.LastName, stuff((select ', ', rtrim (cast(ProductID as char)) 
 from Sales.SalesOrderDetail 
 group by ProductID  

					 

order by ProductID 
 for xml path('')), 1,2,'' ) as Product from Sales.SalesOrderHeader sh join  

		 

Sales.SalesOrderDetail sd 
 on sd.SalesOrderID=sh.SalesOrderID 
 join Person.Person pp 
 on pp.BusinessEntityID = sh.SalesPersonID order by sh.SalesPersonID;  

				 

			 

/*Using STRING_AGG:  */

					 

select distinct sh.SalesPersonID, pp.FirstName,pp.LastName, 
 (STRING_AGG(cast(sd.ProductID as nvarchar(max)),', ') WITHIN GROUP ( ORDER BY sd.ProductID ) ) AS Product FROM  

					 

Sales.SalesOrderDetail sd 				 

join  

		 

Sales.SalesOrderHeader sh 
 on sd.SalesOrderID=sh.SalesOrderID 
 join Person.Person pp 
 on pp.BusinessEntityID = sh.SalesPersonID 
 group by sh.SalesPersonID, pp.FirstName,pp.LastName order by sh.SalesPersonID;  

				 