DROP TABLE elevation_full;
CREATE TABLE elevation_full (
	id serial,
	my_id text,
	val_elevation float4
);
\COPY elevation_full (my_id, val_elevation) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\elevation\elevation_full_2.csv' WITH CSV HEADER;
CREATE INDEX elevation_full_my_id_idx ON elevation_full(my_id);
ALTER TABLE elevation_full ALTER COLUMN my_id TYPE integer USING my_id::integer;

-- find missing districts
WITH projection AS (
	SELECT foo1.my_id,
	ROUND(EXTRACT(EPOCH FROM foo1.epidemic_week))::integer AS time_in_ms, 
	foo1.epidemic_week, 
	foo1.y FROM (
		SELECT ab.my_id, e.epidemic_week, e.y FROM admin2_afro_master_subset1 ab
		CROSS JOIN (
			SELECT DISTINCT epidemic_week, y FROM idsr
		) e WHERE ab.in_idsr = 'true'
	) foo1
)
SELECT DISTINCT p.my_id FROM projection p
	LEFT JOIN 
	elevation_full ef
	ON p.my_id = ef.my_id
WHERE val_elevation IS NULL;