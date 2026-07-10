import glob
import pandas as pd

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

# Extract year
df["year"] = df["ts"].dt.year

# Extract minutes played
df["mins_played"] = df["ms_played"] / 60000

print(df)