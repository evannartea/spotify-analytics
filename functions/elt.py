import glob
import pandas as pd

# Read + concat JSON files
def load_data():
    dataframes = []
    files = glob.glob("data/raw/Streaming_History_Audio_*.json")

    for file in files:
        dataframes.append(pd.read_json(file))

    return pd.concat(dataframes, ignore_index=True)

# Export DataFrame to PostgreSQL
def export_to_db(table_name, df, engine):
    df.to_sql(
        name=table_name,
        con=engine, 
        if_exists="replace",
        index=False
    )

# Extract data from PostgreSQL as CSV files
def extract_from_db(table_name, engine):
    df = pd.read_sql(f"SELECT * FROM warehouse.{table_name}", engine)
    
    file_path = f"data/clean/{table_name}.csv"
    df.to_csv(file_path, index=False)

    return file_path