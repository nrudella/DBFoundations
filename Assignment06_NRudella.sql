--*************************************************************************--
-- Title: Assignment06
-- Author: NRudella
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2026-11-15,NRudella,Created File and Completed Questions 1-10
--**************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS (SELECT	Name
				FROM		SysDatabases
				WHERE	Name = 'Assignment06DB_NRudella')
		BEGIN
			ALTER DATABASE [Assignment06DB_NRudella]
				SET SINGLE_USER 
				WITH ROLLBACK IMMEDIATE;
			DROP DATABASE Assignment06DB_NRudella;
		END
	CREATE DATABASE Assignment06DB_NRudella;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH


GO
USE Assignment06DB_NRudella;

-- Create Tables (Module 01)-- 
CREATE TABLE Categories (
	[CategoryID]	INT				IDENTITY (1, 1) NOT NULL,
	[CategoryName]	NVARCHAR (100)	NOT NULL
);


GO
CREATE TABLE Products (
	[ProductID]		INT				IDENTITY (1, 1) NOT NULL,
	[ProductName]	NVARCHAR (100)	NOT NULL,
	[CategoryID]	INT				NULL,
	[UnitPrice]		MONEY			NOT NULL
);


GO
CREATE TABLE Employees (
	-- New Table
	[EmployeeID]		INT				IDENTITY (1, 1) NOT NULL,
	[EmployeeFirstName]	NVARCHAR (100)	NOT NULL,
	[EmployeeLastName]	NVARCHAR (100)	NOT NULL,
	[ManagerID]			INT				NULL
);


GO
CREATE TABLE Inventories (
	[InventoryID]	INT		IDENTITY (1, 1) NOT NULL,
	[InventoryDate]	DATE	NOT NULL,
	[EmployeeID]	INT		NOT NULL, -- New Column
	[ProductID]		INT		NOT NULL,
	[Count]			INT		NOT NULL
);


GO
-- Add Constraints (Module 02) -- 
BEGIN
	-- Categories
	ALTER TABLE Categories
		ADD CONSTRAINT pkCategories PRIMARY KEY (CategoryId);
	ALTER TABLE Categories
		ADD CONSTRAINT ukCategories UNIQUE (CategoryName);
END


GO
BEGIN
	-- Products
	ALTER TABLE Products
		ADD CONSTRAINT pkProducts PRIMARY KEY (ProductId);
	ALTER TABLE Products
		ADD CONSTRAINT ukProducts UNIQUE (ProductName);
	ALTER TABLE Products
		ADD CONSTRAINT fkProductsToCategories FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId);
	ALTER TABLE Products
		ADD CONSTRAINT ckProductUnitPriceZeroOrHigher CHECK (UnitPrice >= 0);
END


GO
BEGIN
	-- Employees
	ALTER TABLE Employees
		ADD CONSTRAINT pkEmployees PRIMARY KEY (EmployeeId);
	ALTER TABLE Employees
		ADD CONSTRAINT fkEmployeesToEmployeesManager FOREIGN KEY (ManagerId) REFERENCES Employees (EmployeeId);
END


GO
BEGIN
	-- Inventories
	ALTER TABLE Inventories
		ADD CONSTRAINT pkInventories PRIMARY KEY (InventoryId);
	ALTER TABLE Inventories
		ADD CONSTRAINT dfInventoryDate DEFAULT GetDate() FOR InventoryDate;
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToProducts FOREIGN KEY (ProductId) REFERENCES Products (ProductId);
	ALTER TABLE Inventories
		ADD CONSTRAINT ckInventoryCountZeroOrHigher CHECK ([Count] >= 0);
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToEmployees FOREIGN KEY (EmployeeId) REFERENCES Employees (EmployeeId);
END


GO
-- Adding Data (Module 04) -- 
INSERT	INTO Categories (
	CategoryName
)
SELECT		CategoryName
FROM		Northwind.dbo.Categories
ORDER BY	CategoryID;


GO
INSERT	INTO Products (
	ProductName,
	CategoryID,
	UnitPrice
)
SELECT		ProductName,
			CategoryID,
			UnitPrice
FROM		Northwind.dbo.Products
ORDER BY	ProductID;


