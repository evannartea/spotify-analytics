import glob
import pandas as pd
import psycopg2
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine


def load_data():
    dataframes = []
    files = glob.glob("data/Streaming_History_Audio_*.json")

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


def export_to_db(df, database_url):
    # Connect to PostgreSQL
    engine = create_engine(database_url)

    # Export DataFrame to PostgreSQL
    df.to_sql(
        name="streaming_history",
        con=engine, 
        if_exists="replace",
        index=False
    )


def main():
    load_dotenv()

    database_url = os.getenv("DATABASE_URL")
    df = load_data()
    df_clean = clean_data(df)

    export_to_db(df_clean, database_url)

if __name__ == "__main__":
    main()