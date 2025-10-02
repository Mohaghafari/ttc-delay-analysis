# Data Scripts

## convert_excel_to_csv.py

Converts TTC delay Excel files to CSV format for dbt seeds.

**Usage:**
```bash
# Place .xlsx files in data/raw/
# Run converter
python scripts/convert_excel_to_csv.py

# Output goes to seeds/ directory
```

Handles:
- Excel to CSV conversion
- Column name standardization
- Combining multiple years
- Basic data validation

## Adding More Data

To scale beyond 100k records:

1. Download historical data from Toronto Open Data:
   - https://open.toronto.ca/dataset/ttc-subway-delay-data/
   - https://open.toronto.ca/dataset/ttc-streetcar-delay-data/
   - https://open.toronto.ca/dataset/ttc-bus-delay-data/

2. Download Excel files for 2022, 2023, 2024

3. Place in `data/raw/`

4. Run converter:
   ```bash
   python scripts/convert_excel_to_csv.py
   ```

5. Reload seeds:
   ```bash
   dbt seed --full-refresh
   dbt build
   ```

This will get you 300k-1M records depending on years downloaded.

