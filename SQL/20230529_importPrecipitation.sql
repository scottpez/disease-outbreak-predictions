DROP TABLE precipitation_full;
CREATE TABLE precipitation_full (
	id serial,
	my_id text,
	epidemic_week date,
	val_precipitation float4
);
\COPY precipitation_full (my_id, epidemic_week, val_precipitation) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\precipitation\precipitation_full_2.csv' WITH CSV HEADER;
CREATE INDEX precipitation_full_my_id_epidemic_week_idx ON precipitation_full(my_id, epidemic_week);
ALTER TABLE precipitation_full ALTER COLUMN my_id TYPE integer USING my_id::integer;

-- find missing districts
WITH projection AS (
	SELECT ab.my_id, e.epidemic_week FROM admin2_afro_master_subset1 ab
	CROSS JOIN (
		SELECT DISTINCT epidemic_week FROM idsr
	) e WHERE ab.in_idsr = 'true'
)
SELECT p.my_id, p.epidemic_week, pf.val_precipitation FROM projection p
	LEFT JOIN 
	precipitation_full pf 
	ON p.my_id = pf.my_id AND p.epidemic_week = pf.epidemic_week
WHERE val_precipitation IS NULL;