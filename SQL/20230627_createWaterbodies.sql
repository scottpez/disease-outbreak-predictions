-- Note that the 3000 in the command below is buffer by 3,000 meters or 3 km.
pgsql2shp -f "D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\waterbodies\osm_waterbodies_3km" -u scopez -P zen0$ osm "SELECT o.osm_id, ST_SetSRID(ST_Transform(ST_Buffer(ST_Transform(o.way, 102022), 3000), 4326), 4326) AS geom FROM planet_osm_polygon o WHERE o.natural = 'water' OR o.water IS NOT NULL"
