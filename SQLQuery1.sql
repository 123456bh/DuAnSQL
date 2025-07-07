IF DB_ID('MyNewStoreDB') IS NULL
BEGIN
    CREATE DATABASE MyNewStoreDB; 
    PRINT 'Database MyNewStoreDB created successfully.';
END
ELSE
    PRINT 'Database MyNewStoreDB already exists.';
GO

USE MyNewStoreDB; 
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Roles ---';
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL
    DROP TABLE dbo.Roles;
GO
CREATE TABLE dbo.Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(50) NOT NULL UNIQUE
);
PRINT N'Table "Roles" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Categories ---';
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL
    DROP TABLE dbo.Categories;
GO
CREATE TABLE dbo.Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL UNIQUE
);
PRINT N'Table "Categories" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Suppliers ---';
IF OBJECT_ID('dbo.Suppliers', 'U') IS NOT NULL DROP TABLE dbo.Suppliers;
GO
CREATE TABLE dbo.Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(255) NOT NULL UNIQUE,
    ContactPerson NVARCHAR(100) NULL,
    PhoneNumber VARCHAR(20) NULL,
    Email VARCHAR(100) NULL UNIQUE,
    Address NVARCHAR(MAX) NULL
);
PRINT N'Table "Suppliers" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Employees ---';
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Employees;
GO
CREATE TABLE dbo.Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode VARCHAR(20) NOT NULL UNIQUE,
    FullName NVARCHAR(100) NOT NULL,
    Position NVARCHAR(100) NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(256) NOT NULL,
    Salt VARCHAR(128) NOT NULL,
    RoleID INT NULL,
    IsFirstLogin BIT DEFAULT 1,
    PhoneNumber VARCHAR(20) NULL,
    Email VARCHAR(100) NULL UNIQUE,
    CONSTRAINT FK_Employee_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
PRINT N'Table "Employees" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Customers ---';
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL
    DROP TABLE dbo.Customers;
GO
CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerCode VARCHAR(20) NULL UNIQUE,
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NULL UNIQUE,
    Address NVARCHAR(255) NULL,
    Email VARCHAR(100) NULL UNIQUE,
    DateRegistered DATETIME DEFAULT GETDATE()
);
PRINT N'Table "Customers" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Products ---';
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO
CREATE TABLE dbo.Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductCode VARCHAR(20) NOT NULL UNIQUE,
    ProductName NVARCHAR(255) NOT NULL,
    CategoryID INT NULL,
    SellingPrice DECIMAL(18, 2) NOT NULL,
	CostPrice DECIMAL(18, 2) NOT NULL,
    InventoryQuantity INT NOT NULL,
    ProductImage VARBINARY(MAX) NULL,
    Description NVARCHAR(MAX) NULL,
    CONSTRAINT CK_Product_SellingPrice CHECK (SellingPrice >= 0),
	CONSTRAINT CK_Product_CostPrice CHECK (CostPrice >= 0),
    CONSTRAINT CK_Product_InventoryQuantity CHECK (InventoryQuantity >= 0),
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
PRINT N'Table "Products" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Orders ---';
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
    DROP TABLE dbo.Orders;
GO
CREATE TABLE dbo.Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    CustomerID INT NULL,
    EmployeeID INT NOT NULL,
    TotalAmount DECIMAL(18, 2) NOT NULL,
    OrderStatus VARCHAR(50) NULL DEFAULT 'Pending',
    CONSTRAINT CK_Order_TotalAmount CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Order_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID) ON DELETE SET NULL,
    CONSTRAINT FK_Order_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID) ON DELETE NO ACTION
);
PRINT N'Table "Orders" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: OrderDetails ---';
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL
    DROP TABLE dbo.OrderDetails;
GO
CREATE TABLE dbo.OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL,
    Subtotal AS (CONVERT(DECIMAL(18,2), ISNULL(Quantity,0) * ISNULL(UnitPrice,0))) PERSISTED,
    CONSTRAINT CK_OrderDetail_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderDetail_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT FK_OrderDetail_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetail_Product FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID) ON DELETE NO ACTION
);
PRINT N'Table "OrderDetails" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: PurchaseOrders ---';
IF OBJECT_ID('dbo.PurchaseOrders', 'U') IS NOT NULL DROP TABLE dbo.PurchaseOrders;
GO
CREATE TABLE dbo.PurchaseOrders (
    PurchaseOrderID INT PRIMARY KEY IDENTITY(1,1),
    SupplierID INT NOT NULL,
    EmployeeID INT NOT NULL, 
    PurchaseOrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status VARCHAR(50) NOT NULL DEFAULT 'Received',
    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_PurchaseOrder_Supplier FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers(SupplierID) ON DELETE NO ACTION,
    CONSTRAINT FK_PurchaseOrder_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID) ON DELETE NO ACTION
);
PRINT N'Table "PurchaseOrders" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: PurchaseOrderDetails ---';
IF OBJECT_ID('dbo.PurchaseOrderDetails', 'U') IS NOT NULL DROP TABLE dbo.PurchaseOrderDetails;
GO
CREATE TABLE dbo.PurchaseOrderDetails (
    PurchaseOrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    PurchaseOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    ImportPrice DECIMAL(18,2) NOT NULL,
    CONSTRAINT CK_PurchaseDetail_Quantity CHECK (Quantity > 0),
    CONSTRAINT FK_PurchaseDetail_PurchaseOrder FOREIGN KEY (PurchaseOrderID) REFERENCES dbo.PurchaseOrders(PurchaseOrderID) ON DELETE CASCADE,
    CONSTRAINT FK_PurchaseDetail_Product FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID) ON DELETE NO ACTION
);
PRINT N'Table "PurchaseOrderDetails" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Table: Notifications (Corrected Version) ---';
IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL
    DROP TABLE dbo.Notifications;
GO
CREATE TABLE dbo.Notifications (
    NotificationID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(255) NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    SenderID INT NULL,       
    RecipientID INT NULL,    
    IsRead BIT NOT NULL DEFAULT 0,
    RelatedOrderID INT NULL,
    NotificationType VARCHAR(50) NULL,      
    CONSTRAINT FK_Notification_Sender FOREIGN KEY (SenderID) REFERENCES dbo.Employees(EmployeeID) 
        ON DELETE NO ACTION,
    CONSTRAINT FK_Notification_Recipient FOREIGN KEY (RecipientID) REFERENCES dbo.Employees(EmployeeID) 
        ON DELETE NO ACTION,       
    CONSTRAINT FK_Notification_Order FOREIGN KEY (RelatedOrderID) REFERENCES dbo.Orders(OrderID) 
        ON DELETE SET NULL
);
PRINT N'Table "Notifications" created successfully (Corrected).';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Indexes ---';
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_ProductName' AND object_id = OBJECT_ID('dbo.Products'))
    CREATE NONCLUSTERED INDEX IX_Products_ProductName ON dbo.Products(ProductName);
