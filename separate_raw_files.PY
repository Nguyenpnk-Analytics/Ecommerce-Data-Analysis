import pandas as pd
import time
import math
import os

# link to raw data at your computer
input_path = r'C:\....\...csv'

# Maximum row (not including header)
max_rows_per_file = 1_000_000

# Get base name(without .csv)
base_name = os.path.splitext(input_path)[0]

print("🔄 Processing file split, please wait...")

start_time = time.time()

# Read all file
df = pd.read_csv(input_path)

total_rows = len(df)
num_parts = math.ceil(total_rows / max_rows_per_file)

print(f"📄 Total Row: {total_rows}")
print(f"📂 Number of files to create: {num_parts}")

for i in range(num_parts):
    start_row = i * max_rows_per_file
    end_row = min(start_row + max_rows_per_file, total_rows)
    
    chunk = df.iloc[start_row:end_row]
    
    output_path = f"{base_name} {i+1}.csv"
    chunk.to_csv(output_path, index=False, quoting=1, encoding='utf-8')
    
    print(f"✅ Saved: {output_path} ({end_row - start_row} rows)")

elapsed = time.time() - start_time
print(f"🎉 Complete in {elapsed:.2f} seconds.")
