/* Source Database */

use source_jhalak;

/* Source */ 
 
CREATE TABLE CustomerOrder 
(OrderID INT IDENTITY PRIMARY KEY, 
 CustomerID INT NOT NULL, 
 OrderDate DATETIME DEFAULT getdate(), 
 OrderValue MONEY NOT NULL); 
 
/* Destination Database */

 use destination_jhalak;

 /* Destination */

 CREATE TABLE CustomerReport
 (CustomerID INT PRIMARY KEY,
 LastName VARCHAR(50),
 FirstName VARCHAR(50),
 Email VARCHAR(50),
Phone VARCHAR(20),
 TotalPurchase MONEY,
 NumberOfOrders INT,
 ModifiedDate DATETIME DEFAULT getdate());

 /* Creating Audit table in the SOURCE database */

 use source_jhalak;

CREATE TABLE AuditCustomer
 (
 Audit_PK  INT  IDENTITY(1,1) PRIMARY KEY
 ,CustomerID  INT  NOT NULL
 ,OrderID INT
 ,OrderDate DATETIME
 ,OrderValue MONEY
 ,ModifiedDate DATETIME
 );
 
 /* Creating Triggers in source database */
 /* We'll need two triggers - 
 one for INSERT and one for DELETE operations. */

CREATE TRIGGER tr_ins_customer_order 
ON source_jhalak.dbo.CustomerOrder 
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @CustomerID INT;
  DECLARE @OrderDate DATETIME;
  DECLARE @OrderValue MONEY;

  SELECT @CustomerID = CustomerID, @OrderDate = OrderDate, @OrderValue = OrderValue
  FROM inserted;

  INSERT INTO source_jhalak.dbo.AuditCustomer (CustomerID, OrderID, OrderDate, OrderValue)
  SELECT @CustomerID, OrderID, @OrderDate, @OrderValue
  FROM inserted;

  UPDATE destination_jhalak.dbo.CustomerReport
  SET TotalPurchase = TotalPurchase + @OrderValue,
      NumberOfOrders = NumberOfOrders + 1,
      ModifiedDate = GETDATE()
  WHERE CustomerID = @CustomerID;
END;

CREATE TRIGGER tr_del_customer_order
ON source_jhalak.dbo.CustomerOrder
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @CustomerID INT;
  DECLARE @OrderValue MONEY;

  SELECT @CustomerID = CustomerID, @OrderValue = OrderValue
  FROM deleted;

  INSERT INTO source_jhalak.dbo.AuditCustomer (CustomerID, OrderID, OrderDate, OrderValue, ModifiedDate)
  SELECT CustomerID, OrderID, OrderDate, OrderValue, GETDATE()
  FROM deleted;

  UPDATE destination_jhalak.dbo.CustomerReport
  SET TotalPurchase = TotalPurchase - @OrderValue,
      NumberOfOrders = NumberOfOrders - 1,
      ModifiedDate = GETDATE()
  WHERE CustomerID = @CustomerID;
END;
