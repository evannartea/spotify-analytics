<div>
    <img src="images/Spotify_logo_with_text.svg.png" height="200" width="200">
</div>

# Streaming History Dashboard
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](#)
[![Postgres](https://img.shields.io/badge/Postgres-%23316192.svg?logo=postgresql&logoColor=white)](#)
[![Tableau](https://custom-icon-badges.demolab.com/badge/Tableau-0176D3?logo=tableau&logoColor=fff)](#)
[![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=fff)](#)

### 📌 Project Overview
#
An end-to-end data analytics project that uses an ELT pipeline to process and analyse personal Spotify streaming history data on Tableau. This project covers a complete analytics workflow from data extraction, loading and transforming in a database, and dashboard development.<br>
<br>
The interactive dashboard is available on <a href="https://public.tableau.com/views/SpotifyDashboard_17842213345050/SpotifyDashboard?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link">Tableau Public</a>.

### 📷 Examples
#
**Original View:**<br>
<br>
<img src="images/dashboard_screenshot.png" alt="Dashboard Screenshot" height="982" width="1710"><br>
<br>
**Filtered View:**<br>
<br>
<img src="images/dashboard_filtered_screenshot.png" alt="Dashboard Filtered Screenshot" height="982" width="1710">

### 🎯 What I Learned
#
- Used Python to read and concatenate multiple JSON files into a single dataframe.
- Learned how to set up and configure a PostgreSQL server.
- Improved my understanding of data warehousing by implementing a star schema using SQL to create fact and dimension tables.
- Gained experience developing an interactive dashboard in Tableau.

### 📝 Notes
#
- All data prior to 2022 was removed, as there were significant gaps in streaming history data between 2016 and 2022 which impacted the visualisation on Tableau. This excluded 61 rows totalling 49 minutes of listening activity recorded before the Spotify Premium subscription started in 2022.
- The genre data was likely the least reliable component, as Last.fm's `artist.getTopTags` API endpoint was used as a proxy for artist genres. These are user-generated keywords and are not always strictly defined genres, .e.g, "Japanese" or "Soundtrack". The same genre could also appear in different formats, e.g., "Hip-hop" and "Hip hop". To improve consistency, tags were normalised using regex and any appearing fewer than 30 times were filtered out to reduce niche or highly personalised tags. This approach was inspired by an <a href="https://dev.to/romdevin/combining-spotify-playlist-data-with-lastfm-genres-for-comprehensive-json-output-2k2j">article by Roman Dubrovin</a> and was necessary since Spotify has deprecated its genres endpoint in the Web API.
- Last.fm's API endpoint also provides a `count` attribute defined as "a weighted count of how often the tag was applied, with a maximum of 100". However, the values are not evenly distributed among the tags, as multiple tags could share the maximum count of 100. To ensure accuracy and a fair distribution of weight among the top tags, the counts were normalised and any tags with counts below 50 were excluded. For example, if an artist had two tags with counts of 100, these were assigned equal weights of 0.5 each.
- `dim_play_info` data was not utilised for the final dashboard which may have been a missed opportunity to analyse listening behaviour such as song starts, song endings, skips, and shuffle activity.
- The process could have been more streamlined by connecting Tableau directly to the PostgreSQL database. However, this feature is unavailable for Tableau Public, meaning the transformed data had to be extratced from PostgreSQL as CSV files before being imported into Tableau.
- Adding new data after reaching the visualisation stage proved quite problematic due to a rigid pipeline. This could have been avoided by establishing visualisation requirements earlier and loading all necessary data from the start, or by developing a more flexible pipeline to accommodate these changes.
- Tableau containers are very confusing!

### 📄 Credits
#
**Author:** Evan Nartea<br>
**Contributors:** Evan Nartea<br>
<br>
Spotify data: Spotify → Account → Security and privacy → Account privacy → Download your data → Extended streaming history<br>
Genre data: https://www.last.fm/api/show/artist.getTopTags<br>
