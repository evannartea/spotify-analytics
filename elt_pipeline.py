import os
import glob
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

def load_data():
    dataframes = []
    files = glob.glob("data/raw/Streaming_History_Audio_*.json")

    for file in files:
        dataframes.append(pd.read_json(file))

    return pd.concat(dataframes, ignore_index=True)

def clean_data(df):
    # Convert timestamp to datetime
    df["ts"] = pd.to_datetime(
        df["ts"],
        format="%Y-%m-%dT%H:%M:%SZ",
        utc=True
    )

    # Create minutes played
    df["mins_played"] = df["ms_played"] / 60000

    return df

# Export DataFrame to PostgreSQL
def export_to_db(df, engine):
    df.to_sql(
        name="streaming_history",
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

def main():
    load_dotenv()
    database_url = os.getenv("DATABASE_URL")
    engine = create_engine(database_url)
    
    df = load_data()
    df_clean = clean_data(df)

    export_to_db(df_clean, engine)

    print("Exported successfully!")

    extract_from_db("dim_date", engine)
    extract_from_db("dim_time", engine)
    extract_from_db("dim_track", engine)
    extract_from_db("dim_country", engine)
    extract_from_db("dim_play_info", engine)
    extract_from_db("fact_streams", engine)
    
    print("Extracted succesfully!")

if __name__ == "__main__":
    main()