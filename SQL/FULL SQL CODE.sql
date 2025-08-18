select * 
from public."E-commerce data"

ALTER TABLE public."E-commerce data"
ALTER COLUMN event_time TYPE TIMESTAMP
USING TO_TIMESTAMP(SUBSTRING(event_time FROM 1 FOR 19), 'YYYY-MM-DD HH24:MI:SS');

				--INDEXING

-- indexes creation for event_time and event_type columns
	CREATE INDEX idx_event_type_time 
	ON public."E-commerce data" (event_type, event_time)

-- indexes creation for user_id Column
	CREATE INDEX user_id_idx
	ON public."E-commerce data" (user_id)
		 
-- indexes creation for category_id Column
	CREATE INDEX category_id_idx
	ON public."E-commerce data" (category_id)
 
-- indexes creation for event_type and event_time Column
	CREATE INDEX idx_event_type_time_category 
	ON "E-commerce data"(event_type, event_time, category_id, category_code)


				--DATA EXPLORATION

-- CATEGORY_CODE, EVENT_TYPE, COUNT ?

		--TABLE COUNT EVENT_TYPE BY CATEGORY_CODE
				CREATE VIEW Total_Event_type_by_category_code AS (
				SELECT 
					COALESCE(NULLIF(TRIM(category_code), ''), 'Unknown') AS category_code,
					event_type,
					COUNT(*) AS event_count
				FROM public."E-commerce data"
				GROUP BY 
					COALESCE(NULLIF(TRIM(category_code), ''), 'Unknown'),
					event_type
				ORDER BY 
					CASE 
						WHEN COALESCE(NULLIF(TRIM(category_code), ''), 'Unknown') = 'Unknown' THEN 1
						ELSE 0
					END,
					category_code DESC )
					
-- EVENT_TIME, EVENT_TYPE, COUNT?

							-- TABLE COUNT EVENT_TYPE BY EVENT_TIME
			CREATE VIEW Total_Event_type_by_time_lot AS (
			SELECT 
				CASE
					WHEN EXTRACT(HOUR FROM event_time) = 0  THEN '00–01'
					WHEN EXTRACT(HOUR FROM event_time) = 1  THEN '01–02'
					WHEN EXTRACT(HOUR FROM event_time) = 2  THEN '02–03'
					WHEN EXTRACT(HOUR FROM event_time) = 3  THEN '03–04'
					WHEN EXTRACT(HOUR FROM event_time) = 4  THEN '04–05'
					WHEN EXTRACT(HOUR FROM event_time) = 5  THEN '05–06'
					WHEN EXTRACT(HOUR FROM event_time) = 6  THEN '06–07'
					WHEN EXTRACT(HOUR FROM event_time) = 7  THEN '07–08'
					WHEN EXTRACT(HOUR FROM event_time) = 8  THEN '08–09'
					WHEN EXTRACT(HOUR FROM event_time) = 9  THEN '09–10'
					WHEN EXTRACT(HOUR FROM event_time) = 10 THEN '10–11'
					WHEN EXTRACT(HOUR FROM event_time) = 11 THEN '11–12'
					WHEN EXTRACT(HOUR FROM event_time) = 12 THEN '12–13'		
					WHEN EXTRACT(HOUR FROM event_time) = 13 THEN '13–14'
					WHEN EXTRACT(HOUR FROM event_time) = 14 THEN '14–15'
					WHEN EXTRACT(HOUR FROM event_time) = 15 THEN '15–16'
					WHEN EXTRACT(HOUR FROM event_time) = 16 THEN '16–17'
					WHEN EXTRACT(HOUR FROM event_time) = 17 THEN '17–18'
					WHEN EXTRACT(HOUR FROM event_time) = 18 THEN '18–19'
					WHEN EXTRACT(HOUR FROM event_time) = 19 THEN '19–20'
					WHEN EXTRACT(HOUR FROM event_time) = 20 THEN '20–21'
					WHEN EXTRACT(HOUR FROM event_time) = 21 THEN '21–22'
					WHEN EXTRACT(HOUR FROM event_time) = 22 THEN '22–23'
					WHEN EXTRACT(HOUR FROM event_time) = 23 THEN '23–24'
				END AS time_lot
				,event_type
				,COUNT(*) AS event_count
			FROM public."E-commerce data"
			GROUP BY time_lot, event_type
			ORDER BY time_lot, event_type);	

