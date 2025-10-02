"""
Generate realistic TTC (Toronto Transit Commission) data for analysis
This script generates 10M+ records of transit data
"""
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from faker import Faker
import random

fake = Faker()
Faker.seed(42)
np.random.seed(42)

# TTC Route information (realistic Toronto routes)
ROUTES = [
    {'route_id': 1, 'route_name': 'Yonge-University', 'route_type': 'Subway', 'avg_fare': 3.25},
    {'route_id': 2, 'route_name': 'Bloor-Danforth', 'route_type': 'Subway', 'avg_fare': 3.25},
    {'route_id': 5, 'route_name': 'Yonge', 'route_type': 'Bus', 'avg_fare': 3.25},
    {'route_id': 6, 'route_name': 'Bay', 'route_type': 'Bus', 'avg_fare': 3.25},
    {'route_id': 29, 'route_name': 'Dufferin', 'route_type': 'Bus', 'avg_fare': 3.25},
    {'route_id': 32, 'route_name': 'Eglinton West', 'route_type': 'Bus', 'avg_fare': 3.25},
    {'route_id': 36, 'route_name': 'Finch West', 'route_type': 'Bus', 'avg_fare': 3.25},
    {'route_id': 501, 'route_name': 'Queen', 'route_type': 'Streetcar', 'avg_fare': 3.25},
    {'route_id': 504, 'route_name': 'King', 'route_type': 'Streetcar', 'avg_fare': 3.25},
    {'route_id': 505, 'route_name': 'Dundas', 'route_type': 'Streetcar', 'avg_fare': 3.25},
    {'route_id': 510, 'route_name': 'Spadina', 'route_type': 'Streetcar', 'avg_fare': 3.25},
]

PAYMENT_TYPES = ['Presto', 'Token', 'Cash', 'Day Pass', 'Monthly Pass']
BOARDING_STATUSES = ['On Time', 'Delayed', 'Early']

def generate_trip_data(num_records=10_000_000, output_file='seeds/ttc_trips.csv', chunk_size=500_000):
    """Generate TTC trip data in chunks to handle large datasets"""
    
    print(f"Generating {num_records:,} TTC trip records...")
    
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2024, 12, 31)
    date_range = (end_date - start_date).days
    
    # Generate data in chunks
    chunks_written = 0
    for chunk_start in range(0, num_records, chunk_size):
        chunk_end = min(chunk_start + chunk_size, num_records)
        current_chunk_size = chunk_end - chunk_start
        
        # Generate random dates
        random_days = np.random.randint(0, date_range, current_chunk_size)
        trip_dates = [start_date + timedelta(days=int(d)) for d in random_days]
        
        # Generate trip times (weighted towards rush hours)
        # Probability distribution for each hour (0-23), normalized to sum to 1.0
        hour_probs = np.array([0.01, 0.01, 0.01, 0.01, 0.02, 0.03, 0.08, 0.12, 0.09, 0.06, 
                               0.05, 0.06, 0.05, 0.04, 0.04, 0.05, 0.08, 0.10, 0.06, 0.02, 
                               0.01, 0.01, 0.005, 0.005])
        hour_probs = hour_probs / hour_probs.sum()  # Normalize to sum to 1.0
        hours = np.random.choice(range(24), current_chunk_size, p=hour_probs)
        minutes = np.random.randint(0, 60, current_chunk_size)
        seconds = np.random.randint(0, 60, current_chunk_size)
        
        trip_datetimes = [
            dt.replace(hour=int(h), minute=int(m), second=int(s))
            for dt, h, m, s in zip(trip_dates, hours, minutes, seconds)
        ]
        
        # Select routes with realistic distribution
        route_weights = [0.15, 0.15, 0.12, 0.10, 0.10, 0.08, 0.08, 0.07, 0.07, 0.05, 0.03]
        selected_routes = np.random.choice(len(ROUTES), current_chunk_size, p=route_weights)
        
        # Generate trip data
        chunk_data = []
        for i in range(current_chunk_size):
            route = ROUTES[selected_routes[i]]
            
            # Generate realistic trip details
            passengers = np.random.poisson(lam=15) + 1  # Average 15 passengers per trip
            delay_minutes = 0
            boarding_status = np.random.choice(BOARDING_STATUSES, p=[0.75, 0.20, 0.05])
            
            if boarding_status == 'Delayed':
                delay_minutes = np.random.exponential(scale=5)  # Average 5 min delay
            elif boarding_status == 'Early':
                delay_minutes = -np.random.exponential(scale=2)  # Average 2 min early
                
            trip_data = {
                'trip_id': chunk_start + i + 1,
                'trip_datetime': trip_datetimes[i],
                'route_id': route['route_id'],
                'route_name': route['route_name'],
                'route_type': route['route_type'],
                'passengers': passengers,
                'payment_type': np.random.choice(PAYMENT_TYPES, p=[0.70, 0.10, 0.05, 0.05, 0.10]),
                'fare_amount': route['avg_fare'] if np.random.random() > 0.02 else 0,  # 2% fare evasion
                'boarding_status': boarding_status,
                'delay_minutes': round(delay_minutes, 2),
                'vehicle_id': f"V{route['route_type'][:3].upper()}{np.random.randint(1000, 9999)}",
                'stop_sequence': np.random.randint(1, 50),
                'temperature_celsius': round(np.random.normal(10, 15), 1),  # Toronto weather
                'is_weekend': trip_datetimes[i].weekday() >= 5,
                'created_at': datetime.now()
            }
            chunk_data.append(trip_data)
        
        # Create DataFrame
        df_chunk = pd.DataFrame(chunk_data)
        
        # Write to CSV (append after first chunk)
        mode = 'w' if chunks_written == 0 else 'a'
        header = chunks_written == 0
        df_chunk.to_csv(output_file, mode=mode, header=header, index=False)
        
        chunks_written += 1
        progress = (chunk_end / num_records) * 100
        print(f"Progress: {progress:.1f}% ({chunk_end:,} / {num_records:,} records)")
    
    print(f"\n✓ Successfully generated {num_records:,} records")
    print(f"✓ Output file: {output_file}")
    print(f"✓ File size: {pd.read_csv(output_file).memory_usage(deep=True).sum() / 1024**2:.2f} MB")

def generate_route_info(output_file='seeds/route_info.csv'):
    """Generate route information reference table"""
    df = pd.DataFrame(ROUTES)
    df['is_active'] = True
    df['created_at'] = datetime.now()
    df.to_csv(output_file, index=False)
    print(f"✓ Generated route info: {output_file}")

if __name__ == "__main__":
    import os
    import sys
    
    # Create seeds directory if it doesn't exist
    os.makedirs('seeds', exist_ok=True)
    
    # Parse command line arguments
    num_records = 1_000_000  # Default to 1M for faster testing
    if len(sys.argv) > 1:
        num_records = int(sys.argv[1])
    
    print("=" * 60)
    print("TTC Data Generator")
    print("=" * 60)
    
    # Generate route info (small reference table)
    generate_route_info()
    
    print("\n")
    
    # Generate trip data (large fact table)
    generate_trip_data(num_records=num_records)
    
    print("\n" + "=" * 60)
    print("Data generation complete!")
    print("=" * 60)