PRINT N'Index "IX_Products_ProductName" created/exists.';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_FullName' AND object_id = OBJECT_ID('dbo.Customers'))
    CREATE NONCLUSTERED INDEX IX_Customers_FullName ON dbo.Customers(FullName);
PRINT N'Index "IX_Customers_FullName" created/exists.';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_OrderDate' AND object_id = OBJECT_ID('dbo.Orders'))
    CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate);
PRINT N'Index "IX_Orders_OrderDate" created/exists.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Inserting Sample Data ---';

IF (SELECT COUNT(*) FROM dbo.Roles) = 0 
BEGIN
    INSERT INTO dbo.Roles (RoleName) VALUES 
    ('Admin'), 
    ('Sales'), 
    ('Warehouse');
    PRINT N'Sample data inserted into Roles.';
END
ELSE
    PRINT N'Roles table already contains data. Skipping sample data insertion.';
GO
-------------------------------------------------------------------------------
IF (SELECT COUNT(*) FROM dbo.Categories) = 0
BEGIN
    INSERT INTO dbo.Categories (CategoryName) VALUES 
    (N'Smartphones & Accessories'), 
    (N'Laptops & Components'), 
    (N'Men''s Fashion'), 
    (N'Women''s Fashion'),
    (N'Home Appliances'),
    (N'Books & Stationery'),
    (N'Sports & Outdoors'),
    (N'Health & Beauty');
    PRINT N'Sample data inserted into Categories.';
END
ELSE
    PRINT N'Categories table already contains data. Skipping sample data insertion.';
GO
-------------------------------------------------------------------------------
IF (SELECT COUNT(*) FROM dbo.Suppliers) = 0
BEGIN
    INSERT INTO dbo.Suppliers (SupplierName, ContactPerson, PhoneNumber, Email, Address) VALUES
    (N'TechDistributors Inc.', N'John Smith', '123-456-7890', 'sales@techdist.com', N'123 Tech Avenue, Silicon Valley, CA'),
    (N'Fashion House Wholesale', N'Jane Doe', '987-654-3210', 'contact@fashionhw.com', N'456 Fashion Blvd, New York, NY');
    PRINT N'Sample data inserted into Suppliers.';
END
ELSE
    PRINT N'Suppliers table already contains data. Skipping.';
GO
-------------------------------------------------------------------------------
IF (SELECT COUNT(*) FROM dbo.Employees) = 0
BEGIN
    DECLARE @AdminRoleID_SampleNew INT = (SELECT RoleID FROM dbo.Roles WHERE RoleName = 'Admin');
    DECLARE @SalesRoleID_SampleNew INT = (SELECT RoleID FROM dbo.Roles WHERE RoleName = 'Sales');
    DECLARE @WarehouseRoleID_SampleNew INT = (SELECT RoleID FROM dbo.Roles WHERE RoleName = 'Warehouse');

    INSERT INTO dbo.Employees (EmployeeCode, FullName, Position, Username, PasswordHash, Salt, RoleID, IsFirstLogin, PhoneNumber, Email) VALUES
    ('EMPNEW01', N'Alice Admin', N'System Administrator', 'admin_new', 'f906b6644b9098696550497281c26c7d0911821697896037073340bd5618b493', 'adminsalt_new123', @AdminRoleID_SampleNew, 0, '0911111111', 'alice.admin@newstore.com'),
    ('EMPNEW02', N'Bob Sales', N'Sales Manager', 'sales_mgr_new', '1f718b571c5f130615c015332176567ca066a95182ea8763481975009806b172', 'salessalt_mgr', @SalesRoleID_SampleNew, 1, '0922222222', 'bob.sales@newstore.com'),
    ('EMPNEW03', N'Charlie SalesRep', N'Sales Representative', 'sales_rep_new', 'a9f53a914c217f80e9f71624d914699e812870295789a5045b38030e63f374e4', 'salessalt_rep', @SalesRoleID_SampleNew, 0, '0933333333', 'charlie.rep@newstore.com'),
    ('EMPNEW04', N'Diana Warehouse', N'Warehouse Supervisor', 'warehouse_sup_new', '4dd98a0184938317a33280f98f7de353cf2791a0831823634a55041fc52059e1', 'warehousesalt_sup', @WarehouseRoleID_SampleNew, 0, '0944444444', 'diana.warehouse@newstore.com'),
    ('EMPNEW05', N'Edward Picker', N'Warehouse Picker', 'picker_new', '075a1e6a7f42168209a8eb93b8ee0886d9299eb2195d3317a83043961619c8eb', 'pickersalt_new', @WarehouseRoleID_SampleNew, 1, '0955555555', 'edward.picker@newstore.com'),
    ('EMPNEW06', N'Fiona Finance', N'Finance Admin (Admin Role)', 'finance_admin_new', '2d60e19a9cb1919a8d89cf24f3623996d44176c8f9064886707838d3b8831e91', 'financesalt_new', @AdminRoleID_SampleNew, 0, '0966666666', 'fiona.finance@newstore.com');
    PRINT N'Sample data inserted into Employees. REMEMBER to replace HASH placeholders.';
END
ELSE
    PRINT N'Employees table already contains data. Skipping sample data insertion.';
GO
-------------------------------------------------------------------------------
IF (SELECT COUNT(*) FROM dbo.Customers) = 0
BEGIN
    INSERT INTO dbo.Customers (CustomerCode, FullName, PhoneNumber, Address, Email) VALUES
    ('CUSN001', N'Michael New A', '0987000001', N'10 New Main St, Anytown, USA', 'michael.new.a@example.com'),
    ('CUSN002', N'Sarah New B', '0912000002', N'20 New Oak Ave, Anytown, USA', 'sarah.new.b@example.com'),
    ('CUSN003', N'David New C', '0923000003', N'30 New Pine Ln, Anytown, USA', 'david.new.c@example.com'),
    ('CUSN004', N'Linda New D', '0934000004', N'40 New Maple Dr, Anytown, USA', 'linda.new.d@example.com'),
    ('CUSN005', N'James New E', '0945000005', N'50 New Birch Rd, Anytown, USA', 'james.new.e@example.com'),
    ('CUSN006', N'Patricia New F', '0956000006', N'60 New Cedar Ct, Anytown, USA', 'patricia.new.f@example.com'),
    ('CUSN007', N'Robert New G', '0967000007', N'70 New Elm St, Anytown, USA', 'robert.new.g@example.com');
    PRINT N'Sample data inserted into Customers.';