--TABLE RISING DISTINCT ACTIVE USER PER DAY

			CREATE VIEW Total_User_Active_Per_Day as (
			WITH USER_ID_CTE AS(
				SELECT 
				  event_time::DATE AS event_date,
				  COUNT(DISTINCT user_id) AS unique_users
				FROM public."E-commerce data"
				WHERE event_type <> '' AND event_type IS NOT NULL
				GROUP BY event_date
			)
			SELECT event_date
			,unique_users
			FROM USER_ID_CTE
			ORDER BY event_date);

--TABLE SUFIRING TIME BY DATE?

			CREATE VIEW Avg_Session_Time AS (
			WITH session_durations AS (
			    SELECT
			        user_id,
			        user_session,
			        MIN(event_time) AS session_start,
			        MAX(event_time) AS session_end,
			        EXTRACT(EPOCH FROM MAX(event_time) - MIN(event_time)) / 60 AS session_duration_minutes
			    FROM public."E-commerce data"
			    GROUP BY user_id, user_session
			)
			
			SELECT
			    session_start::DATE AS session_date,
			    ROUND(AVG(session_duration_minutes), 2) AS avg_session_duration_minutes
			FROM session_durations
			GROUP BY session_start::DATE
			ORDER BY session_date);
			
-- TABLE DOANH THU THEO BRAND?/ REVENUE BY BRAND, PRODUCT_ID, PRICE

			CREATE VIEW Brand_Sales_Summary as (
			WITH Revenue_by_ProductId_CTE AS (
			    SELECT 
			        product_id,
			        brand,
			        price,
			        COUNT(*) AS "Total"
			    FROM public."E-commerce data"
			    WHERE event_type = 'purchase'
			    GROUP BY product_id, brand, price
			)
			SELECT 
			    COALESCE(NULLIF(brand, ''), 'Other brands') AS brand,
				product_id,price,
			    SUM(ROUND((price * "Total")::numeric, 3)) AS "Total_Revenue"
			FROM Revenue_by_ProductId_CTE
			GROUP BY COALESCE(NULLIF(brand, ''), 'Other brands'),product_id,price
			ORDER BY 
			    CASE 
			        WHEN COALESCE(NULLIF(brand, ''), 'Other brands') = 'Other brands' THEN 1
			        ELSE 0
			    END,
			    "Total_Revenue" DESC);	

--TABLE TOTAL EVENT_TYPE CLICKING BY PRICE_RANGE

			CREATE VIEW Total_Event_Type_Clicking_by_Price_range as (
			WITH price_buckets AS (
			  SELECT 
				  event_type,
				  CASE
					  WHEN price < 500 THEN '0-500'
					  WHEN price < 1000 THEN '500-1000'
					  WHEN price < 1500 THEN '1000-1500'
					  WHEN price < 2000 THEN '1500-2000'
					  WHEN price < 2500 THEN '2000-2500'
					  ELSE '2500+'
				  END AS price_range
			  FROM public."E-commerce data"
			)
			SELECT 
				price_range,
				event_type,
				COUNT(*) AS total_click
			FROM price_buckets
			GROUP BY price_range, event_type
			ORDER BY 
				CASE price_range
					WHEN '0-500' THEN 0
					WHEN '500-1000' THEN 1
					WHEN '1000-1500' THEN 2
					WHEN '1500-2000' THEN 3
					WHEN '2000-2500' THEN 4
					ELSE 5
				END,
				CASE event_type
					WHEN 'view' THEN 0
					WHEN 'cart' THEN 1
					ELSE 2 
				END)

-- TABLE CORRELATION BETWEEN VIEW AND PURCHASE

