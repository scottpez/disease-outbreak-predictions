DROP TABLE relativewealth_full;
CREATE TABLE relativewealth_full (
	id serial,
	my_id text,
	val_wealth float4
);
\COPY relativewealth_full (my_id, val_wealth) FROM 'D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\wealth\relative_wealth_index_full_2.csv' WITH CSV HEADER;
SELECT abs(min(val_wealth)) FROM relativewealth_full;
UPDATE relativewealth_full SET val_wealth = val_wealth + 1.30700004;
CREATE INDEX relativewealth_full_my_id_idx ON relativewealth_full(my_id);
ALTER TABLE relativewealth_full ALTER COLUMN my_id TYPE integer USING my_id::integer;

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
SELECT p.my_id, p.epidemic_week, rwf.val_wealth FROM projection p
	LEFT JOIN 
	relativewealth_full rwf
	ON p.my_id = rwf.my_id
WHERE val_wealth IS NULL;