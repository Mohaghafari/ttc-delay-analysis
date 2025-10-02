"""
Convert TTC Excel delay files to CSV for dbt
"""
import pandas as pd
import os
import glob
from datetime import datetime

def process_excel_files():
    print("=" * 60)
    print("TTC Data Converter")
    print("=" * 60)
    
    raw_dir = "data/raw"
    seeds_dir = "seeds"
    
    os.makedirs(raw_dir, exist_ok=True)
    os.makedirs(seeds_dir, exist_ok=True)
    
    # Find Excel files
    excel_files = glob.glob(f"{raw_dir}/*.xlsx") + glob.glob(f"{raw_dir}/*.xls")
    
    if not excel_files:
        print(f"\nNo Excel files found in {raw_dir}/")
        print("Download files from Toronto Open Data and place them there")
        return False
    
    print(f"\nFound {len(excel_files)} Excel file(s)")
    
    # Categorize by transit type
    datasets = {
        'subway': [],
        'streetcar': [],
        'bus': []
    }
    
    for file in excel_files:
        filename = os.path.basename(file).lower()
        if 'subway' in filename:
            datasets['subway'].append(file)
        elif 'streetcar' in filename:
            datasets['streetcar'].append(file)
        elif 'bus' in filename:
            datasets['bus'].append(file)
    
    # Process each type
    total_rows = 0
    
    for dataset_type, files in datasets.items():
        if not files:
            continue
            
        print(f"\n{dataset_type.upper()} DELAYS")
        print("-" * 40)
        
        all_dfs = []
        
        for file in files:
            filename = os.path.basename(file)
            print(f"\nReading: {filename}")
            
            try:
                df = pd.read_excel(file, engine='openpyxl')
                print(f"  Rows: {len(df):,} | Columns: {len(df.columns)}")
                
                # Standardize column names
                df.columns = df.columns.str.lower().str.strip()
                df.columns = df.columns.str.replace(' ', '_').str.replace('-', '_')
                df.columns = df.columns.str.replace('/', '_').str.replace('(', '').str.replace(')', '')
                
                # Add metadata
                df['transit_type'] = dataset_type
                df['source_file'] = filename
                df['loaded_at'] = datetime.now()
                
                all_dfs.append(df)
                total_rows += len(df)
                
            except Exception as e:
                print(f"  Error: {e}")
                continue
        
        # Combine and save
        if all_dfs:
            combined_df = pd.concat(all_dfs, ignore_index=True, sort=False)
            output_file = f"{seeds_dir}/ttc_{dataset_type}_delays.csv"
            combined_df.to_csv(output_file, index=False)
            
            print(f"\nSaved: {output_file}")
            print(f"  Total rows: {len(combined_df):,}")
            print(f"  Columns: {len(combined_df.columns)}")
    
    print(f"\n{'='*60}")
    print(f"Total records: {total_rows:,}")
    print(f"{'='*60}")
    
    return True

if __name__ == "__main__":
    success = process_excel_files()
    
    if success:
        print("\nDone! Run: dbt seed")
    else:
        print("\nDownload files from:")
        print("  https://open.toronto.ca/catalogue/?search=ttc&topics=Transportation")