GO
INSERT	INTO Employees (
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
)
SELECT		E.FirstName,
			E.LastName,
			IsNull(E.ReportsTo, E.EmployeeID)
FROM		Northwind.dbo.Employees AS E
ORDER BY	E.EmployeeID;


GO
INSERT	INTO Inventories (
	InventoryDate,
	EmployeeID,
	ProductID,
	[Count]
)
SELECT		'20170101' AS InventoryDate,
			5 AS EmployeeID,
			ProductID,
			UnitsInStock
FROM		Northwind.dbo.Products
UNION
SELECT		'20170201' AS InventoryDate,
			7 AS EmployeeID,
			ProductID,
			UnitsInStock + 10 -- Using this is to create a made up value
FROM		Northwind.dbo.Products
UNION
SELECT		'20170301' AS InventoryDate,
			9 AS EmployeeID,
			ProductID,
			UnitsInStock + 20 -- Using this is to create a made up value
FROM		Northwind.dbo.Products
ORDER BY	1, 2;


GO
-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT	*
FROM	Categories;


GO
SELECT	*
FROM	Products;


GO
SELECT	*
FROM	Employees;


GO
SELECT	*
FROM	Inventories;


GO
/********************************* Questions and Answers *********************************/
PRINT 'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------';


GO
-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


-- Intermediate Step 1: Inspect table columns and write explicit SELECT statements using 2-part names (dbo.)
/* 
	SELECT CategoryID, CategoryName FROM dbo.Categories;
	SELECT ProductID, ProductName, CategoryID, UnitPrice FROM dbo.Products;
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID FROM dbo.Employees;
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count] FROM dbo.Inventories;
	*/
-- Final Step: Create the four base views with schemabinding: 
GO	


CREATE VIEW dbo.vCategories
WITH SCHEMABINDING
AS
SELECT	CategoryID,
		CategoryName
FROM	dbo.Categories;


GO
CREATE VIEW dbo.vProducts
WITH SCHEMABINDING
AS
SELECT	ProductID,
		ProductName,
		CategoryID,
		UnitPrice
FROM	dbo.Products;


GO
CREATE VIEW dbo.vEmployees
WITH SCHEMABINDING
AS
SELECT	EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
FROM	dbo.Employees;


GO
CREATE VIEW dbo.vInventories
WITH SCHEMABINDING
AS
SELECT	InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		[Count]
FROM	dbo.Inventories;


GO
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?


-- Intermediate Plan: 
-- 1) Use DENY SELECT ON <Table> TO Public so users cannot query physical tables directly. 
-- 2) Use GRANT SELECT ON <View> TO Public so users interact only with the Base Views (Abstraction Layer).
GO


DENY SELECT
	ON dbo.Categories TO PUBLIC;

DENY SELECT
	ON dbo.Products TO PUBLIC;

DENY SELECT
	ON dbo.Employees TO PUBLIC;

DENY SELECT
	ON dbo.Inventories TO PUBLIC;


GO
GRANT SELECT
	ON dbo.vCategories TO PUBLIC;

GRANT SELECT
	ON dbo.vProducts TO PUBLIC;

GRANT SELECT
	ON dbo.vEmployees TO PUBLIC;

GRANT SELECT
	ON dbo.vInventories TO PUBLIC;


GO
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


-- Intermediate Plan (4-step Join Process):
-- 1) Columns wanted: CategoryName, ProductName, UnitPrice
-- 2) Views they live in: dbo.vCategories, dbo.vProducts
-- 3) How they connect: vCategories.CategoryID = vProducts.CategoryID
-- 4) Test intermediate SELECT and add TOP (1000000000) + ORDER BY:
/*
	SELECT 
		c.CategoryName,
		p.ProductName, 
		p.UnitPrice
	FROM dbo.vCategories AS c
	INNER JOIN dbo.vProducts AS p
		ON c.CategoryID = p.CategoryID
	ORDER BY c.CategoryName ASC, p.ProductName ASC;
	*/
-- Final Step: Wrap in CREATE VIEW dbo.vProductsByCategories
GO


CREATE VIEW dbo.vProductsByCategories
WITH SCHEMABINDING
AS
SELECT		TOP (1000000000) c.CategoryName,
							p.ProductName,
							p.UnitPrice
