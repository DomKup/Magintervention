-- What categories of tech products does Magist have?
SELECT DISTINCT
    p.product_category_name
FROM
    products p
JOIN product_category_name_translation t
	ON p.product_category_name = t.product_category_name
WHERE
	t.product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia');

-- How many products of these tech categories have been sold (within the time window of the database snapshot)?  
-- ANSWER: 16852
SELECT
    count(p.product_category_name) as tech_sales
FROM
    products p
JOIN order_items
	ON p.product_id = order_items.product_id
JOIN product_category_name_translation t
	ON p.product_category_name = t.product_category_name
WHERE
	t.product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia');


-- What’s the average price of the products being sold? 
-- ANSWER: 108,50€ for tech products, 120,65€ in total
SELECT AVG (price) FROM order_items;

SELECT 
    AVG(price)
FROM
    order_items
        JOIN
    products ON order_items.product_id = products.product_id
WHERE
    product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia');

-- Are expensive tech products popular? 
-- ANSWER: 4148 products, 24,6% of total tech sales lie over the average price of 121€
SELECT
    count(product_category_name) as tech_sales
FROM
    products
JOIN order_items
	ON products.product_id = order_items.product_id
WHERE
    product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia')
	AND price >121.00;


-- How many months of data are included in magist database? 
-- ANSWER: 24 months
SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(earliest_date),
        MAX(latest_date)) AS months_between
FROM
    (SELECT 
        MIN(review_answer_timestamp) AS earliest_date,
            MAX(review_answer_timestamp) AS latest_date
    FROM
        order_reviews UNION SELECT 
        MIN(order_delivered_customer_date) AS earliest_date,
            MAX(order_delivered_customer_date) AS latest_date
    FROM
        orders) AS combined_data;

-- How many sellers are there? 
-- ANSWER: 3095 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers;

-- How many Tech sellers are there? 
-- ANSWER: 477
SELECT 
    COUNT(DISTINCT sellers.seller_id) AS tech_seller_count
FROM
    sellers
        JOIN
    order_items ON sellers.seller_id = order_items.seller_id
        JOIN
    products ON order_items.product_id = products.product_id
WHERE
    product_category_name IN ('audio' , 'consoles_games',
        'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer',
        'telefonia');
        
-- What percentage of overall sellers are Tech sellers? 
-- ANSWER: 15,4%
SELECT 
    (COUNT(DISTINCT CASE
            WHEN
                products.product_category_name IN ('audio' , 'consoles_games',
                    'eletronicos',
                    ' pcs',
                    'informatica_acessorios',
                    'pc_gamer',
                    'telefonia')
            THEN
                sellers.seller_id
            ELSE NULL
        END) * 100) / COUNT(DISTINCT sellers.seller_id) AS tech_seller_percentage
FROM
    sellers
        JOIN
    order_items ON sellers.seller_id = order_items.seller_id
        JOIN
    products ON order_items.product_id = products.product_id;

-- What is the total amount earned by all sellers? 
-- ANSWER: 16.008.872€
SELECT 
    SUM(payment_value)
FROM
    order_payments;

-- What is the total amount earned by all Tech sellers? 
-- ANSWER: 2.321.963,9€
SELECT 
    SUM(payment_value) AS tech_earnings
FROM
    order_payments
        JOIN
    order_items ON order_payments.order_id = order_items.order_id
        JOIN
    products ON order_items.product_id = products.product_id
        JOIN
    sellers ON order_items.seller_id = sellers.seller_id
WHERE
    product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia');
        

-- Can you work out the average monthly income of all sellers? 
-- ANSWER: 172,7€ 
SELECT 
    (SUM(payment_value) / COUNT(sellers.seller_id)) AS monthly_income
FROM
    order_payments
        JOIN
    order_items ON order_payments.order_id = order_items.order_id
        JOIN
    sellers ON order_items.seller_id = sellers.seller_id;

-- Can you work out the average monthly income of Tech sellers? 
-- ANSWER: 188€
SELECT 
    (SUM(payment_value) / COUNT(sellers.seller_id)) AS monthly_income
FROM
    order_payments
        JOIN
    order_items ON order_payments.order_id = order_items.order_id
		JOIN
	products ON order_items.product_id = products.product_id
        JOIN
    sellers ON order_items.seller_id = sellers.seller_id