END
ELSE
    PRINT N'Customers table already contains data. Skipping sample data insertion.';
GO
-------------------------------------------------------------------------------
IF (SELECT COUNT(*) FROM dbo.Products) = 0
BEGIN
    DECLARE @CatSmartphones INT = (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = N'Smartphones & Accessories');
    DECLARE @CatLaptops INT = (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = N'Laptops & Components');
    DECLARE @CatFashionM INT = (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = N'Men''s Fashion');
    DECLARE @CatHomeApp INT = (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = N'Home Appliances');
    DECLARE @CatBooks INT = (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = N'Books & Stationery');
    DECLARE @CatSports INT = (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = N'Sports & Outdoors');

    INSERT INTO dbo.Products (ProductCode, ProductName, CategoryID, SellingPrice, CostPrice, InventoryQuantity, Description) VALUES
    ('SP001', N'Flagship Phone X', @CatSmartphones, 1200.00, 950.00, 75, N'Latest generation smartphone with AI camera.'),
    ('LP001', N'UltraBook Pro 14', @CatLaptops, 1500.00, 1150.50, 40, N'Thin and light professional laptop.'),
    ('SP002', N'Mid-Range Phone Y', @CatSmartphones, 450.00, 320.75, 120, N'Affordable smartphone with great features.'),
    ('LP002', N'Gaming Laptop Titan', @CatLaptops, 2200.00, 1850.00, 20, N'High-performance gaming laptop with RTX graphics.'),
    ('MF001', N'Men''s Leather Jacket', @CatFashionM, 199.99, 120.00, 60, N'Classic black leather jacket.'),
    ('HA001', N'Smart Coffee Maker', @CatHomeApp, 89.50, 55.25, 90, N'Wi-Fi enabled coffee maker.'),
    ('BK001', N'The Art of Coding', @CatBooks, 29.95, 15.50, 150, N'A comprehensive guide to software development.'),
    ('SO001', N'Yoga Mat Premium', @CatSports, 35.00, 20.00, 200, N'Eco-friendly, non-slip yoga mat.');
    PRINT N'Sample data inserted into Products.';
END
ELSE
    PRINT N'Products table already contains data. Skipping sample data insertion.';
GO
-------------------------------------------------------------------------------
IF (SELECT COUNT(*) FROM dbo.Orders) < 3 
BEGIN
    DECLARE @CustN1 INT = (SELECT CustomerID FROM dbo.Customers WHERE CustomerCode = 'CUSN001');
    DECLARE @CustN2 INT = (SELECT CustomerID FROM dbo.Customers WHERE CustomerCode = 'CUSN002');
    DECLARE @CustN3 INT = (SELECT CustomerID FROM dbo.Customers WHERE CustomerCode = 'CUSN003');

    DECLARE @EmpSalesRepNew INT = (SELECT EmployeeID FROM dbo.Employees WHERE Username = 'sales_rep_new');

    DECLARE @ProdSP001 INT = (SELECT ProductID FROM dbo.Products WHERE ProductCode = 'SP001');
    DECLARE @ProdLP001 INT = (SELECT ProductID FROM dbo.Products WHERE ProductCode = 'LP001');
    DECLARE @ProdMF001 INT = (SELECT ProductID FROM dbo.Products WHERE ProductCode = 'MF001');
    DECLARE @ProdHA001 INT = (SELECT ProductID FROM dbo.Products WHERE ProductCode = 'HA001');

    DECLARE @NewOrderID1 INT, @NewOrderID2 INT, @NewOrderID3 INT;

    -- Đơn hàng 1
    IF @CustN1 IS NOT NULL AND @EmpSalesRepNew IS NOT NULL AND @ProdSP001 IS NOT NULL AND @ProdLP001 IS NOT NULL
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            INSERT INTO dbo.Orders (OrderDate, CustomerID, EmployeeID, TotalAmount, OrderStatus) VALUES (DATEADD(day, -10, GETDATE()), @CustN1, @EmpSalesRepNew, 0, 'Completed');
            SET @NewOrderID1 = SCOPE_IDENTITY();
            INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES (@NewOrderID1, @ProdSP001, 1, (SELECT SellingPrice FROM Products WHERE ProductID = @ProdSP001));
            UPDATE dbo.Products SET InventoryQuantity = InventoryQuantity - 1 WHERE ProductID = @ProdSP001;
            INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES (@NewOrderID1, @ProdLP001, 1, (SELECT SellingPrice FROM Products WHERE ProductID = @ProdLP001));
            UPDATE dbo.Products SET InventoryQuantity = InventoryQuantity - 1 WHERE ProductID = @ProdLP001;
            UPDATE dbo.Orders SET TotalAmount = (SELECT SUM(Subtotal) FROM dbo.OrderDetails WHERE OrderID = @NewOrderID1) WHERE OrderID = @NewOrderID1;
            COMMIT TRANSACTION; PRINT N'Sample Order 1 (NewDB) created for Customer CUSN001.';
        END TRY
        BEGIN CATCH IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; PRINT N'Error creating Sample Order 1 (NewDB): ' + ERROR_MESSAGE(); END CATCH
    END

    -- Đơn hàng 2
    IF @CustN2 IS NOT NULL AND @EmpSalesRepNew IS NOT NULL AND @ProdMF001 IS NOT NULL
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            INSERT INTO dbo.Orders (OrderDate, CustomerID, EmployeeID, TotalAmount, OrderStatus) VALUES (DATEADD(day, -5, GETDATE()), @CustN2, @EmpSalesRepNew, 0, 'Shipped');
            SET @NewOrderID2 = SCOPE_IDENTITY();
            INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES (@NewOrderID2, @ProdMF001, 2, (SELECT SellingPrice FROM Products WHERE ProductID = @ProdMF001));
            UPDATE dbo.Products SET InventoryQuantity = InventoryQuantity - 2 WHERE ProductID = @ProdMF001;
            UPDATE dbo.Orders SET TotalAmount = (SELECT SUM(Subtotal) FROM dbo.OrderDetails WHERE OrderID = @NewOrderID2) WHERE OrderID = @NewOrderID2;
            COMMIT TRANSACTION; PRINT N'Sample Order 2 (NewDB) created for Customer CUSN002.';
        END TRY
        BEGIN CATCH IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; PRINT N'Error creating Sample Order 2 (NewDB): ' + ERROR_MESSAGE(); END CATCH
    END

    -- Đơn hàng 3 (Khách vãng lai)
    IF @EmpSalesRepNew IS NOT NULL AND @ProdHA001 IS NOT NULL
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            INSERT INTO dbo.Orders (OrderDate, CustomerID, EmployeeID, TotalAmount, OrderStatus) VALUES (GETDATE(), NULL, @EmpSalesRepNew, 0, 'Pending'); -- CustomerID is NULL
            SET @NewOrderID3 = SCOPE_IDENTITY();
            INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES (@NewOrderID3, @ProdHA001, 1, (SELECT SellingPrice FROM Products WHERE ProductID = @ProdHA001));
            UPDATE dbo.Products SET InventoryQuantity = InventoryQuantity - 1 WHERE ProductID = @ProdHA001;
            UPDATE dbo.Orders SET TotalAmount = (SELECT SUM(Subtotal) FROM dbo.OrderDetails WHERE OrderID = @NewOrderID3) WHERE OrderID = @NewOrderID3;
            COMMIT TRANSACTION; PRINT N'Sample Order 3 (NewDB) created for Guest Customer.';
        END TRY
        BEGIN CATCH IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; PRINT N'Error creating Sample Order 3 (NewDB): ' + ERROR_MESSAGE(); END CATCH
    END
    PRINT N'Attempted to insert sample orders.';