CREATE INDEX correlation_ind 
ON public."E-commerce data" (user_id, category_id, product_id,brand, category_code,user_session)

			CREATE VIEW Correlation_view_purchase as (
			WITH views AS (
				SELECT 
					product_id,
					brand,
					category_code,
					event_time::DATE AS event_date,
					COUNT(*) AS view_count
				FROM public."E-commerce data"
				WHERE event_type = 'view'
				GROUP BY product_id, brand, category_code, event_time::DATE
			),
			purchases AS (
				SELECT 
					product_id,
					brand,
					category_code,
					event_time::DATE AS event_date,
					COUNT(*) AS purchase_count
				FROM public."E-commerce data"
				WHERE event_type = 'purchase'
				GROUP BY product_id, brand, category_code, event_time::DATE
			)
			
			SELECT 
				COALESCE(v.event_date, p.event_date) AS event_date,
				COALESCE(v.category_code, p.category_code) AS category_code,
				COALESCE(v.brand, p.brand) AS brand,
				SUM(COALESCE(view_count, 0)) AS view_count,
				SUM(COALESCE(purchase_count, 0)) AS purchase_count
			FROM views v
			FULL OUTER JOIN purchases p
				ON v.product_id = p.product_id 
				AND v.brand = p.brand
				AND v.event_date = p.event_date  
			GROUP BY 
				COALESCE(v.event_date, p.event_date),
				COALESCE(v.category_code, p.category_code),
				COALESCE(v.brand, p.brand)
			HAVING SUM(COALESCE(v.view_count, 0)) > 0
			ORDER BY 1);

		-- ANALYTICS BY PRICE, DATE AND TIME TO INCREASE CUSTOMERS WHO HAVE IMMEDIATELY PURCHASE 
				
--TABLE CUSTOMERS WHO HAVE IMMEDIATELY PURCHASE BY PRICE_RANGE

			CREATE VIEW Immediately_Purchase_By_Price_Range as ( 
			WITH sessions_with_3_events AS (
				SELECT user_id, user_session, category_id
				FROM public."E-commerce data"
				WHERE event_type IN ('view', 'cart', 'purchase')
				GROUP BY user_id, user_session, category_id
				HAVING 
					COUNT(DISTINCT event_type) = 3
			),
			
			view_per_session AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					CASE
						WHEN price < 500 THEN '0-500'
						WHEN price < 1000 THEN '500-1000'
						WHEN price < 1500 THEN '1000-1500'
						WHEN price < 2000 THEN '1500-2000'
						WHEN price < 2500 THEN '2000-2500'
						ELSE '2500+'
					END AS price_range,
					COUNT(*) AS session_view
				FROM public."E-commerce data"
				WHERE event_type = 'view'
				GROUP BY user_id, user_session, category_id,
					CASE
						WHEN price < 500 THEN '0-500'
						WHEN price < 1000 THEN '500-1000'
						WHEN price < 1500 THEN '1000-1500'
						WHEN price < 2000 THEN '1500-2000'
						WHEN price < 2500 THEN '2000-2500'
						ELSE '2500+'
					END
			),
			
			purchase_per_session AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					CASE
						WHEN price < 500 THEN '0-500'
						WHEN price < 1000 THEN '500-1000'
						WHEN price < 1500 THEN '1000-1500'
						WHEN price < 2000 THEN '1500-2000'
						WHEN price < 2500 THEN '2000-2500'
						ELSE '2500+'
					END AS price_range,
					COUNT(*) AS session_purchase
				FROM public."E-commerce data"
				WHERE event_type = 'purchase'
				GROUP BY user_id, user_session, category_id,
					CASE
						WHEN price < 500 THEN '0-500'
						WHEN price < 1000 THEN '500-1000'
						WHEN price < 1500 THEN '1000-1500'
						WHEN price < 2000 THEN '1500-2000'
						WHEN price < 2500 THEN '2000-2500'
						ELSE '2500+'
					END
			)
			
			SELECT 
				vps.price_range,
				--SUM(vps.session_view) AS total_view,
				SUM(pps.session_purchase) AS total_purchase
			FROM sessions_with_3_events s3e
			JOIN view_per_session vps 
				ON s3e.user_id = vps.user_id 
				AND s3e.user_session = vps.user_session 
				AND s3e.category_id = vps.category_id
			JOIN purchase_per_session pps 
				ON s3e.user_id = pps.user_id 
				AND s3e.user_session = pps.user_session 
				AND s3e.category_id = pps.category_id
				AND vps.price_range = pps.price_range
			GROUP BY vps.price_range
			ORDER BY 
				CASE 
					WHEN vps.price_range = '0-500' THEN 1
					WHEN vps.price_range = '500-1000' THEN 2
					WHEN vps.price_range = '1000-1500' THEN 3
					WHEN vps.price_range = '1500-2000' THEN 4
					WHEN vps.price_range = '2000-2500' THEN 5
					ELSE 6
				END);

