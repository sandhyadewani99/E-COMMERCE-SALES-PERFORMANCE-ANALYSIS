 -- =================================================================================================================================================================
  -- ### PROJECT NAME: E-COMMERCE SALES PERFORMANCE ANALYSIS ###
  -- ==========================================================================================================================================
  
  -- (1): CREATE DATABASE AND TABLES
create database Ecommerce_Sales_Performance_Analysis;
use Ecommerce_Sales_Performance_Analysis;

 -- # CREate TABLES
create table people(
Person_name varchar (50),
Region varchar (50));
select * from people;
SELECT COUNT(*) FROM people;

create table Returns(
returned varchar(20),
order_Id varchar(50) primary key,
region varchar(50));
select * from Returns;
SELECT COUNT(*) FROM  Returns;

create table Sales(
Order_Id varchar(50),
Order_Date varchar(50),
Ship_Date varchar(50),
Shipment_Days int,
Ship_Mode varchar(50),
Segment varchar(50),
City varchar(50),
State varchar(50),
Product_Id varchar(50),
Category varchar(50),
Sub_Category varchar(50),
Sales   DECIMAL(10,2),
Quantity int,
Profit  DECIMAL(10,2),
Shipping_Cost  DECIMAL(10,2),
Order_Priority  varchar(50));

select * from Sales;

 -- =========================================================================================================================================
 -- "KEY BUSINESS QUESTION”
 -- ===========================================================================================================================================
 
 -- Q1. Which Product Categories Are Performing Below And Above The Overall Business Profit Margin?
 
 -- (1): Overall Business Profit Margin
select round(sum(profit)/sum(sales)*100, 2) as Overall_Profit_Margin 
from sales;

 -- (2): Category-wise Sales & Profit
select category, round(sum(sales),2) as total_sales, 
round(sum(profit),2) as total_profit 
from sales 
group by category;

 -- (3): Category-wise Profit Margin
select category, round(sum(profit)/sum(sales)*100, 2) as Profit_Margin
from sales 
group by category;

 -- (4): Final Business Answer
SELECT
    Category,
round(sum(Sales),2) AS Total_Sales,
round(sum(Profit),2) as Total_Profit,
round((sum(Profit)/sum(Sales))*100,2) as Profit_Margin,
case
        when (sum(Profit)/sum(Sales))*100 >
             (select (sum(Profit)/sum(Sales))*100 from Sales)
        then 'Above Average'

        when (sum(Profit)/sum(Sales))*100 <
             (select (sum(Profit)/sum(Sales))*100 from Sales)
        then 'Below Average'

        else 'Equal'
    end as Performance
from Sales
group by Category
order by Profit_Margin desc;

 -- -- (Q2).How Does Shipping Cost Affect Profit Margins Across Different Shipping Modes?
 
 -- 1: Shipping Mode-wise Sales, Profit & Shipping Cost
select Ship_Mode, 
round(sum(sales),2) as total_sales,
round(sum(profit), 2) as total_profit, 
round(sum(Shipping_Cost),2) as total_Shipping_Cost 
from Sales 
group by Ship_Mode; 

 -- 2: Profit Margin by Shipping Mode
select Ship_Mode, 
round(sum(profit)/ sum(sales)*100,2) as profit_margin
from Sales 
group by Ship_Mode
order by profit_margin desc; 

 -- 3: Average Shipping Cost by Shipping Mode 
select Ship_Mode, 
round(avg(Shipping_Cost),2) as avg_Shipping_Cost
from Sales 
group by Ship_Mode
order by avg_Shipping_Cost desc; 

 -- 4: Final Business Analysis
select Ship_Mode, 
round(avg(Shipping_Cost),2) as avg_Shipping_Cost,
round(sum(profit)/ sum(sales)*100,2) as profit_margin,
case 
when (sum(profit)/ sum(sales)) *100 >=
(select (sum(Profit)/sum(Sales))*100 from Sales)
        then 'High Profit Margin'

        else 'Low Profit Margin'
    end as Performance
from Sales 
group by Ship_Mode
order by avg_Shipping_Cost desc; 

 -- (Q3): Which Sub-Categories Are Causing Margin Leakage Within Low-Performing Categories?
 
 -- 1: Category-wise Profit Margin
