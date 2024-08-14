DROP TABLE landcover_full;
CREATE TABLE landcover_full (
	id serial,
	my_id text,
	"year" integer,
	clas TEXT,
	val float4,
	percent_cov float4
);
\COPY landcover_full (my_id, "year", clas, val, percent_cov) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\landcover\landcover_full_2.csv' WITH CSV HEADER;
CREATE INDEX landcover_full_my_id_year_clas_idx ON landcover_full(my_id, "year", clas);
ALTER TABLE landcover_full ALTER COLUMN my_id TYPE integer USING my_id::integer;

-- find missing districts
WITH projection AS (
	SELECT ab.my_id, e.epidemic_week FROM admin2_afro_master_subset1 ab
	CROSS JOIN (
		SELECT DISTINCT epidemic_week FROM idsr
	) e WHERE ab.in_idsr = 'true'
)
SELECT p.my_id, p.epidemic_week, lf.val FROM projection p
	LEFT JOIN 
	landcover_full lf
	ON p.my_id = lf.my_id AND EXTRACT(YEAR FROM p.epidemic_week) = lf."year" 
WHERE val IS NULL;