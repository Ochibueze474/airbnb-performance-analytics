-- =============================================
-- Indexes for Performance Optimization
-- =============================================

-- Frequently grouped columns
CREATE INDEX idx_neighbourhood_cleansed
ON airbnb_listings(neighbourhood_cleansed);

CREATE INDEX idx_room_type
ON airbnb_listings(room_type);

CREATE INDEX idx_property_type
ON airbnb_listings(property_type);

-- Performance filtering
CREATE INDEX idx_superhost
ON airbnb_listings(host_is_superhost);

CREATE INDEX idx_instant_bookable
ON airbnb_listings(instant_bookable);

-- Revenue-based analysis
CREATE INDEX idx_estimated_revenue
ON airbnb_listings(estimated_revenue_l365d);

CREATE INDEX idx_estimated_occupancy
ON airbnb_listings(estimated_occupancy_l365d);