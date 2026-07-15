import os
import glob
import time
import requests
import pandas as pd
from dotenv import load_dotenv

def load_data():
    dataframes = []
    files = glob.glob("data/raw/Streaming_History_Audio_*.json")

    for file in files:
        dataframes.append(pd.read_json(file))

    return pd.concat(dataframes, ignore_index=True)


def get_genres(artist_name, api_key, session):
    url = f"https://ws.audioscrobbler.com/2.0/"
    params = {
        "method": "artist.gettoptags",
        "artist": artist_name,
        "api_key": api_key,
        "format": "json"
    }

    response = session.get(url, params=params, timeout=10)
    data = response.json()

    result = []
    tags = data.get("toptags", {}).get("tag", [])

    for tag in tags:
        result.append(
            {
                "name": tag["name"],
                "count": tag["count"]
            }
        )

    return result

def main():
    df = load_data()

    load_dotenv()
    api_key = os.getenv("API_KEY")

    session = requests.Session()
    artists = sorted(df["master_metadata_album_artist_name"].dropna().unique())

    rows = []
    
    for artist in artists:
        genres = get_genres(artist, api_key, session)
        time.sleep(0.2)
        
        for genre in genres:
            rows.append(
                {
                    "artist_name": artist,
                    "genre": genre["name"],
                    "weight": genre["count"]
                }
            )

    df_genre = pd.DataFrame(rows)
    df_genre.to_csv("data/raw/genres.csv", index=False)

    print("Completed!")

if __name__ == "__main__":
    main()
