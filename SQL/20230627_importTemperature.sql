DROP TABLE temperature_full;
CREATE TABLE temperature_full (
	id serial,
	my_id text,
	epidemic_week date,
	val_temperature float4
);
\COPY temperature_full (my_id, epidemic_week, val_temperature) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\temperature\temperature_full_2.csv' WITH CSV HEADER;
CREATE INDEX temperature_full_my_id_epidemic_week_idx ON temperature_full(my_id, epidemic_week);
ALTER TABLE temperature_full ALTER COLUMN my_id TYPE integer USING my_id::integer;

-- find missing districts
WITH projection AS (
	SELECT my_id, adm0_name, adm1_name, adm2_name, epidemic_week
	FROM admin2_afro_master_subset1 ab
	CROSS JOIN (
		SELECT DISTINCT epidemic_week FROM idsr WHERE epidemic_week IS NOT NULL
	) e
)
SELECT DISTINCT my_id FROM (
SELECT p.my_id, p.adm0_name, p.adm1_name, p.adm2_name, p.epidemic_week, tf2.val_temperature FROM projection p
	LEFT JOIN 
	temperature_full tf2 
	ON p.my_id = tf2.my_id AND p.epidemic_week = tf2.epidemic_week
WHERE val_temperature IS NULL
)foo;
SELECT * FROM (
SELECT count(*) AS my_count, epidemic_week FROM temperature_full pf GROUP BY epidemic_week
) foo WHERE my_count != 4506;