-- TABLE CUSTOMERS WHO HAVE IMMEDIATELY PURCHASE BY TIME_LOT
	
			CREATE VIEW Immediately_Purchase_By_Time_lot as (
			WITH sessions_with_3_events AS (
				SELECT user_id, user_session, category_id
				FROM public."E-commerce data"
				WHERE event_type IN ('view', 'cart', 'purchase')
				GROUP BY user_id, user_session, category_id
				HAVING 
					COUNT(DISTINCT event_type) = 3
			),
			
			view_per_session AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					CASE
						WHEN EXTRACT(HOUR FROM event_time) = 0  THEN '00–01'
						WHEN EXTRACT(HOUR FROM event_time) = 1  THEN '01–02'
						WHEN EXTRACT(HOUR FROM event_time) = 2  THEN '02–03'
						WHEN EXTRACT(HOUR FROM event_time) = 3  THEN '03–04'
						WHEN EXTRACT(HOUR FROM event_time) = 4  THEN '04–05'
						WHEN EXTRACT(HOUR FROM event_time) = 5  THEN '05–06'
						WHEN EXTRACT(HOUR FROM event_time) = 6  THEN '06–07'
						WHEN EXTRACT(HOUR FROM event_time) = 7  THEN '07–08'
						WHEN EXTRACT(HOUR FROM event_time) = 8  THEN '08–09'
						WHEN EXTRACT(HOUR FROM event_time) = 9  THEN '09–10'
						WHEN EXTRACT(HOUR FROM event_time) = 10 THEN '10–11'
						WHEN EXTRACT(HOUR FROM event_time) = 11 THEN '11–12'
						WHEN EXTRACT(HOUR FROM event_time) = 12 THEN '12–13'		
						WHEN EXTRACT(HOUR FROM event_time) = 13 THEN '13–14'
						WHEN EXTRACT(HOUR FROM event_time) = 14 THEN '14–15'
						WHEN EXTRACT(HOUR FROM event_time) = 15 THEN '15–16'
						WHEN EXTRACT(HOUR FROM event_time) = 16 THEN '16–17'
						WHEN EXTRACT(HOUR FROM event_time) = 17 THEN '17–18'
						WHEN EXTRACT(HOUR FROM event_time) = 18 THEN '18–19'
						WHEN EXTRACT(HOUR FROM event_time) = 19 THEN '19–20'
						WHEN EXTRACT(HOUR FROM event_time) = 20 THEN '20–21'
						WHEN EXTRACT(HOUR FROM event_time) = 21 THEN '21–22'
						WHEN EXTRACT(HOUR FROM event_time) = 22 THEN '22–23'
						WHEN EXTRACT(HOUR FROM event_time) = 23 THEN '23–24'
					END AS time_lot,
					COUNT(*) AS session_view
				FROM public."E-commerce data"
				WHERE event_type = 'view'
				GROUP BY user_id, user_session, category_id, time_lot
			),
			
			purchase_per_session AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					CASE
						WHEN EXTRACT(HOUR FROM event_time) = 0  THEN '00–01'
						WHEN EXTRACT(HOUR FROM event_time) = 1  THEN '01–02'
						WHEN EXTRACT(HOUR FROM event_time) = 2  THEN '02–03'
						WHEN EXTRACT(HOUR FROM event_time) = 3  THEN '03–04'
						WHEN EXTRACT(HOUR FROM event_time) = 4  THEN '04–05'
						WHEN EXTRACT(HOUR FROM event_time) = 5  THEN '05–06'
						WHEN EXTRACT(HOUR FROM event_time) = 6  THEN '06–07'
						WHEN EXTRACT(HOUR FROM event_time) = 7  THEN '07–08'
						WHEN EXTRACT(HOUR FROM event_time) = 8  THEN '08–09'
						WHEN EXTRACT(HOUR FROM event_time) = 9  THEN '09–10'
						WHEN EXTRACT(HOUR FROM event_time) = 10 THEN '10–11'
						WHEN EXTRACT(HOUR FROM event_time) = 11 THEN '11–12'
						WHEN EXTRACT(HOUR FROM event_time) = 12 THEN '12–13'		
						WHEN EXTRACT(HOUR FROM event_time) = 13 THEN '13–14'
						WHEN EXTRACT(HOUR FROM event_time) = 14 THEN '14–15'
						WHEN EXTRACT(HOUR FROM event_time) = 15 THEN '15–16'
						WHEN EXTRACT(HOUR FROM event_time) = 16 THEN '16–17'
						WHEN EXTRACT(HOUR FROM event_time) = 17 THEN '17–18'
						WHEN EXTRACT(HOUR FROM event_time) = 18 THEN '18–19'
						WHEN EXTRACT(HOUR FROM event_time) = 19 THEN '19–20'
						WHEN EXTRACT(HOUR FROM event_time) = 20 THEN '20–21'
						WHEN EXTRACT(HOUR FROM event_time) = 21 THEN '21–22'
						WHEN EXTRACT(HOUR FROM event_time) = 22 THEN '22–23'
						WHEN EXTRACT(HOUR FROM event_time) = 23 THEN '23–24'
					END AS time_lot,
					COUNT(*) AS session_purchase
				FROM public."E-commerce data"
				WHERE event_type = 'purchase'
				GROUP BY user_id, user_session, category_id, time_lot
			)
			
			SELECT 
				vps.time_lot,
			   -- SUM(vps.session_view) AS total_view,
				SUM(pps.session_purchase) AS total_purchase
			FROM sessions_with_3_events s3e
			JOIN view_per_session vps 
				ON s3e.user_id = vps.user_id 
				AND s3e.user_session = vps.user_session 
				AND s3e.category_id = vps.category_id
			JOIN purchase_per_session pps 
				ON s3e.user_id = pps.user_id 
				AND s3e.user_session = pps.user_session 
				AND s3e.category_id = pps.category_id
				AND vps.time_lot = pps.time_lot
			GROUP BY vps.time_lot
			ORDER BY 1)