FROM		dbo.vCategories AS c
			INNER JOIN
			dbo.vProducts AS p
			ON c.CategoryID = p.CategoryID
ORDER BY	c.CategoryName ASC, p.ProductName ASC;


GO
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!


-- Intermediate Plan: 
-- 1) Columns Wanted: ProductName, InventoryDate, [Count]
-- 2) Views they live in: dbo.vProducts, dbo.vInventories
-- 3) How they connect: vProducts.ProductID = vInventories.ProductID
-- 4) Test intermediate SELECT and add TOP (1000000000) + ORDER BY: 
/*
	SELECT 
		p.ProductName,
		i.InventoryDate,
		i.[Count]
	FROM dbo.vProducts AS p
	INNER JOIN dbo.vInventories AS i
		ON p.ProductID = i.ProductID
	ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.[Count] ASC;
	*/
-- Final Step: Wrap in CREATE VIEW dbo.vInventoriesByProductsByDates
GO


CREATE VIEW dbo.vInventoriesByProductsByDates
WITH SCHEMABINDING
AS
SELECT		TOP (1000000000) p.ProductName,
							i.InventoryDate,
							i.[Count]
FROM		dbo.vProducts AS p
			INNER JOIN
			dbo.vInventories AS i
			ON p.ProductID = i.ProductID
ORDER BY	p.ProductName ASC, i.InventoryDate ASC, i.[Count] ASC;


GO
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
-- Here is are the rows selected from the view:
-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth


-- Intermediate Plan:
-- 1) Columns Wanted: InventoryDate, EmployeeName (EmployeeFirstName + ' ' + EmployeeLastName)
-- 2) Views they live in: dbo.vInventories, dbo.vEmployees
-- 3) How they connect: vInventories.EmployeeID = vEmployees.EmployeeID
-- 4) Deduplicate using DISTINCT (or GROUP BY) so only 1 row per date is returned: 
/*
	SELECT DISTINCT
	i.InventoryDate,
	[EmployeeName]=e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM dbo.vInventories AS i
	INNER JOIN dbo.vEmployees AS e
	ON i.EmployeeID = e.EmployeeID
	ORDER BY i.InventoryDate ASC;
	*/
-- FINAL STEP: Wrap in CREATE VIEW dbo.vInventoriesByEmployeesByDates
GO


CREATE VIEW dbo.vInventoriesByEmployeesByDates
WITH SCHEMABINDING
AS
SELECT		DISTINCT TOP (1000000000) i.InventoryDate,
									e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [EmployeeName]
FROM		dbo.vInventories AS i
			INNER JOIN
			dbo.vEmployees AS e
			ON i.EmployeeID = e.EmployeeID
ORDER BY	i.InventoryDate ASC;


GO
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!


-- Intermediate Plan:
-- 1) Columns Wanted: CategoryName, ProductName, InventoryDate, [Count]
-- 2) Views they live in: dbo.vCategories, dbo.vProducts, dbo.vInventories
-- 3) How they connect: vCategories.CategoryID = vProducts.CategoryID AND vProducts.ProductID = vInventories.ProductID
-- 4) Test intermediate SELECT and sort by CategoryName, ProductName, InventoryDate, [Count]
/*
SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count]
FROM dbo.vCategories AS c
INNER JOIN dbo.vProducts AS p
ON c.CategoryID = p.CategoryID
INNER JOIN dbo.vInventories AS i
ON p.ProductID = i.ProductID
ORDER BY 
	c.CategoryName ASC,
	p.ProductName ASC,
	i.InventoryDate ASC,
	i.[Count] ASC;
*/
-- FINAL STEP: Wrap in CREATE VIEW dbo.vInventoriesByProductsByCategories
GO


CREATE VIEW dbo.vInventoriesByProductsByCategories
WITH SCHEMABINDING
AS
SELECT		TOP (1000000000) c.CategoryName,
							p.ProductName,
							i.InventoryDate,
							i.[Count]
FROM		dbo.vCategories AS c
			INNER JOIN
			dbo.vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			dbo.vInventories AS i
			ON p.ProductID = i.ProductID
ORDER BY	c.CategoryName ASC, p.ProductName ASC, i.InventoryDate ASC, i.[Count] ASC;


