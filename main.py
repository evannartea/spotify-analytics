import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from pipeline import load_data, export_to_db, extract_from_db

def main():
    load_dotenv()
    database_url = os.getenv("DATABASE_URL")
    engine = create_engine(database_url)
    
    df = load_data()

    export_to_db("streaming history", df, engine)

    print("Exported successfully!")

    """
    extract_from_db("dim_date", engine)
    extract_from_db("dim_time", engine)
    extract_from_db("dim_track", engine)
    extract_from_db("dim_country", engine)
    extract_from_db("dim_play_info", engine)
    extract_from_db("fact_streams", engine)
    """
    print("Extracted succesfully!")

if __name__ == "__main__":
    main()