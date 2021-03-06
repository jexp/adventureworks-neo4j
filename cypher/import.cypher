// Create products
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/products.csv" as row
CREATE (:Product {productName: row.ProductName, productNumber: row.ProductNumber, productId: row.ProductID, modelName: row.ProductModelName, standardCost: row.StandardCost, listPrice: row.ListPrice});

// Create vendors
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/vendors.csv" as row
CREATE (:Vendor {vendorName: row.VendorName, vendorNumber: row.AccountNumber, vendorId: row.VendorID, creditRating: row.CreditRating, activeFlag: row.ActiveFlag});

// Create employees
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/employees.csv" as row
CREATE (:Employee {firstName: row.FirstName, lastName: row.LastName, fullName: row.FullName, employeeId: row.EmployeeID, jobTitle: row.JobTitle, organizationLevel: row.OrganizationLevel, maritalStatus: row.MaritalStatus, gender: row.Gender, territoty: row.Territory, country: row.Country, group: row.Group});

// Create customers
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/customers.csv" as row
CREATE (:Customer {firstName: row.FirstName, lastName: row.LastName, fullName: row.FullName, customerId: row.CustomerID});

// Create categories
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/productcategories.csv" as row
CREATE (:Category {categoryName: row.CategoryName, categoryId: row.CategoryID});

// Create sub-categories
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/productsubcategories.csv" as row
CREATE (:SubCategory {subCategoryName: row.SubCategoryName, subCategoryId: row.SubCategoryID});

// Prepare orders
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/orders.csv" AS row
MERGE (order:Order {orderId: row.SalesOrderID}) ON CREATE SET order.orderDate =  row.OrderDate;

// Create indexes for faster lookup
CREATE INDEX ON :Product(productId);
CREATE INDEX ON :Product(productName);
CREATE INDEX ON :Category(categoryId);
CREATE INDEX ON :Category(categoryName);
CREATE INDEX ON :SubCategory(subCategoryId);
CREATE INDEX ON :SubCategory(subCategoryName);
CREATE INDEX ON :Employee(employeeId);
CREATE INDEX ON :Vendor(vendorId);
CREATE INDEX ON :Vendor(vendorName);
CREATE INDEX ON :Customer(customerId);
CREATE INDEX ON :Order(orderId);

// Create relationships: Order to Product
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/orders.csv" AS row
MATCH (order:Order {orderId: row.SalesOrderID})
MATCH (product:Product {productId: row.ProductID})
MERGE (order)-[pu:PRODUCT]->(product)
ON CREATE SET pu.unitPrice = toFloat(row.UnitPrice), pu.quantity = toFloat(row.OrderQty);

// Create relationships: Order to Employee
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/orders.csv" AS row
MATCH (order:Order {orderId: row.SalesOrderID})
MATCH (employee:Employee {employeeId: row.EmployeeID})
MERGE (employee)-[:SOLD]->(order);

// Create relationships: Order to Customer
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/orders.csv" AS row
MATCH (order:Order {orderId: row.SalesOrderID})
MATCH (customer:Customer {customerId: row.CustomerID})
MERGE (customer)-[:PURCHASED]->(order);

// Create relationships: Product to Vendor
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/vendorproduct.csv" AS row
MATCH (product:Product {productId: row.ProductID})
MATCH (vendor:Vendor {vendorId: row.VendorID})
MERGE (vendor)-[:SUPPLIES]->(product);

// Create relationships: Product to SubCategory
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/products.csv" AS row
MATCH (product:Product {productId: row.ProductID})
MATCH (subcategory:SubCategory {subCategoryId: row.SubCategoryID})
MERGE (product)-[:PART_OF_SUBCAT]->(subcategory);

// Create relationships: SubCategory to Category
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/productsubcategories.csv" AS row
MATCH (subcategory:SubCategory {subCategoryId: row.SubCategoryID})
MATCH (category:Category {categoryId: row.CategoryID})
MERGE (subcategory)-[:PART_OF_CAT]->(category);

// Create relationship for employee reporting structure
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/Users/stephanefrechette/Import/AdventureWorksNeo4j/employees.csv" AS row
MATCH (employee:Employee {employeeId: row.EmployeeID})
MATCH (manager:Employee {employeeId: row.ManagerID})
MERGE (employee)-[:REPORTS_TO]->(manager);

// Create an unique constraint on orders
CREATE CONSTRAINT ON (o:Order) ASSERT o.orderID IS UNIQUE;
