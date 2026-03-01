
Q1: Revenue by Neighbourhood (Active Listings)

SELECT 
    neighbourhood_cleansed AS neighbourhood,
    COUNT(*) AS total_listings,
    
    -- Active listings metrics
    SUM(CASE 
            WHEN estimated_occupancy_l365d > 0 
              OR number_of_reviews_ltm > 0 
            THEN 1 ELSE 0 
        END) AS active_listings,
    SUM(CASE 
            WHEN estimated_occupancy_l365d > 0 
              OR number_of_reviews_ltm > 0 
            THEN price * number_of_reviews ELSE 0 
        END) AS active_estimated_revenue,
    ROUND(AVG(CASE 
            WHEN estimated_occupancy_l365d > 0 
              OR number_of_reviews_ltm > 0 
            THEN price * number_of_reviews 
        END),2) AS active_avg_revenue_per_listing,
    
    -- Inactive listings metrics
    SUM(CASE 
            WHEN estimated_occupancy_l365d = 0 
              AND number_of_reviews_ltm = 0 
            THEN 1 ELSE 0 
        END) AS inactive_listings
     
FROM airbnb_listings
GROUP BY neighbourhood
ORDER BY active_estimated_revenue DESC
LIMIT 10;


Q2: Instant Booking Performance

SELECT
    instant_bookable,
    
    -- Active listings metrics
    SUM(CASE WHEN estimated_occupancy_l365d > 0 
             OR number_of_reviews_ltm > 0 THEN 1 ELSE 0 END) AS active_listings,
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 
             OR number_of_reviews_ltm > 0 THEN number_of_reviews END),2) AS avg_reviews_active,
    SUM(CASE WHEN estimated_occupancy_l365d > 0 
             OR number_of_reviews_ltm > 0 THEN price * number_of_reviews ELSE 0 END) AS estimated_revenue_active,
    
    -- Inactive listings metrics
    SUM(CASE WHEN estimated_occupancy_l365d = 0 
             AND number_of_reviews_ltm = 0 THEN 1 ELSE 0 END) AS inactive_listings
    
FROM airbnb_listings
GROUP BY instant_bookable
ORDER BY estimated_revenue_active DESC;


Q3: Superhost Performance

SELECT 
    CASE WHEN host_is_superhost = TRUE THEN 'Superhost'
	     WHEN host_is_superhost = FALSE THEN 'Non-Superhost'
		 ELSE 'Unknown'
    END AS superhost_status,
    
    -- Active listings metrics
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN 1 ELSE 0 END) AS active_listings,
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price END),2) AS avg_price_active,
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN review_scores_rating END)::numeric,2) AS avg_rating_active,
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN number_of_reviews END),2) AS avg_reviews_active,
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price * number_of_reviews ELSE 0 END) AS estimated_revenue_active,
    
    -- Inactive listings count
    SUM(CASE WHEN estimated_occupancy_l365d = 0 AND number_of_reviews_ltm = 0 THEN 1 ELSE 0 END) AS inactive_listings
    
FROM airbnb_listings
GROUP BY host_is_superhost
ORDER BY estimated_revenue_active DESC;


Q4: Revenue by Price Segment

SELECT 
    CASE 
        WHEN price < 50 THEN 'Low (<50)'
        WHEN price BETWEEN 50 AND 150 THEN 'Medium (50-150)'
        ELSE 'High (>150)'
    END AS price_range,
    
    -- Active listings count
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN 1 ELSE 0 END) AS active_listings,
    
    -- Average reviews and availability for active listings
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN number_of_reviews END),2) AS avg_reviews_active,
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN availability_365 END),2) AS avg_availability_active,
    
    -- Inactive listings count
    SUM(CASE WHEN estimated_occupancy_l365d = 0 AND number_of_reviews_ltm = 0 THEN 1 ELSE 0 END) AS inactive_listings

FROM airbnb_listings
GROUP BY price_range
ORDER BY avg_reviews_active DESC;