END
ELSE
    PRINT N'Orders table already contains sufficient sample data or prerequisites missing. Skipping sample order insertion.';
GO

PRINT N'--- Finished inserting sample data. ---';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating Stored Procedures ---';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating User-Defined Table Type: OrderDetailType ---';
IF TYPE_ID('dbo.OrderDetailType') IS NOT NULL
    DROP TYPE dbo.OrderDetailType;
GO
CREATE TYPE dbo.OrderDetailType AS TABLE (
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL
);
GO
PRINT N'UDTT "OrderDetailType" created.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetAllCategories ---';
IF OBJECT_ID('dbo.usp_GetAllCategories', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetAllCategories;
GO
CREATE PROCEDURE dbo.usp_GetAllCategories
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoryID, CategoryName
    FROM dbo.Categories
    ORDER BY CategoryName;
END
GO
PRINT N'Stored Procedure "usp_GetAllCategories" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetAllProductsWithCategory ---';
IF OBJECT_ID('dbo.usp_GetAllProductsWithCategory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetAllProductsWithCategory;
GO
CREATE PROCEDURE dbo.usp_GetAllProductsWithCategory
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.ProductID,
        p.ProductCode,
        p.ProductName,
        p.CategoryID,
        ISNULL(c.CategoryName, N'N/A') AS CategoryName,
        p.SellingPrice,
		p.CostPrice,
        p.InventoryQuantity,
        p.Description
    FROM
        dbo.Products p
    LEFT JOIN
        dbo.Categories c ON p.CategoryID = c.CategoryID
    ORDER BY
        p.ProductName;
END
GO
PRINT N'Stored Procedure "usp_GetAllProductsWithCategory" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_AddProduct ---';
IF OBJECT_ID('dbo.usp_AddProduct', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddProduct;
GO
CREATE PROCEDURE dbo.usp_AddProduct
    @ProductCode VARCHAR(20),
    @ProductName NVARCHAR(255),
    @CategoryID INT,
    @SellingPrice DECIMAL(18,2),
	@CostPrice DECIMAL(18,2),
    @InventoryQuantity INT,
    @Description NVARCHAR(MAX) = NULL,
    @NewProductID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT 1 FROM dbo.Products WHERE ProductCode = @ProductCode)
    BEGIN
        RAISERROR('Product code already exists.', 16, 1);
        RETURN -1;
    END;

    IF @CategoryID IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Categories WHERE CategoryID = @CategoryID)
    BEGIN
        RAISERROR('Category does not exist.', 16, 1);
        RETURN -2;
    END;

    BEGIN TRY
        INSERT INTO dbo.Products
            (ProductCode, ProductName, CategoryID, SellingPrice, CostPrice, InventoryQuantity, Description)
        VALUES
            (@ProductCode, @ProductName, @CategoryID, @SellingPrice, @CostPrice, @InventoryQuantity, @Description);
			
        SET @NewProductID = SCOPE_IDENTITY();
        RETURN 0; 
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        RETURN -99; 
    END CATCH
END
GO
PRINT N'Stored Procedure "usp_AddProduct" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_UpdateProduct ---';
IF OBJECT_ID('dbo.usp_UpdateProduct', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UpdateProduct;
GO
CREATE PROCEDURE dbo.usp_UpdateProduct
    @ProductID INT,
    @ProductCode VARCHAR(20),
    @ProductName NVARCHAR(255),
    @CategoryID INT,
    @SellingPrice DECIMAL(18,2),
	@CostPrice DECIMAL(18,2),
    @InventoryQuantity INT,
    @Description NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM dbo.Products WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR('Product not found.', 16, 1);
        RETURN -3; 
    END;

    IF EXISTS(SELECT 1 FROM dbo.Products WHERE ProductCode = @ProductCode AND ProductID <> @ProductID)
    BEGIN
        RAISERROR('Product code is already in use by another product.', 16, 1);
        RETURN -1; 
    END;

    IF @CategoryID IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Categories WHERE CategoryID = @CategoryID)
    BEGIN
        RAISERROR('Category does not exist.', 16, 1);
        RETURN -2; 
    END;

    BEGIN TRY
        UPDATE dbo.Products
        SET ProductCode = @ProductCode,
            ProductName = @ProductName,
            CategoryID = @CategoryID,
            SellingPrice = @SellingPrice,
			CostPrice = @CostPrice,
            InventoryQuantity = @InventoryQuantity,
            Description = @Description
        WHERE ProductID = @ProductID;

        IF @@ROWCOUNT > 0
            RETURN 0; 
        ELSE          
            RAISERROR('Product found but not updated.', 16, 1); 
            RETURN -3; 
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        RETURN -99; 
    END CATCH
END
GO
PRINT N'Stored Procedure "usp_UpdateProduct" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_DeleteProduct ---';
IF OBJECT_ID('dbo.usp_DeleteProduct', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_DeleteProduct;
GO
CREATE PROCEDURE dbo.usp_DeleteProduct
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM dbo.Products WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR('Product not found.', 16, 1);
        RETURN -3; 
    END;

    IF EXISTS(SELECT 1 FROM dbo.OrderDetails WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR('Product is part of existing orders and cannot be deleted directly. Consider marking as inactive.', 16, 1);
        RETURN -6; 
    END;

	IF EXISTS(SELECT 1 FROM dbo.PurchaseOrderDetails WHERE ProductID = @ProductID) 
	BEGIN 
		RAISERROR('Product has a procurement history and cannot be delete directly. Consider marking as inactive.', 16, 1); 
		RETURN -7;
	END;

    BEGIN TRY
        DELETE FROM dbo.Products
        WHERE ProductID = @ProductID;

        IF @@ROWCOUNT > 0
            RETURN 0; 
        ELSE	
            RAISERROR('Product found but not deleted.', 16, 1);
            RETURN -3;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        RETURN -99; 
    END CATCH
END
GO
PRINT N'Stored Procedure "usp_DeleteProduct" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_VerifyLogin ---';
IF OBJECT_ID('dbo.usp_VerifyLogin', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VerifyLogin;
GO
CREATE PROCEDURE dbo.usp_VerifyLogin
    @Username VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.EmployeeID,
        e.EmployeeCode,
        e.FullName,
        e.Position,
        e.Username,
        e.PasswordHash,
        e.Salt,
        e.RoleID,
        r.RoleName,
        e.IsFirstLogin
    FROM
        dbo.Employees e
    INNER JOIN
        dbo.Roles r ON e.RoleID = r.RoleID
    WHERE
        e.Username = @Username;
END
GO
PRINT N'Stored Procedure "usp_VerifyLogin" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetAllEmployeesWithRoles ---';
IF OBJECT_ID('dbo.usp_GetAllEmployeesWithRoles', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetAllEmployeesWithRoles;
GO
CREATE PROCEDURE dbo.usp_GetAllEmployeesWithRoles
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.EmployeeID,
        e.EmployeeCode,
        e.FullName,
        e.Position,
        e.Username,
        e.RoleID,
        r.RoleName,
        e.IsFirstLogin,
        e.PhoneNumber,
        e.Email
    FROM
        dbo.Employees e
    INNER JOIN
        dbo.Roles r ON e.RoleID = r.RoleID
    ORDER BY
        e.FullName;
END
GO
PRINT N'Stored Procedure "usp_GetAllEmployeesWithRoles" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetAllCustomers ---';
IF OBJECT_ID('dbo.usp_GetAllCustomers', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetAllCustomers;
GO
CREATE PROCEDURE dbo.usp_GetAllCustomers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CustomerID,
        CustomerCode,
        FullName,
        PhoneNumber,
        Address,
        Email,
        DateRegistered
    FROM
        dbo.Customers
    ORDER BY
        FullName;
END
GO
PRINT N'Stored Procedure "usp_GetAllCustomers" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetSalesRevenueByDateRange ---';
IF OBJECT_ID('dbo.usp_GetSalesRevenueByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetSalesRevenueByDateRange;
GO
CREATE PROCEDURE dbo.usp_GetSalesRevenueByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CONVERT(VARCHAR(10), o.OrderDate, 120) AS SaleDate,
        SUM(o.TotalAmount) AS DailyRevenue
    FROM
        dbo.Orders o
    WHERE
        o.OrderDate >= @StartDate AND o.OrderDate < DATEADD(day, 1, @EndDate) -- Includes the whole @EndDate
    GROUP BY
        CONVERT(VARCHAR(10), o.OrderDate, 120)
    ORDER BY
        SaleDate;
END
GO
PRINT N'Stored Procedure "usp_GetSalesRevenueByDateRange" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_CreateOrder ---';
IF OBJECT_ID('dbo.usp_CreateOrder', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateOrder;
GO
CREATE PROCEDURE dbo.usp_CreateOrder
    @CustomerID INT = NULL,
    @EmployeeID INT,
    @OrderDetails dbo.OrderDetailType READONLY,
    @NewOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM @OrderDetails od JOIN dbo.Products p ON od.ProductID = p.ProductID WHERE p.InventoryQuantity < od.Quantity)
        BEGIN
            RAISERROR('One or more products has insufficient stock.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END

        INSERT INTO dbo.Orders (OrderDate, CustomerID, EmployeeID, TotalAmount, OrderStatus) VALUES (GETDATE(), @CustomerID, @EmployeeID, 0, 'Pending');
        SET @NewOrderID = SCOPE_IDENTITY();

        INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity, UnitPrice) SELECT @NewOrderID, ProductID, Quantity, UnitPrice FROM @OrderDetails;

        UPDATE p SET p.InventoryQuantity = p.InventoryQuantity - od.Quantity FROM dbo.Products p JOIN @OrderDetails od ON p.ProductID = od.ProductID;

        DECLARE @TotalAmount DECIMAL(18, 2);
        SELECT @TotalAmount = SUM(Subtotal) FROM dbo.OrderDetails WHERE OrderID = @NewOrderID;
        UPDATE dbo.Orders SET TotalAmount = @TotalAmount WHERE OrderID = @NewOrderID;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
PRINT N'SP "usp_CreateOrder" created/updated.';
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetDashboardKPIs ---';
IF OBJECT_ID('dbo.usp_GetDashboardKPIs', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetDashboardKPIs;
GO
CREATE PROCEDURE dbo.usp_GetDashboardKPIs
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM dbo.Products) AS TotalProducts,
        (SELECT COUNT(*) FROM dbo.Customers) AS TotalCustomers,
        (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = 'Pending') AS PendingOrders,
        ISNULL((SELECT SUM(TotalAmount) FROM dbo.Orders WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)), 0) AS TodayRevenue;
END
GO
PRINT N'SP "usp_GetDashboardKPIs" created/updated.';
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetRevenueLast7Days ---';
IF OBJECT_ID('dbo.usp_GetRevenueLast7Days', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetRevenueLast7Days;
GO
CREATE PROCEDURE dbo.usp_GetRevenueLast7Days
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CAST(OrderDate AS DATE) AS SaleDate,
        SUM(TotalAmount) AS DailyRevenue
    FROM dbo.Orders
    WHERE OrderDate >= DATEADD(day, -7, CAST(GETDATE() AS DATE))
    GROUP BY CAST(OrderDate AS DATE)
    ORDER BY SaleDate;
END
GO
PRINT N'SP "usp_GetRevenueLast7Days" created/updated.';
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetTopSellingProducts ---';
IF OBJECT_ID('dbo.usp_GetTopSellingProducts', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetTopSellingProducts;
GO
CREATE PROCEDURE dbo.usp_GetTopSellingProducts
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 5
        p.ProductName,
        SUM(od.Quantity) AS TotalQuantitySold
    FROM dbo.OrderDetails od
    JOIN dbo.Products p ON od.ProductID = p.ProductID
    GROUP BY p.ProductName
    ORDER BY TotalQuantitySold DESC;
END
GO
PRINT N'SP "usp_GetTopSellingProducts" created/updated.';
GO
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating Stored Procedure: usp_GetNotificationsForEmployee ---';
IF OBJECT_ID('dbo.usp_GetNotificationsForEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetNotificationsForEmployee;
GO
CREATE PROCEDURE dbo.usp_GetNotificationsForEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        n.NotificationID,
        n.Title,
        n.Content,
        n.CreatedAt,
        ISNULL(sender.FullName, 'System') AS SenderName,
        n.IsRead,
        n.RelatedOrderID,
        n.NotificationType
    FROM 
        dbo.Notifications n
    LEFT JOIN 
        dbo.Employees sender ON n.SenderID = sender.EmployeeID
    WHERE 
        n.RecipientID = @EmployeeID OR n.RecipientID IS NULL -- Lấy thông báo gửi riêng và thông báo chung
    ORDER BY 
        n.CreatedAt DESC;
END
GO
PRINT N'Stored Procedure "usp_GetNotificationsForEmployee" created/updated.';
GO

-------------------------------------------------------------------------------
PRINT N'--- Finished creating Stored Procedures. ---';
GO
-------------------------------------------------------------------------------

PRINT N'--- Creating Views ---';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating View: v_ProductDetailsWithCategory ---';
IF OBJECT_ID('dbo.v_ProductDetailsWithCategory', 'V') IS NOT NULL
    DROP VIEW dbo.v_ProductDetailsWithCategory;
GO
-----
CREATE VIEW dbo.v_ProductDetailsWithCategory
AS
SELECT
    p.ProductID,
    p.ProductCode,
    p.ProductName,
    p.CategoryID,
    ISNULL(c.CategoryName, N'N/A') AS CategoryName, 
    p.SellingPrice,
	p.CostPrice,
    p.InventoryQuantity,
    p.Description    
FROM
    dbo.Products p
LEFT JOIN 
    dbo.Categories c ON p.CategoryID = c.CategoryID;
GO
PRINT N'View "v_ProductDetailsWithCategory" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating View: v_OrderSummaryWithDetails ---';
IF OBJECT_ID('dbo.v_OrderSummaryWithDetails', 'V') IS NOT NULL
    DROP VIEW dbo.v_OrderSummaryWithDetails;
GO
-----
CREATE VIEW dbo.v_OrderSummaryWithDetails
AS
SELECT
    o.OrderID,
    o.OrderDate,
    ISNULL(cust.FullName, N'Guest Customer') AS CustomerName,
    emp.FullName AS EmployeeName,
    o.TotalAmount,
    o.OrderStatus,
    (SELECT COUNT(*) FROM dbo.OrderDetails od WHERE od.OrderID = o.OrderID) AS NumberOfItems, 
    (SELECT SUM(ISNULL(od.Quantity, 0)) FROM dbo.OrderDetails od WHERE od.OrderID = o.OrderID) AS TotalQuantityInOrder 
FROM
    dbo.Orders o
INNER JOIN 
    dbo.Employees emp ON o.EmployeeID = emp.EmployeeID
LEFT JOIN 
    dbo.Customers cust ON o.CustomerID = cust.CustomerID;
GO
PRINT N'View "v_OrderSummaryWithDetails" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating View: v_EmployeeDetailsWithRole ---';
IF OBJECT_ID('dbo.v_EmployeeDetailsWithRole', 'V') IS NOT NULL
    DROP VIEW dbo.v_EmployeeDetailsWithRole;
GO
-----
CREATE VIEW dbo.v_EmployeeDetailsWithRole
AS
SELECT
    e.EmployeeID,
    e.EmployeeCode,
    e.FullName,
    e.Position,
    e.Username,
    e.RoleID, 
    ISNULL(r.RoleName, N'N/A') AS RoleName,
    e.IsFirstLogin,
    e.PhoneNumber,
    e.Email    
FROM
    dbo.Employees e
LEFT JOIN 
    dbo.Roles r ON e.RoleID = r.RoleID;
GO
PRINT N'View "v_EmployeeDetailsWithRole" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Creating/Updating View: v_CustomerPurchaseSummary ---';
IF OBJECT_ID('dbo.v_CustomerPurchaseSummary', 'V') IS NOT NULL
    DROP VIEW dbo.v_CustomerPurchaseSummary;
GO
-----
CREATE VIEW dbo.v_CustomerPurchaseSummary
AS
SELECT
    c.CustomerID,
    c.FullName AS CustomerName,
    c.PhoneNumber AS CustomerPhoneNumber,
    c.Email AS CustomerEmail,
    COUNT(o.OrderID) AS TotalOrders,
    ISNULL(SUM(o.TotalAmount), 0) AS TotalSpent
FROM
    dbo.Customers c
LEFT JOIN 
    dbo.Orders o ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.FullName,
    c.PhoneNumber,
    c.Email;
GO
PRINT N'View "v_CustomerPurchaseSummary" created/updated.';
GO
-------------------------------------------------------------------------------
PRINT N'--- Finished creating Views. ---';
GO
-------------------------------------------------------------------------------
PRINT N'====== MyNewStoreDB DATABASE SCRIPT COMPLETED SUCCESSFULLY ======';
GO
-------------------------------------------------------------------------------
SELECT TOP 10 * FROM dbo.v_ProductDetailsWithCategory;
SELECT TOP 10 * FROM dbo.v_OrderSummaryWithDetails ORDER BY OrderDate DESC;
SELECT TOP 10 * FROM dbo.v_EmployeeDetailsWithRole;
SELECT TOP 10 * FROM dbo.v_CustomerPurchaseSummary ORDER BY TotalSpent DESC;
-- SQL để lấy các chỉ số KPI cho Dashboard
EXEC dbo.usp_GetDashboardKPIs;
-- SQL để lấy dữ liệu cho biểu đồ doanh thu 7 ngày
EXEC dbo.usp_GetRevenueLast7Days;

EXEC dbo.usp_GetTopSellingProducts;

---- SQL để lấy 10 đơn hàng gần đây nhất cho Dashboard
--SELECT TOP 10
--    OrderID,
--    OrderDate,
--    CustomerName,
--    EmployeeName,
--    TotalAmount,
--    OrderStatus
--FROM 
--    dbo.v_OrderSummaryWithDetails
--ORDER BY 
--    OrderDate DESC;

-- SQL để lấy danh sách thông báo cho Admin (EmployeeID = 1)
DECLARE @AdminEmployeeID INT = 1; -- ID này sẽ được lấy từ thông tin đăng nhập của người dùng

EXEC dbo.usp_GetNotificationsForEmployee @EmployeeID = @AdminEmployeeID;

USE MyNewStoreDB;
GO
EXEC dbo.usp_GetDashboardKPIs;
GO
-------------------------------------------------------------------------------
SELECT * FROM dbo.Employees WHERE Username = 'admin_new';
-------------------------------------------------------------------------------
USE MyNewStoreDB;
GO

UPDATE dbo.Employees
SET PasswordHash = '5c5f75bf8697608c0c0f5296df7008acdb0bab6abd416e598ebf97bea3043e2d'
WHERE Username = 'admin_new';

PRINT 'Password hash for admin_new has been updated successfully!';
GO
-------
SELECT * from Products
-------
EXEC sp_help 'dbo.Products';
-------
USE MyNewStoreDB;
GO

-- Bước 1: Khai báo biến để lưu trữ mật khẩu của admin
DECLARE @AdminPasswordHash VARCHAR(256);
DECLARE @AdminSalt VARCHAR(128);

-- Bước 2: Lấy thông tin hash và salt của tài khoản admin_new
-- Script này sẽ tìm tài khoản có Username là 'admin_new' và lấy mật khẩu đã được mã hóa của nó.
SELECT 
    @AdminPasswordHash = PasswordHash, 
    @AdminSalt = Salt 
FROM 
    dbo.Employees 
WHERE 
    Username = 'admin_new';

-- Bước 3: Kiểm tra xem đã lấy được thông tin chưa, sau đó cập nhật cho các tài khoản khác
IF @AdminPasswordHash IS NOT NULL AND @AdminSalt IS NOT NULL
BEGIN
    -- Cập nhật mật khẩu cho tất cả các tài khoản nhân viên khác admin_new
    UPDATE dbo.Employees
    SET 
        PasswordHash = @AdminPasswordHash,
        Salt = @AdminSalt
    WHERE 
        Username <> 'admin_new'; -- Dấu <> có nghĩa là "không bằng"

    PRINT 'SUCCESS: All other employee accounts have been updated to use the same password as admin_new.';
    PRINT 'You can now log in to accounts like "sales_mgr_new" or "warehouse_sup_new" using the admin password.';
END
ELSE
BEGIN
    -- In ra lỗi nếu không tìm thấy tài khoản admin_new
    PRINT 'ERROR: Could not find the user "admin_new" or its password information. No accounts were updated.';
END
GO

-- (Tùy chọn) Kiểm tra lại kết quả sau khi chạy
SELECT Username, PasswordHash, Salt, RoleID FROM dbo.Employees;

-----------
-----------
-----------
USE MyNewStoreDB;
GO

PRINT N'--- Creating/Updating Stored Procedure: usp_AddEmployee ---';
IF OBJECT_ID('dbo.usp_AddEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddEmployee;
GO
CREATE PROCEDURE dbo.usp_AddEmployee
    @EmployeeCode VARCHAR(20),
    @FullName NVARCHAR(100),
    @Position NVARCHAR(100),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(256),
    @Salt VARCHAR(128),
    @RoleID INT,
	@IsFirstLogin BIT = 1,
    @PhoneNumber VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL,
    @NewEmployeeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra các giá trị UNIQUE
    IF EXISTS(SELECT 1 FROM dbo.Employees WHERE Username = @Username)
    BEGIN
        RAISERROR('Username already exists.', 16, 1);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM dbo.Employees WHERE EmployeeCode = @EmployeeCode)
    BEGIN
        RAISERROR('Employee code already exists.', 16, 1);
        RETURN;
    END
    IF @Email IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Employees WHERE Email = @Email)
    BEGIN
        RAISERROR('Email is already in use by another employee.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.Employees 
        (EmployeeCode, FullName, Position, Username, PasswordHash, Salt, RoleID, PhoneNumber, Email, IsFirstLogin)
    VALUES 
        (@EmployeeCode, @FullName, @Position, @Username, @PasswordHash, @Salt, @RoleID, @PhoneNumber, @Email, @IsFirstLogin); -- Mặc định IsFirstLogin là 1 cho nhân viên mới

    SET @NewEmployeeID = SCOPE_IDENTITY();
END
GO
PRINT N'Stored Procedure "usp_AddEmployee" created successfully.';
GO

-------------------------------------------------------------------------------

PRINT N'--- Creating/Updating Stored Procedure: usp_UpdateEmployee ---';
IF OBJECT_ID('dbo.usp_UpdateEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UpdateEmployee;
GO
CREATE PROCEDURE dbo.usp_UpdateEmployee
    @EmployeeID INT,
    @EmployeeCode VARCHAR(20),
    @FullName NVARCHAR(100),
    @Position NVARCHAR(100),
    @RoleID INT,
    @PhoneNumber VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra các giá trị UNIQUE (không phải của chính nhân viên này)
    IF EXISTS(SELECT 1 FROM dbo.Employees WHERE EmployeeCode = @EmployeeCode AND EmployeeID <> @EmployeeID)
    BEGIN
        RAISERROR('Employee code is already in use by another employee.', 16, 1);
        RETURN;
    END
    IF @Email IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Employees WHERE Email = @Email AND EmployeeID <> @EmployeeID)
    BEGIN
        RAISERROR('Email is already in use by another employee.', 16, 1);
        RETURN;
    END

    UPDATE dbo.Employees
    SET
        EmployeeCode = @EmployeeCode,
        FullName = @FullName,
        Position = @Position,
        RoleID = @RoleID,
        PhoneNumber = @PhoneNumber,
        Email = @Email
    WHERE
        EmployeeID = @EmployeeID;
END
GO
PRINT N'Stored Procedure "usp_UpdateEmployee" created successfully.';
GO

-------------------------------------------------------------------------------

PRINT N'--- Creating/Updating Stored Procedure: usp_DeleteEmployee ---';
IF OBJECT_ID('dbo.usp_DeleteEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_DeleteEmployee;
GO
CREATE PROCEDURE dbo.usp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Thêm kiểm tra để không cho xóa nhân viên nếu họ đã có đơn hàng
    IF EXISTS (SELECT 1 FROM dbo.Orders WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Cannot delete this employee. They are associated with existing orders. Consider deactivating the account instead.', 16, 1);
        RETURN;
    END

    -- Thêm kiểm tra để không cho xóa nhân viên nếu họ đã có đơn nhập hàng
    IF EXISTS (SELECT 1 FROM dbo.PurchaseOrders WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Cannot delete this employee. They are associated with existing purchase orders. Consider deactivating the account instead.', 16, 1);
        RETURN;
    END

    DELETE FROM dbo.Employees
    WHERE EmployeeID = @EmployeeID;
END
GO
PRINT N'Stored Procedure "usp_DeleteEmployee" created successfully.';
GO

------------
------------
-----------
USE MyNewStoreDB;
GO

PRINT N'--- Creating/Updating Stored Procedure: usp_AddCustomer ---';
IF OBJECT_ID('dbo.usp_AddCustomer', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddCustomer;
GO
CREATE PROCEDURE dbo.usp_AddCustomer
    @CustomerCode VARCHAR(20) = NULL,
    @FullName NVARCHAR(100),
    @PhoneNumber VARCHAR(20) = NULL,
    @Address NVARCHAR(255) = NULL,
    @Email VARCHAR(100) = NULL,
    @NewCustomerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra các ràng buộc duy nhất
    IF @PhoneNumber IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Customers WHERE PhoneNumber = @PhoneNumber)
    BEGIN
        RAISERROR('Phone number already exists for another customer.', 16, 1);
        RETURN;
    END
    IF @Email IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Customers WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already exists for another customer.', 16, 1);
        RETURN;
    END
    IF @CustomerCode IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Customers WHERE CustomerCode = @CustomerCode)
    BEGIN
        RAISERROR('Customer code already exists for another customer.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.Customers (CustomerCode, FullName, PhoneNumber, Address, Email, DateRegistered)
    VALUES (@CustomerCode, @FullName, @PhoneNumber, @Address, @Email, GETDATE());

    SET @NewCustomerID = SCOPE_IDENTITY();
END
GO
PRINT N'Stored Procedure "usp_AddCustomer" created successfully.';
GO

-------------------------------------------------------------------------------

PRINT N'--- Creating/Updating Stored Procedure: usp_UpdateCustomer ---';
IF OBJECT_ID('dbo.usp_UpdateCustomer', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UpdateCustomer;
GO
CREATE PROCEDURE dbo.usp_UpdateCustomer
    @CustomerID INT,
    @CustomerCode VARCHAR(20) = NULL,
    @FullName NVARCHAR(100),
    @PhoneNumber VARCHAR(20) = NULL,
    @Address NVARCHAR(255) = NULL,
    @Email VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra các ràng buộc duy nhất (không phải của chính khách hàng này)
    IF @PhoneNumber IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Customers WHERE PhoneNumber = @PhoneNumber AND CustomerID <> @CustomerID)
    BEGIN
        RAISERROR('Phone number is already in use by another customer.', 16, 1);
        RETURN;
    END
    IF @Email IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Customers WHERE Email = @Email AND CustomerID <> @CustomerID)
    BEGIN
        RAISERROR('Email is already in use by another customer.', 16, 1);
        RETURN;
    END
    IF @CustomerCode IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Customers WHERE CustomerCode = @CustomerCode AND CustomerID <> @CustomerID)
    BEGIN
        RAISERROR('Customer code is already in use by another customer.', 16, 1);
        RETURN;
    END

    UPDATE dbo.Customers
    SET
        CustomerCode = @CustomerCode,
        FullName = @FullName,
        PhoneNumber = @PhoneNumber,
        Address = @Address,
        Email = @Email
    WHERE
        CustomerID = @CustomerID;
END
GO
PRINT N'Stored Procedure "usp_UpdateCustomer" created successfully.';
GO

-------------------------------------------------------------------------------

PRINT N'--- Creating/Updating Stored Procedure: usp_DeleteCustomer ---';
IF OBJECT_ID('dbo.usp_DeleteCustomer', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_DeleteCustomer;
GO
CREATE PROCEDURE dbo.usp_DeleteCustomer
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- An toàn hơn: Không cho xóa khách hàng nếu họ đã có đơn hàng
    -- Thay vào đó, bạn có thể thêm một cột IsActive BIT và chỉ cập nhật nó thành 0
    IF EXISTS(SELECT 1 FROM dbo.Orders WHERE CustomerID = @CustomerID)
    BEGIN
        RAISERROR('Cannot delete customer. They have existing orders. Consider deactivating the customer instead.', 16, 1);
        RETURN;
    END

    DELETE FROM dbo.Customers
    WHERE CustomerID = @CustomerID;
END
GO
PRINT N'Stored Procedure "usp_DeleteCustomer" created successfully.';
GO

---------
---------
---------
USE MyNewStoreDB;
GO

PRINT N'--- Creating/Updating Stored Procedure: usp_AddCategory ---';
IF OBJECT_ID('dbo.usp_AddCategory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddCategory;
GO
CREATE PROCEDURE dbo.usp_AddCategory
    @CategoryName NVARCHAR(100),
    @NewCategoryID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM dbo.Categories WHERE CategoryName = @CategoryName)
    BEGIN
        RAISERROR('Category name already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.Categories (CategoryName)
    VALUES (@CategoryName);

    SET @NewCategoryID = SCOPE_IDENTITY();
END
GO
PRINT N'Stored Procedure "usp_AddCategory" created successfully.';
GO

-------------------------------------------------------------------------------

PRINT N'--- Creating/Updating Stored Procedure: usp_UpdateCategory ---';
IF OBJECT_ID('dbo.usp_UpdateCategory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UpdateCategory;
GO
CREATE PROCEDURE dbo.usp_UpdateCategory
    @CategoryID INT,
    @CategoryName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM dbo.Categories WHERE CategoryName = @CategoryName AND CategoryID <> @CategoryID)
    BEGIN
        RAISERROR('Another category with this name already exists.', 16, 1);
        RETURN;
    END

    UPDATE dbo.Categories
    SET CategoryName = @CategoryName
    WHERE CategoryID = @CategoryID;
END
GO
PRINT N'Stored Procedure "usp_UpdateCategory" created successfully.';
GO

-------------------------------------------------------------------------------

PRINT N'--- Creating/Updating Stored Procedure: usp_DeleteCategory ---';
IF OBJECT_ID('dbo.usp_DeleteCategory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_DeleteCategory;
GO
CREATE PROCEDURE dbo.usp_DeleteCategory
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- An toàn: Khi xóa một danh mục, các sản phẩm thuộc danh mục đó sẽ được cập nhật
    -- CategoryID thành NULL, dựa trên thiết lập ON DELETE SET NULL của bạn.
    -- Bạn không cần thêm logic kiểm tra ở đây, nhưng cần biết điều này.
    -- Nếu muốn ngăn chặn việc xóa, bạn có thể thêm kiểm tra như sau:
    /*
    IF EXISTS(SELECT 1 FROM dbo.Products WHERE CategoryID = @CategoryID)
    BEGIN
        RAISERROR('Cannot delete category. It is currently in use by one or more products.', 16, 1);
        RETURN;
    END
    */

    DELETE FROM dbo.Categories
    WHERE CategoryID = @CategoryID;
END
GO
PRINT N'Stored Procedure "usp_DeleteCategory" created successfully.';
GO
