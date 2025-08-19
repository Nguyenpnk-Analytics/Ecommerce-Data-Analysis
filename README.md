# 🛒 E-Commerce Data Analysis

## 📖 Project Overview
This project analyses an **E-Commerce dataset** to uncover customer behaviour, product performance, and sales trends.  
The goal is to generate actionable business insights, visualise them through dashboards and reports, and provide recommendations to improve sales and enhance the customer experience.

---

## 📂 Dataset

- **Source**: [E-Commerce Behaviour Data from Multi-category Store (Kaggle)](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store)  
- **Size**: ~110 million rows and 9 columns (data from October 2019 to November 2019).  
- **Description**: This dataset contains user behaviour logs from a large multi-category online store (similar to marketplaces like Shopee, Lazada, or Amazon).  
  It records customer interactions such as viewing products, adding them to the basket, and completing purchases.  

### 🔑 Main Fields
- `event_time` – Timestamp when the event occurred (UTC).  
- `event_type` – Type of user action: `view`, `cart`, `remove_from_cart`, `purchase`.  
- `product_id` – Unique identifier of the product.  
- `category_code` – Category hierarchy of the product (e.g. `electronics.smartphone`).  
- `brand` – Brand of the product (e.g. Apple, Samsung, Xiaomi).  
- `price` – Price of the product at the time of event.  
- `user_id` – Anonymised ID of the user performing the event.  
- `user_session` – Unique session ID for tracking user behaviour across multiple events.  

### 📊 Data Characteristics
- Large-scale clickstream dataset (behavioural data, not accounting/financial records).  
- Includes both browsing activity (`view`) and transactional activity (`purchase`).  
- Allows for analysis of:  
  - Conversion funnel (View → Cart → Purchase).  
  - Product and brand performance.  
  - Customer behaviour segmentation.  
  - Seasonal/time-based shopping trends.  

⚠️ **Note**: The dataset does **not** contain cost, shipping, or profit margin information.  
Therefore, only revenue-related insights (not profitability) can be derived.

### 🧹 Data Cleaning & Preparation
- Removed duplicates and null values in key columns (`product_id`, `user_id`, `event_time`).  
- Standardised the date format for consistency.  
- Split the raw CSV file into smaller chunks of 1,000,000 rows each for easier processing.  

---

## 🔎 Workflow

1. **Exploratory Data Analysis (EDA)**  
   - Monitored `event_type` distribution by `category_code` and `event_time`.  
   - Identified active users, browsing time trends, and correlation between views and purchases.  
   - Calculated total revenue by brand, product, and price, as well as average purchase decision time.  
   - Analysed customer behaviour by price range, date, and time to explore ways of increasing immediate purchases.  
   - Compared customer groups based on immediate vs. later purchases.  

2. **Business Questions**  
   - What are the top-selling products?  
   - Which brands generate the highest sales?  
   - How do sales trend over time?  
   - What opportunities exist to increase revenue?  
   - At what times do customers usually make purchases (immediate vs. delayed)?  
   - How long does it take customers to make a purchase decision for each category?  
   - How does price affect purchase decisions?  

3. **Tools Used**  
   - **Python (Pandas)** → Data wrangling, cleaning, and preprocessing.  
   - **PostgreSQL** → Complex queries, aggregation, transformation, and customer segmentation.  
   - **Power BI** → Interactive dashboard creation and storytelling visualisation.  

---

## 📊 Key Insights

- **Overall Performance**  
  - The marketplace generated **485M USD in revenue** during Oct–Nov 2019.  
  - Over **15M unique users** interacted with the store, but only ~0.2–0.5M converted into paying customers.  
  - Smartphones dominated activity with nearly **70% of total events**, making them the core driver of sales.  

- **Sales & Brand Analysis**  
  - **Apple, Samsung, and Xiaomi** contributed the largest revenue share.  
  - Apple led in average product price, while Xiaomi led in purchase volume.  
  - Revenue growth was relatively flat during the 2-month period, suggesting limited short-term seasonality.  

- **Purchasing Habits**  
  - Most purchases were for products priced **under 500 USD**.  
  - The conversion funnel showed a significant gap: many views but few purchases.  
  - Purchase decision time was short for low-price items and much longer for high-value products.  

- **Customer Behaviour**  
  - **Immediate purchases** occurred mostly in the low-price segment (0–500 USD, >84%).  
  - **Later purchases** were more common in higher price ranges (500–1000+ USD).  
  - Peak purchasing hours: **11:00–13:00** (lunch) and **18:00–20:00** (evening).  
  - Purchase activity peaked mid-month and declined toward the month’s end.  

### 💡 Recommendations
- Target **promotions and vouchers** for products priced between 500–1000 USD to capture immediate buyers.  
- Improve price display accuracy to ensure that monitored prices include VAT and additional fees.  
- Focus **marketing campaigns during lunch and evening peak hours** to maximise conversion.  
- Encourage basket-to-purchase conversion with **reminder emails or discount nudges** for items whose **time in cart** is shorter than the average purchase decision time.  
- Collaborate with sellers to expand product variety and stock in **technology and home appliances** categories.   

---

## 📈 Dashboard & Visualisation

- **Interactive Dashboard (Power BI)**: [bit.ly/data-analytics-portfolio](http://bit.ly/3Hz6vJ0)  
- **Preview (static image):**  
  ![Dashboard Preview](assets/dashboard.png)  

---

## ⚙️ Usage

- Open `Ecommerce_Analytics_Dashboard.pbix` with **Power BI Desktop**.  
- Run queries from `SQL_Scripts.sql` using **PostgreSQL** (optional, for replication).  
- Dataset available on [Kaggle](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store).  
