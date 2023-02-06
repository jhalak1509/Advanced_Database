create database source_jhalak
create database destination_jhalak

/* Source */  

use source_jhalak;
 
create table SaleOrder 
(OrderID int identity primary key, 
 OrderDate date, 
 CustomerID int); 
 
create table OrderItem 
(ItemID int, 
 OrderID int references SaleOrder(OrderID), 
 Quantity int, 
 UnitPrice money, 
 LastModified datetime default getdate() 
 primary key (OrderID, ItemID)); 

 /* Creating Materialized view for data sync */

 Create View View_Order 
 WITH SCHEMABINDING
 AS
 SELECT  
so.CustomerID, so.OrderDate, so.OrderID, oi.ItemID, oi.Quantity, oi.UnitPrice, oi.LastModified  
FROM  
dbo.SaleOrder  so
JOIN  
dbo.OrderItem oi ON so.OrderID = oi.OrderID ;

Create UNIQUE CLUSTERED INDEX in_vOrder
on View_Order(OrderID, ItemID);

/* Destination */

use destination_jhalak;

create table ItemsReport 
(CustomerID int, 
 OrderDate date, 
 OrderID int, 
 ItemID int, 
 Quantity int, 
 UnitPrice money, 
 LastModified datetime 
 primary key(OrderID, ItemID));   

 /* Creating Audit table in destination db */

 CREATE TABLE ItemsAudit 
 ( 
  Audit_PK INT  IDENTITY(1,1) NOT NULL 
  ,CustomerID int 
  ,OrderDate date 
  ,OrderID int 
  ,ItemID int 
  ,OldQuantity int 
  ,NewQuantity int 
  ,OldUnitPrice money 
  ,NewUnitPrice money 
  ,NewLastModified datetime 
  ,OldLastModified datetime 
  ,[Action] CHAR(6) NULL 
  ,ActionTime DATETIME DEFAULT GETDATE() 
 ); 

/* Creating stored procedure in the destination database */

CREATE PROCEDURE SynchronizeDestinationData  
AS
BEGIN
  SET NOCOUNT ON;
  
  MERGE INTO destination_jhalak.dbo.ItemsReport AS dest
  USING source_jhalak.dbo.View_Order AS src
  ON dest.OrderID = src.OrderID AND dest.ItemID = src.ItemID 
  WHEN MATCHED THEN 
    UPDATE SET dest.Quantity = src.Quantity, dest.UnitPrice = src.UnitPrice, dest.LastModified = src.LastModified
  WHEN NOT MATCHED BY TARGET THEN  
    INSERT (CustomerID, OrderDate, OrderID, ItemID, Quantity, UnitPrice, LastModified)
    VALUES (src.CustomerID, src.OrderDate, src.OrderID, src.ItemID, src.Quantity, src.UnitPrice, src.LastModified)
  WHEN NOT MATCHED BY SOURCE THEN  
    DELETE 
  OUTPUT $action, src.CustomerID, src.OrderDate, src.OrderID, src.ItemID, 
         Deleted.Quantity,
    Inserted.Quantity,
    Deleted.UnitPrice,
    Inserted.UnitPrice,
    Inserted.LastModified,
    Deleted.LastModified
INTO destination_jhalak.dbo.ItemsAudit
    ([Action],
    CustomerID,
    OrderDate,
    OrderID,
    ItemID,
    OldQuantity,
    NewQuantity,
    OldUnitPrice,
    NewUnitPrice,
    NewLastModified,
    OldLastModified);
         
END;