select Category , 
round(sum(sales),2) as total_sales,
round(sum(profit), 2) as total_profit, 
round(sum(profit)/ sum(sales)*100,2) as profit_margin
from Sales 
group by Category
order by profit_margin;

 -- 2: Sub-Category-wise Profit Margin
select Category , Sub_Category,
round(sum(sales),2) as total_sales,
round(sum(profit), 2) as total_profit, 
round(sum(profit)/ sum(sales)*100,2) as profit_margin
from Sales 
group by Category,Sub_Category
order by profit_margin;

 -- (3): Find Margin Leakage in Low-Performing Categories
select Category , Sub_Category,
round(sum(sales),2) as total_sales,
round(sum(profit), 2) as total_profit, 
round(sum(profit)/ sum(sales)*100,2) as profit_margin
from Sales 
where Category in (
    select Category
    from (
        select
            Category,
            (sum(Profit)/sum(Sales))*100 as margin
        from Sales
        group by Category
        order by Margin
        limit 1
    ) as Low_Category)
group by Category,Sub_Category
order by profit_margin;

 -- (4): Final Business Answer
select Category , Sub_Category,
round(sum(sales),2) as total_sales,
round(sum(profit), 2) as total_profit, 
round(sum(profit)/ sum(sales)*100,2) as profit_margin,
case
        when sum(Profit) < 0 then'Loss Making'
        when (sum(Profit)/sum(Sales))*100 < 10 then 'Low Margin'
        else 'Healthy Margin'
    end as Margin_Status
from Sales
group by Category,Sub_Category
order by profit_margin;


 -- (Q4): Does Longer Delivery Time Negatively Impact Profitability Or Priority Orders?
 
 -- (1): Delivery Time-wise Sales & Profit
select Shipment_Days,
round(sum(sales),2) as total_sales,
round(sum(profit), 2) as total_profit
from Sales
group by Shipment_Days
order by Shipment_Days;

 -- (2): Average Profit by Delivery Time
select Shipment_Days,
round(avg(profit), 2) as avg_profit
from Sales
group by Shipment_Days
order by Shipment_Days;

 -- (3): Delivery Time by Order Priority
select Order_Priority,
round(avg( Shipment_Days),2) as avg_Delivery_Days
from Sales
group by Order_Priority
order by avg_Delivery_Days;

 -- (4): Final Business Analysis
select Order_Priority,
round(avg( Shipment_Days),2) as avg_Delivery_Days,
round(avg(profit), 2) as avg_profit,
case
        when avg(Shipment_Days) > (
            select avg(Shipment_Days)
            from Sales
        )
        then'Long Delivery Time'
        else 'Short Delivery Time'
    end as Delivery_Status
from Sales
group by Order_Priority
order by avg_Delivery_Days;

 -- (5):What Are The Yearly And Monthly Trends In Sales, Profit, And Profit Margin?

 -- (1): 1: Yearly Sales, Profit & Profit Margin
select
year(STR_TO_DATE(Order_Date,'%d-%m-%Y')) as Order_Year,
round(sum(Sales),2) as Total_Sales,
round(sum(Profit),2) as Total_Profit,
round((sum(Profit)/sum(Sales))*100,2) as Profit_Margin
from Sales
group by year(STR_TO_DATE(Order_Date,'%d-%m-%Y'))
order by Order_Year;

 -- (2): Monthly Sales Trend
select month(str_to_date(Order_Date,'%d-%m-%Y')) as Order_Month,
round(sum(Sales),2) as Total_Sales
from Sales
group by Order_Month
order by Order_Month;

 -- (3): Monthly Profit Trend
select month(str_to_date(Order_Date,'%d-%m-%Y')) as Order_Month,
round(sum(Profit),2) as Total_Profit
from Sales
group by Order_Month
order by Order_Month;

 -- (4): Final Business Analysis
select
year(STR_TO_DATE(Order_Date,'%d-%m-%Y')) as Order_Year,
month(str_to_date(Order_Date,'%d-%m-%Y')) as Order_Month,
round(sum(Sales),2) as Total_Sales,
round(sum(Profit),2) as Total_Profit,
round((sum(Profit)/sum(Sales))*100,2) as Profit_Margin
from Sales
group by Order_Year,  Order_Month
order by Order_Year,  Order_Month;

 -- =========================================================================================================================================================================================================