GO
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!


-- Intermediate Work:
-- 1) Columns wanted: CategoryName, ProductName, InventoryDate, [Count], EmployeeName
-- 2) Views they live in:  dbo.vCategories, dbo.vProducts, dbo.vInventories, dbo.vEmployees
-- 3) How they connect: vCategories.CategoryID = vProducts.CategoryID, vProducts.ProductID = vInventories.ProductID,vInventories.EmployeeID = vEmployees.EmployeeID
-- 4) Test intermediate SELECT and sort by InventoryDate, CategoryName, ProductName, EmployeeName:
/*
SELECT
    c.CategoryName,
    p.ProductName,
    i.InventoryDate,
    i.[Count],
    [EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vCategories AS c
INNER JOIN dbo.vProducts AS p
    ON c.CategoryID = p.CategoryID
INNER JOIN dbo.vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN dbo.vEmployees AS e
    ON i.EmployeeID = e.EmployeeID
ORDER BY i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, [EmployeeName] ASC;
*/
-- Final Step: Wrap in CREATE VIEW dbo.vInventoriesByProductsByEmployees
GO


CREATE VIEW dbo.vInventoriesByProductsByEmployees
WITH SCHEMABINDING
AS
SELECT		TOP (1000000000) c.CategoryName,
							p.ProductName,
							i.InventoryDate,
							i.[Count],
							e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [EmployeeName]
FROM		dbo.vCategories AS c
			INNER JOIN
			dbo.vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			dbo.vInventories AS i
			ON p.ProductID = i.ProductID
			INNER JOIN
			dbo.vEmployees AS e
			ON i.EmployeeID = e.EmployeeID
ORDER BY	i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, [EmployeeName] ASC;


GO
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 


-- Intermediate Plan:
-- 1) Write subquery to isolate ProductIDs for 'Chai' and 'Chang' from dbo.vProducts: SELECT ProductID FROM dbo.vProducts WHERE ProductName IN ('Chai', 'Chang')
-- 2) Filter the 4-view join using WHERE p.ProductID IN (...) and sort by InventoryDate, CategoryName, ProductName
/*
SELECT
    c.CategoryName,
    p.ProductName,
    i.InventoryDate,
    i.[Count],
    [EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vCategories AS c
INNER JOIN dbo.vProducts AS p
    ON c.CategoryID = p.CategoryID
INNER JOIN dbo.vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN dbo.vEmployees AS e
    ON i.EmployeeID = e.EmployeeID
WHERE p.ProductID IN (
    SELECT ProductID
    FROM dbo.vProducts
    WHERE ProductName IN ('Chai', 'Chang')
)
ORDER BY i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC;
*/
-- Final Step: Wrap in CREATE VIEW dbo.vInventoriesForChaiAndChangByEmployees
GO


CREATE VIEW dbo.vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING
AS
SELECT		TOP (1000000000) c.CategoryName,
							p.ProductName,
							i.InventoryDate,
							i.[Count],
							e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [EmployeeName]
FROM		dbo.vCategories AS c
			INNER JOIN
			dbo.vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			dbo.vInventories AS i
			ON p.ProductID = i.ProductID
			INNER JOIN
			dbo.vEmployees AS e
			ON i.EmployeeID = e.EmployeeID
WHERE		p.ProductID IN (SELECT	ProductID
							FROM		dbo.vProducts
							WHERE		ProductName IN ('Chai', 'Chang'))
ORDER BY	i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC;


GO
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!


-- Intermediate Plan:
-- 1) Columns wanted: Manager (m.EmployeeFirstName + ' ' + m.EmployeeLastName), Employee (e.EmployeeFirstName + ' ' + e.EmployeeLastName)
-- 2) Views they live in:  dbo.vEmployees AS e (Worker) self-joined to dbo.vEmployees AS m (Manager)
-- 3) How they connect:    ON e.ManagerID = m.EmployeeID (Worker's ManagerID = Manager's EmployeeID)
-- 4) Sort by Manager ASC, Employee ASC to match Figure 7 in Assignment06.pdf:
/*
SELECT
    [Manager]  = m.EmployeeFirstName + ' ' + m.EmployeeLastName,
    [Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vEmployees AS e
INNER JOIN dbo.vEmployees AS m
    ON e.ManagerID = m.EmployeeID
ORDER BY [Manager] ASC, [Employee] ASC;
*/
-- Final Step: Wrap in CREATE VIEW dbo.vEmployeesByManager
GO