-- TABLE CUSTOMERS WHO HAVE IMMEDIATELY PURCHASE BY DATE
	
			CREATE VIEW Immediately_Purchase_By_Date as ( 
			WITH sessions_with_3_events AS (
				SELECT user_id, user_session, category_id
				FROM public."E-commerce data"
				WHERE event_type IN ('view', 'cart', 'purchase')
				GROUP BY user_id, user_session, category_id
				HAVING COUNT(DISTINCT event_type) = 3
			),
			
			view_per_session AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					EXTRACT(DAY FROM event_time) AS day,
					COUNT(*) AS session_view
				FROM public."E-commerce data"
				WHERE event_type = 'view'
				GROUP BY user_id, user_session, category_id, day
			),
			
			purchase_per_session AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					EXTRACT(DAY FROM event_time) AS day,
					COUNT(*) AS session_purchase
				FROM public."E-commerce data"
				WHERE event_type = 'purchase'
				GROUP BY user_id, user_session, category_id, day
			)
			
			SELECT 
				vps.day,
				SUM(vps.session_view) AS total_view,
				SUM(pps.session_purchase) AS total_purchase
			FROM sessions_with_3_events s3e
			JOIN view_per_session vps 
				ON s3e.user_id = vps.user_id 
				AND s3e.user_session = vps.user_session 
				AND s3e.category_id = vps.category_id
			JOIN purchase_per_session pps 
				ON s3e.user_id = pps.user_id 
				AND s3e.user_session = pps.user_session 
				AND s3e.category_id = pps.category_id
				AND vps.day = pps.day
			GROUP BY vps.day
			ORDER BY vps.day);

