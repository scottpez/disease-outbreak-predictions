DROP TABLE population_full;
CREATE TABLE population_full (
	id serial,
	my_id text,
	"year" integer,
	count_near_water float,
	pop_near_water float,
	count_total float,
	pop_total float
);
\COPY population_full (my_id, "year", count_near_water, pop_near_water, count_total, pop_total) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\population\population_full_2017.csv' WITH CSV HEADER;
\COPY population_full (my_id, "year", count_near_water, pop_near_water, count_total, pop_total) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\population\population_full_2018.csv' WITH CSV HEADER;
\COPY population_full (my_id, "year", count_near_water, pop_near_water, count_total, pop_total) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\population\population_full_2019.csv' WITH CSV HEADER;
\COPY population_full (my_id, "year", count_near_water, pop_near_water, count_total, pop_total) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\population\population_full_2020.csv' WITH CSV HEADER;
UPDATE population_full SET my_id = (floor(my_id::numeric))::TEXT;
CREATE INDEX population_full_my_id_year_idx ON population_full(my_id, "year");
ALTER TABLE population_full ALTER COLUMN my_id TYPE integer USING my_id::integer;

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
SELECT * FROM (
	SELECT p.my_id, p.y, pf.count_near_water 
		FROM projection p
		LEFT JOIN 
		population_full pf 
		ON p.my_id = pf.my_id AND (CASE WHEN p.y > 2020 THEN 2020 ELSE p.y END) = pf."year"
	WHERE count_near_water IS NULL
) foo;