CREATE VIEW dbo.vEmployeesByManager
WITH SCHEMABINDING
AS
SELECT		TOP (1000000000) m.EmployeeFirstName + ' ' + m.EmployeeLastName AS [Manager],
							e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [Employee]
FROM		dbo.vEmployees AS e
			INNER JOIN
			dbo.vEmployees AS m
			ON e.ManagerID = m.EmployeeID
ORDER BY	[Manager] ASC, [Employee] ASC;


GO
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.


-- Intermediate Plan:
-- 1) Columns wanted: c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.UnitPrice, i.InventoryID, i.InventoryDate, i.[Count], e.EmployeeID, [Employee], [Manager]
-- 2) Views they live in:  dbo.vCategories (c), dbo.vProducts (p), dbo.vInventories (i), dbo.vEmployees (e - Employee), dbo.vEmployees (m - Manager)
-- 3) How they connect:    c.CategoryID = p.CategoryID, p.ProductID = i.ProductID, i.EmployeeID = e.EmployeeID, e.ManagerID = m.EmployeeID
-- 4) Sort by CategoryID, ProductID, InventoryID, [Employee]:
/*
SELECT
    c.CategoryID,
    c.CategoryName,
    p.ProductID,
    p.ProductName,
    p.UnitPrice,
    i.InventoryID,
    i.InventoryDate,
    i.[Count],
    e.EmployeeID,
    [Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
    [Manager]  = m.EmployeeFirstName + ' ' + m.EmployeeLastName
FROM dbo.vCategories AS c
INNER JOIN dbo.vProducts AS p
    ON c.CategoryID = p.CategoryID
INNER JOIN dbo.vInventories AS i
    ON p.ProductID = i.ProductID
INNER JOIN dbo.vEmployees AS e
    ON i.EmployeeID = e.EmployeeID
INNER JOIN dbo.vEmployees AS m
    ON e.ManagerID = m.EmployeeID
ORDER BY c.CategoryID ASC, p.ProductID ASC, i.InventoryID ASC, [Employee] ASC;
*/
-- Final Step: Wrap in CREATE VIEW dbo.vInventoriesByProductsByCategoriesByEmployees
GO


CREATE VIEW dbo.vInventoriesByProductsByCategoriesByEmployees
WITH SCHEMABINDING
AS
SELECT		TOP (1000000000) c.CategoryID,
							c.CategoryName,
							p.ProductID,
							p.ProductName,
							p.UnitPrice,
							i.InventoryID,
							i.InventoryDate,
							i.[Count],
							e.EmployeeID,
							e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [Employee],
							m.EmployeeFirstName + ' ' + m.EmployeeLastName AS [Manager]
FROM		dbo.vCategories AS c
			INNER JOIN
			dbo.vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			dbo.vInventories AS i
			ON p.ProductID = i.ProductID
			INNER JOIN
			dbo.vEmployees AS e
			ON i.EmployeeID = e.EmployeeID
			INNER JOIN
			dbo.vEmployees AS m
			ON e.ManagerID = m.EmployeeID
ORDER BY	c.CategoryID ASC, p.ProductID ASC, i.InventoryID ASC, [Employee] ASC;


GO
/***************************************************************************************/
-- Test your Views (NOTE: You must change the your view names to match what I have below!)
PRINT 'Note: You will get an error until the views are created!';

SELECT	*
FROM	[dbo].[vCategories];

SELECT	*
FROM	[dbo].[vProducts];

SELECT	*
FROM	[dbo].[vInventories];

SELECT	*
FROM	[dbo].[vEmployees];

SELECT	*
FROM	[dbo].[vProductsByCategories];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByDates];

SELECT	*
FROM	[dbo].[vInventoriesByEmployeesByDates];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByCategories];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByEmployees];

SELECT	*
FROM	[dbo].[vInventoriesForChaiAndChangByEmployees];

SELECT	*
FROM	[dbo].[vEmployeesByManager];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByCategoriesByEmployees];


/***************************************************************************************/