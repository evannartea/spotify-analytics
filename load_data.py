import glob
import pandas as pd
import psycopg2
import requests
from sqlalchemy import create_engine

file_name = "Streaming_History_Audio_*.json"

df = pd.DataFrame()

for file in glob.glob("data/" + file_name):
    temp = pd.read_json(file)
    df = pd.concat([df, temp])

# Convert timestamp to datetime
df["ts"] = pd.to_datetime(
    df["ts"],
    format="%Y-%m-%dT%H:%M:%SZ",
    utc=True
)

# Extract year from timestamp
df["year_played"] = df["ts"].dt.year

#Extract month from timestamp
df["month_played"] = df["ts"].dt.month

# Create minutes played
df["mins_played"] = df["ms_played"] / 60000

#print(df)

# Connect to PostgreSQL
engine = create_engine("postgresql+psycopg2://postgres:postgres@localhost:5432/spotify_analytics")

# Export DataFrame to PostgreSQL
df.to_sql(
    name="streaming_history",
    con=engine, 
    if_exists="replace",
    index=False
)