Q5: Revenue by Room Type

SELECT 
    room_type,
    
    -- Active listings count
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN 1 ELSE 0 END) AS active_listings,
    
    -- Average price for active listings
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price END),2) AS avg_price_active,
    
    -- Estimated revenue for active listings
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price * number_of_reviews ELSE 0 END) AS estimated_revenue_active,
    
    -- Inactive listings count
    SUM(CASE WHEN estimated_occupancy_l365d = 0 AND number_of_reviews_ltm = 0 THEN 1 ELSE 0 END) AS inactive_listings

FROM airbnb_listings
GROUP BY room_type
ORDER BY estimated_revenue_active DESC;

Q6

SELECT 
    CORR(price, review_scores_rating) AS price_rating_correlation
FROM airbnb_listings
WHERE review_scores_rating IS NOT NULL
  AND (estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0);


Q7: Top 5 Hosts by Revenue

SELECT 
    host_id,
    COUNT(*) AS total_listings,
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 
             THEN price * number_of_reviews ELSE 0 END) AS estimated_revenue_active,
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 
             THEN 1 ELSE 0 END) AS active_listings
FROM airbnb_listings
GROUP BY host_id
ORDER BY estimated_revenue_active DESC
LIMIT 5;


Q8: Availability Performance Groups

SELECT 
    CASE 
        WHEN availability_365 < 90 THEN 'Low Availability'
        WHEN availability_365 BETWEEN 90 AND 250 THEN 'Medium Availability'
        ELSE 'High Availability'
    END AS availability_group,
    
    -- Active listings count
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN 1 ELSE 0 END) AS active_listings,
    
    -- Average reviews and revenue for active listings
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN number_of_reviews END),2) AS avg_reviews_active,
    SUM(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price * number_of_reviews ELSE 0 END) AS estimated_revenue_active,
    
    -- Inactive listings count
    SUM(CASE WHEN estimated_occupancy_l365d = 0 AND number_of_reviews_ltm = 0 THEN 1 ELSE 0 END) AS inactive_listings

FROM airbnb_listings
GROUP BY availability_group
ORDER BY estimated_revenue_active DESC;


Q9: Overpriced Neighbourhoods (Above Avg Price, Below Avg Rating)

SELECT 
    neighbourhood_cleansed AS neighbourhood,
    COUNT(*) AS total_listings,
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price END),2) AS avg_price_active,
    ROUND(AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN review_scores_rating END)::numeric,2) AS avg_rating_active
FROM airbnb_listings
GROUP BY neighbourhood
HAVING AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price END) > (
    SELECT AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN price END) 
    FROM airbnb_listings
)
AND AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN review_scores_rating END) < (
    SELECT AVG(CASE WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN review_scores_rating END) 
    FROM airbnb_listings
)
ORDER BY avg_price_active DESC;


Q10: Revenue Ranking Within Each Neighbourhood

SELECT 
    neighbourhood_cleansed AS neighbourhood,
    id,
    price,
    number_of_reviews,
    (price * number_of_reviews) AS estimated_revenue,
    RANK() OVER (
        PARTITION BY neighbourhood_cleansed
        ORDER BY (price * number_of_reviews) DESC
    ) AS revenue_rank_in_neighbourhood
FROM airbnb_listings
WHERE estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0;


Q11


SELECT
    -- Active vs Inactive classification
    CASE
        WHEN estimated_occupancy_l365d > 0 OR number_of_reviews_ltm > 0 THEN 'Active'
        ELSE 'Inactive'
    END AS listing_status,
    
    COUNT(*) AS total_listings,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(review_scores_rating)::numeric, 2) AS avg_rating,
    ROUND(AVG(availability_365), 2) AS avg_availability,
    SUM(price * number_of_reviews) AS estimated_revenue,
    ROUND(AVG(number_of_reviews), 2) AS avg_reviews

FROM airbnb_listings

GROUP BY listing_status;