-- TABLE CUSTOMERS WHO HAVE LATER PURCHASE BY PRICE_RANGE

			CREATE VIEW Later_Purchase_By_Price_range as (			
			WITH view_cart_sessions AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					MIN(event_time) AS session_start_time
				FROM public."E-commerce data"
				WHERE event_type IN ('view', 'cart')
				GROUP BY user_id, user_session, category_id
				HAVING COUNT(DISTINCT event_type) = 2
			),
			
			purchase_sessions AS (
				SELECT 
					user_id,
					user_session,
					category_id,
					MIN(event_time) AS purchase_time,
					CASE
						WHEN price < 500 THEN '0-500'
						WHEN price < 1000 THEN '500-1000'
						WHEN price < 1500 THEN '1000-1500'
						WHEN price < 2000 THEN '1500-2000'
						WHEN price < 2500 THEN '2000-2500'
						ELSE '2500+'
					END AS price_range,
					COUNT(*) AS session_purchase
				FROM public."E-commerce data"
				WHERE event_type = 'purchase'
				GROUP BY user_id, user_session, category_id,
					CASE
						WHEN price < 500 THEN '0-500'
						WHEN price < 1000 THEN '500-1000'
						WHEN price < 1500 THEN '1000-1500'
						WHEN price < 2000 THEN '1500-2000'
						WHEN price < 2500 THEN '2000-2500'
						ELSE '2500+'
					END
			),
			
			valid_purchases AS (
				SELECT 
					ps.price_range,
					ps.session_purchase
				FROM purchase_sessions ps
				JOIN view_cart_sessions vcs
					ON ps.user_id = vcs.user_id 
					AND ps.category_id = vcs.category_id
					AND ps.user_session <> vcs.user_session
					AND ps.purchase_time > vcs.session_start_time
			)
			
			SELECT 
				price_range,
				SUM(session_purchase) AS total_purchase
			FROM valid_purchases
			GROUP BY price_range
			ORDER BY 
				CASE 
					WHEN price_range = '0-500' THEN 1
					WHEN price_range = '500-1000' THEN 2
					WHEN price_range = '1000-1500' THEN 3
					WHEN price_range = '1500-2000' THEN 4
					WHEN price_range = '2000-2500' THEN 5
					ELSE 6
				END);

-- AVG PURCHASE DECISION-TIME CALCULATING AFTER VIEWING AND CARTING AT PREVIOUS SESSION (THE FIRST PURCHASING EVENT AFTER VIEWING AND CARTING)

--TABLE AVG PURCHASE DECISION TIME PER CATEGORY

-- CREATE TEMP TABLE "FILTERED_EVENTS" TO FILTER OUT THE NECESSARY EVENTS
				CREATE TEMP TABLE filtered_events AS
				SELECT 
				    user_id,
				    user_session,
				    category_code,
				    event_time,
				    event_type
				FROM "E-commerce data"
				WHERE event_type IN ('view', 'cart', 'purchase');
				
--CREATE TEMP TABLE TO FILTER ALL SESSION WHICH HAVE VIEW AND CART EVENT
					
					CREATE TEMP TABLE view_cart_sessions AS
					SELECT 
					    user_id,
					    user_session,
					    category_code,
					    MIN(event_time) AS session_start_time
					FROM filtered_events
					WHERE event_type IN ('view', 'cart')
					GROUP BY user_id, user_session, category_code
					HAVING COUNT(DISTINCT event_type) = 2;
		
-- FINDING THE FIRST PURCHASE EVENT AFTER RECORDING VIEW AND CART EVENT AT THE SAME SESSION
		
				WITH purchases_after_cart AS (
				    SELECT 
				        vcs.user_id,
				        vcs.user_session AS view_cart_session,
				        vcs.category_code,
				        vcs.session_start_time,
				        fe.user_session AS purchase_session,
				        fe.event_time AS purchase_time,
				        ROW_NUMBER() OVER (
				            PARTITION BY vcs.user_id, vcs.user_session, vcs.category_code
				            ORDER BY fe.event_time
				        ) AS rn
				    FROM view_cart_sessions vcs
				    JOIN filtered_events fe
				      ON fe.user_id = vcs.user_id
				     AND fe.category_code = vcs.category_code
				     AND fe.event_type = 'purchase'
				     AND fe.event_time > vcs.session_start_time
				)
				
				SELECT *
				INTO TEMP valid_purchases
				FROM purchases_after_cart
				WHERE rn = 1;
		
--CALCULATE AVG PURCHASE DECISION TIME PER CATEGORY

			CREATE VIEW Avg_Time_Purchase_Decision as (
			SELECT 
				COALESCE(NULLIF(TRIM(category_code), ''), 'Unknown') AS category_code,
				COUNT(*) AS total_valid_cases,
				ROUND(AVG(EXTRACT(EPOCH FROM (purchase_time - session_start_time)) / 60), 2) AS avg_purchase_decision_time_minutes
			FROM valid_purchases
			GROUP BY 
				COALESCE(NULLIF(TRIM(category_code), ''), 'Unknown')
			ORDER BY 
				(COALESCE(NULLIF(TRIM(category_code), ''), 'Unknown') = 'Unknown') ASC, 
				 total_valid_cases DESC);






