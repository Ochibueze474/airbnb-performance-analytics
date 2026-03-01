# -------------------------------
# 1. Import libraries
# -------------------------------
import pandas as pd           # Data manipulation
import numpy as np            # Numeric operations
import matplotlib.pyplot as plt  # Plotting
import matplotlib.ticker as ticker  # Formatting axes
import seaborn as sns         # Advanced visualizations
import sqlalchemy             # SQL connection
import psycopg2               # PostgreSQL driver


# -------------------------------
# 2. Load raw CSV data
# -------------------------------
df = pd.read_csv(
    'C:/Users/Chibueze/Valentine-Python-Project/PythonProject/Practical/Airbnb_Greece/data/raw/crete_greece.csv.gz',
    compression='gzip'
)


# -------------------------------
# 3. Display settings for better inspection
# -------------------------------
pd.set_option('display.max_columns', None)  # Show all columns
pd.set_option('display.max_rows', 100)     # Show up to 100 rows
pd.set_option('display.width', None)       # No line wrapping

df  # Inspect first few rows


# -------------------------------
# 4. Explore the dataset
# -------------------------------
df.shape         # Number of rows and columns
df.columns       # List of column names
df.info()        # Data types and non null counts
df.describe(include='all')  # Summary statistics


# -------------------------------
# 5. Remove duplicate rows
# -------------------------------
df = df.drop_duplicates()
df.shape  # Check new shape


# -------------------------------
# 6. Check missing values
# -------------------------------
missing_values = df.isna().sum().sort_values(ascending=False)
missing_values  # Identify columns with many missing values


# -------------------------------
# 7. Drop unnecessary or low value columns
# -------------------------------
columns_to_drop = [
    # Completely empty
    'calendar_updated',
    'neighbourhood_group_cleansed',
    
    # High missing / low analytical value
    'host_about',
    'host_neighbourhood',
    'neighbourhood',
    'neighborhood_overview',
    'host_location',
    
    # Scraping / platform metadata
    'listing_url',
    'scrape_id',
    'last_scraped',
    'source',
    
    # Host identity / vanity columns
    'host_name',
    'host_thumbnail_url',
    'host_picture_url',
    
    # Redundant calculated counts
    'calculated_host_listings_count',
    'calculated_host_listings_count_entire_homes',
    'calculated_host_listings_count_private_rooms',
    'calculated_host_listings_count_shared_rooms'
]

df = df.drop(columns=columns_to_drop, errors='ignore')  # Drop safely
df.shape  # Confirm shape


# -------------------------------
# 8. Standardize column names
# -------------------------------
df.columns = (
    df.columns
    .str.strip()           # Remove whitespace
    .str.lower()           # Lowercase all
    .str.replace(" ", "_") # Replace spaces with underscores
)


# -------------------------------
# 9. Clean and convert price column
# -------------------------------
df['price'] = (
    df['price']
    .astype(str)
    .str.replace('$', '', regex=False)  # Remove $ symbol
    .str.replace(',', '', regex=False)  # Remove commas
)

df['price'] = pd.to_numeric(df['price'], errors='coerce')  # Convert to numeric


# -------------------------------
# 10. Convert date columns to datetime
# -------------------------------
date_columns = ['host_since', 'first_review', 'last_review']

for col in date_columns:
    if col in df.columns:
        df[col] = pd.to_datetime(df[col], errors='coerce')  # Coerce errors to NaT


# -------------------------------
# 11. Fill missing reviews_per_month with 0
# -------------------------------
df['reviews_per_month'] = df['reviews_per_month'].fillna(0)


# -------------------------------
# 12. Drop rows with missing price
# -------------------------------
df = df.dropna(subset=['price'])


# -------------------------------
# 13. Convert integer columns
# -------------------------------
int_cols = ['beds','bedrooms','host_listings_count','host_total_listings_count',
            'minimum_minimum_nights','maximum_minimum_nights',
            'minimum_maximum_nights','maximum_maximum_nights']

df[int_cols] = df[int_cols].astype('Int64')  # Nullable integer type


# -------------------------------
# 14. Convert percentage strings to float
# -------------------------------
df['host_response_rate'] = (df['host_response_rate'].str.replace('%','', regex=False).astype(float))
df['host_acceptance_rate'] = (df['host_acceptance_rate'].str.replace('%','', regex=False).astype(float))


# -------------------------------
# 15. Convert t/f to boolean
# -------------------------------
df['instant_bookable'] = df['instant_bookable'].map({'t': True, 'f': False})
df['host_is_superhost'] = df['host_is_superhost'].map({'t': True, 'f': False})
df['host_has_profile_pic'] = df['host_has_profile_pic'].map({'t': True, 'f': False})
df['host_identity_verified'] = df['host_identity_verified'].map({'t': True, 'f': False})
df['has_availability'] = df['has_availability'].map({'t': True, 'f': False})

bol_cols = ['instant_bookable','host_has_profile_pic', 'host_identity_verified','host_is_superhost', 'has_availability']
df[bol_cols] = df[bol_cols].astype('boolean')


# -------------------------------
# 16. Clean amenities column
# -------------------------------
df['amenities'] = df['amenities'].str.replace(r'[\[\]"]', '', regex=True)


# -------------------------------
# 17. Calculate occupancy rate (%)
# -------------------------------
df['occupancy_rate'] = ((df['estimated_occupancy_l365d'] / 365) * 100).round(2)


# -------------------------------
# 18. Reorder columns (bring key ones to front)
# -------------------------------
front_cols = [
'id' ,
'host_id',
'room_type',
'property_type',
'price',
'accommodates',
'bedrooms',
'beds',
'bathrooms_text',
'minimum_nights',
'maximum_nights',
'occupancy_rate',
'estimated_occupancy_l365d',
'estimated_revenue_l365d',
'number_of_reviews',
'review_scores_rating',
'review_scores_accuracy',
'review_scores_cleanliness',
'review_scores_checkin',
'review_scores_communication',
'review_scores_location',
'review_scores_value',
'reviews_per_month',
'availability_30',
'availability_60',
'availability_90',
'availability_365',
'latitude',
'longitude',
'host_since',
'first_review',
'last_review',
'name',
'description',
'amenities',
'instant_bookable',
'license',
]

other_cols = [col for col in df.columns if col not in front_cols]

df = df[front_cols + other_cols]  # Reorder dataframe


# -------------------------------
# 19. Final inspection
# -------------------------------
df  # Display cleaned dataframe


# -------------------------------
# 20. Save cleaned dataset
# -------------------------------
df.to_csv('airbnb_listings.csv', index=False, encoding='utf-8')

# Created smaller sample (5000 rows for demonstration purposes)

df_sample = df.sample(n=5000, random_state=42)

df_sample.to_csv('airbnb_listings_sample.csv', index=False)