WHERE
	product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia');
        

-- What’s the average time between the order being placed and the product being delivered? 
-- ANSWER: 12,2 days
SELECT 
    AVG(TIME_TO_SEC(TIMEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp)) / 86400) AS avg_delivery_days
FROM
    orders;
    
-- Whats the average delivery time for tech products? 
-- ANSWER: 12,7 days
SELECT 
    AVG(TIME_TO_SEC(TIMEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp)) / 86400) AS avg_delivery_days
FROM 
	orders
JOIN order_items
	ON orders.order_id = order_items.order_id
JOIN products
	ON order_items.product_id = products.product_id
WHERE
    product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia')
	AND order_delivered_customer_date IS NOT NULL
    AND order_purchase_timestamp IS NOT NULL;

--     How many orders are delivered on time vs orders delivered with a delay? 
-- ANSWER: 6535 deliveries delayed by at least 24hrs, while 92.906 were delivered on the estimated day or earlier.
SELECT 
    CASE
        WHEN
            (TIME_TO_SEC(TIMEDIFF(order_delivered_customer_date,
                            order_estimated_delivery_date))) > 86400
        THEN
            'The deliveries were delayed'
        ELSE 'The deliveries were on time'
    END AS Timing,
    COUNT(*) AS Amount
FROM
    orders
GROUP BY Timing;

-- Delays filtered for tech products only
SELECT 
    CASE
        WHEN
            (TIME_TO_SEC(TIMEDIFF(order_delivered_customer_date,
                            order_estimated_delivery_date))) > 86400
        THEN
            'The deliveries were delayed'
        ELSE 'The deliveries were on time'
    END AS Timing,
    COUNT(*) AS Amount
FROM
    orders
        JOIN
    order_items ON orders.order_id = order_items.order_id
        JOIN
    products ON order_items.product_id = products.product_id
WHERE
    product_category_name IN ('audio' , 'consoles_games',
        'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer',
        'telefonia')
GROUP BY Timing;

-- Is there any pattern for delayed orders, e.g. big products being delayed more often? 
-- a) standard code
SELECT 
    *
FROM
    orders
        JOIN
    order_payments ON orders.order_id = order_payments.order_id
        JOIN
    order_items ON orders.order_id = order_items.order_id
        JOIN
    products ON order_items.product_id = products.product_id
WHERE
    (TIME_TO_SEC(TIMEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date))) > 86400;
                    
-- b) Delayed deliveries of packages under 10kg
SELECT 
    orders.order_id,
    product_weight_g,
    order_purchase_timestamp,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    product_category_name
FROM
    orders
        JOIN
    order_payments ON orders.order_id = order_payments.order_id
        JOIN
    order_items ON orders.order_id = order_items.order_id
        JOIN
    products ON order_items.product_id = products.product_id
WHERE
    (TIME_TO_SEC(TIMEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date))) > 86400
        AND product_weight_g <= 10000;
    
        
-- Selling trend of profits for tech products
SELECT 
    order_purchase_timestamp,
    payment_value,
    order_payments.order_id
FROM
    order_payments
        JOIN
    orders ON order_payments.order_id = orders.order_id;

SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(earliest_date),
        MAX(latest_date)) AS months_between
FROM
    (SELECT 
        MIN(review_answer_timestamp) AS earliest_date,
            MAX(review_answer_timestamp) AS latest_date
    FROM
        order_reviews UNION SELECT 
        MIN(order_delivered_customer_date) AS earliest_date,
            MAX(order_delivered_customer_date) AS latest_date
    FROM
        orders) AS combined_data;

-- Sales of high end tech products: 1.820.974€ from 2.869.170€ in all tech
SELECT 
    SUM(payment_value) AS tech_earnings
FROM
    order_payments
        JOIN
    order_items ON order_payments.order_id = order_items.order_id
        JOIN
    products ON order_items.product_id = products.product_id
        JOIN
    sellers ON order_items.seller_id = sellers.seller_id
WHERE
    product_category_name IN ('audio', 'consoles_games' , 'eletronicos',
        'pcs',
        'informatica_acessorios',
        'pc_gamer', 'telefonia')
	AND
		payment_value > 200;
