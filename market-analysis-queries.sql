create database real_estate_market;

use real_estate_market;

SELECT COUNT(*) 
FROM final_realty_mysql_ready;

SELECT *
FROM final_realty_mysql_ready
LIMIT 5;

SELECT COUNT(*) AS total_properties
FROM final_realty_mysql_ready;

-- CITY-WISE PROPERTY COUNT
SELECT 
    CITY,
    COUNT(*) AS property_count
FROM final_realty_mysql_ready
GROUP BY CITY
ORDER BY property_count DESC;

-- AVERAGE PROPERTY PRICE BY CITY
SELECT 
    CITY,
    ROUND(AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))), 2) AS avg_price
FROM final_realty_mysql_ready
GROUP BY CITY
ORDER BY avg_price DESC;

-- PRICE BY PROPERTY TYPE
SELECT 
    PROPERTY_TYPE,
    ROUND(AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))), 2) AS avg_price
FROM final_realty_mysql_ready
GROUP BY PROPERTY_TYPE
ORDER BY avg_price DESC;

-- BEDROOM ANALYSIS
SELECT 
    BEDROOM_NUM,
    COUNT(*) AS total_properties,
    ROUND(AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))), 2) AS avg_price
FROM final_realty_mysql_ready
GROUP BY BEDROOM_NUM
ORDER BY BEDROOM_NUM;

-- PRICE SEGMENT DISTRIBUTION
SELECT 
    PRICE_SEGMENT,
    COUNT(*) AS total_properties
FROM final_realty_mysql_ready
GROUP BY PRICE_SEGMENT
ORDER BY total_properties DESC;

-- FURNISHED VS UNFURNISHED ANALYSIS
SELECT 
    FURNISH,
    ROUND(AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))), 2) AS avg_price
FROM final_realty_mysql_ready
GROUP BY FURNISH;

-- MOST EXPENSIVE PROPERTY TYPES
SELECT 
    PROPERTY_TYPE,
    MAX(CAST(PRICE_CLEAN AS DECIMAL(15,2))) AS max_price
FROM final_realty_mysql_ready
GROUP BY PROPERTY_TYPE
ORDER BY max_price DESC;

-- TOP 10 MOST EXPENSIVE PROPERTIES
SELECT
    PROPERTY_TYPE,
    CITY,
    BEDROOM_NUM,
    PRICE_SEGMENT,
    CAST(PRICE_CLEAN AS DECIMAL(15,2)) AS property_price
FROM final_realty_mysql_ready
ORDER BY property_price DESC
LIMIT 10;

-- PRICE PER SQFT ANALYSIS
SELECT
    PROPERTY_TYPE,
    ROUND(
        AVG(
            CAST(PRICE_PER_SQFT_ENGINEERED AS DECIMAL(15,2))
        ),2
    ) AS avg_price_per_sqft
FROM final_realty_mysql_ready
GROUP BY PROPERTY_TYPE
ORDER BY avg_price_per_sqft DESC;

-- LUXURY MARKET SHARE
SELECT
    PRICE_SEGMENT,
    COUNT(*) AS total_properties,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM final_realty_mysql_ready),
        2
    ) AS market_share_percentage
FROM final_realty_mysql_ready
GROUP BY PRICE_SEGMENT
ORDER BY market_share_percentage DESC;

-- CITY + PROPERTY TYPE COMBINATION ANALYSIS
SELECT
    CITY,
    PROPERTY_TYPE,
    COUNT(*) AS total_properties,
    ROUND(
        AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))),
        2
    ) AS avg_price
FROM final_realty_mysql_ready
GROUP BY CITY, PROPERTY_TYPE
ORDER BY avg_price DESC;

-- PROPERTY SIZE CATEGORY ANALYSIS
SELECT
    CASE
        WHEN CAST(AREA_CLEAN AS DECIMAL(15,2)) < 1000
            THEN 'Small'
        WHEN CAST(AREA_CLEAN AS DECIMAL(15,2)) BETWEEN 1000 AND 2500
            THEN 'Medium'
        ELSE 'Large'
    END AS property_size,

    COUNT(*) AS total_properties,

    ROUND(
        AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))),
        2
    ) AS avg_price

FROM final_realty_mysql_ready

GROUP BY property_size
ORDER BY avg_price DESC;

-- BEDROOM PREMIUM ANALYSIS
SELECT
    BEDROOM_NUM,

    ROUND(
        AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))),
        2
    ) AS avg_price,

    ROUND(
        AVG(CAST(PRICE_PER_SQFT_ENGINEERED AS DECIMAL(15,2))),
        2
    ) AS avg_price_per_sqft

FROM final_realty_mysql_ready

GROUP BY BEDROOM_NUM
ORDER BY avg_price DESC;

-- PROPERTY PRICE RANKING
SELECT
    PROPERTY_TYPE,
    CITY,
    BEDROOM_NUM,
    PRICE_SEGMENT,
    CAST(PRICE_CLEAN AS DECIMAL(15,2)) AS property_price,

    RANK() OVER (
        ORDER BY CAST(PRICE_CLEAN AS DECIMAL(15,2)) DESC
    ) AS price_rank

FROM final_realty_mysql_ready;

SELECT
    PROPERTY_TYPE,
    CITY,
    CAST(PRICE_CLEAN AS DECIMAL(15,2)) AS property_price,

    RANK() OVER (
        ORDER BY CAST(PRICE_CLEAN AS DECIMAL(15,2)) DESC
    ) AS rank_value,

    DENSE_RANK() OVER (
        ORDER BY CAST(PRICE_CLEAN AS DECIMAL(15,2)) DESC
    ) AS dense_rank_value,

    ROW_NUMBER() OVER (
        ORDER BY CAST(PRICE_CLEAN AS DECIMAL(15,2)) DESC
    ) AS row_number_value

FROM final_realty_mysql_ready;

-- CITY-WISE PROPERTY RANKING
SELECT
    CITY,
    PROPERTY_TYPE,
    BEDROOM_NUM,
    CAST(PRICE_CLEAN AS DECIMAL(15,2)) AS property_price,

    RANK() OVER (
        PARTITION BY CITY
        ORDER BY CAST(PRICE_CLEAN AS DECIMAL(15,2)) DESC
    ) AS city_price_rank

FROM final_realty_mysql_ready;

WITH ranked_properties AS (

    SELECT
        CITY,
        PROPERTY_TYPE,
        BEDROOM_NUM,
        PRICE_SEGMENT,

        CAST(PRICE_CLEAN AS DECIMAL(15,2)) AS property_price,

        RANK() OVER (
            PARTITION BY CITY
            ORDER BY CAST(PRICE_CLEAN AS DECIMAL(15,2)) DESC
        ) AS city_rank

    FROM final_realty_mysql_ready

)

SELECT *
FROM ranked_properties
WHERE city_rank <= 3;

-- INVESTMENT HOTSPOT ANALYSIS
SELECT
    CITY,
    PROPERTY_TYPE,
    COUNT(*) AS total_properties,
    
    ROUND(
        AVG(CAST(PRICE_CLEAN AS DECIMAL(15,2))),
        2
    ) AS avg_price,
    
    ROUND(
        AVG(CAST(PRICE_PER_SQFT_ENGINEERED AS DECIMAL(15,2))),
        2
    ) AS avg_price_per_sqft,
    
    ROUND(
        AVG(CAST(AREA_CLEAN AS DECIMAL(15,2))),
        2
    ) AS avg_area
    
FROM final_realty_mysql_ready

GROUP BY CITY, PROPERTY_TYPE

HAVING total_properties >= 10

ORDER BY avg_price_per_sqft DESC;   