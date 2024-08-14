create table idsr_temp (countryname text, ProvinceName text, DistrictName text, EventName text, Epiyear text, Epiweek text, TotalCases text, TotalDeaths text, category text);
\COPY idsr_temp(epiyear, epiweek, countryname, provincename, districtname, eventname, totalcases, totaldeaths, category) FROM 'H:\My Drive\work\BrightWorldLabs\coreWork\consulting\2022\WHO-AFRO\analysis\data\20221206_dataFromEtien\IDSRDATA_2019_2022_AS_OF_WEEK45.txt' WITH CSV DELIMITER E'\t' HEADER;
create table diseases (
id serial,
disease text,
disease_type text
);

with data as (
	select distinct eventname as disease from epidemics_temp it
)
insert into diseases (disease) select disease
FROM data
WHERE not exists (select 'x' from diseases d where d.disease = data.disease);
DROP TABLE idsr;
CREATE TABLE public.idsr (
	id serial,
	d_id integer,
	totalcases integer,
	totaldeaths integer,
	epidemic_week date,
	adm0_name TEXT,
	adm1_name TEXT,
	adm2_name TEXT
);
INSERT INTO idsr (d_id, totalcases, totaldeaths, epidemic_week, adm0_name, adm1_name, adm2_name)
	SELECT d.id,
	CASE WHEN totalcases = 'NULL' OR totalcases IS NULL THEN 0 ELSE totalcases::integer END AS totalcases,
	CASE WHEN totaldeaths = 'NULL' OR totaldeaths IS NULL THEN 0 ELSE totaldeaths::integer END AS totaldeaths,
	to_date(epiweek || ' ' || epiyear, 'WW YYYY') AS epidemic_week,
	it.countryname,
	it.provincename,
	it.districtname
	FROM epidemics_temp it
	LEFT OUTER JOIN diseases d ON lower(it.eventname) = lower(d.disease)
	WHERE it.epiweek IS NOT NULL AND it.epiyear IS NOT null;
DELETE FROM idsr WHERE epidemic_week IS NULL;
DELETE FROM idsr WHERE adm2_name = 'NULL';
ALTER TABLE idsr ADD COLUMN adm2_my_id integer;
WITH projection AS (
	SELECT ab.my_id,
		lower(CASE WHEN dd.idsr_adm0_name IS NOT NULL THEN dd.idsr_adm0_name ELSE ab.adm0_name END) AS adm0_name,
		lower(CASE WHEN dd.idsr_adm1_name IS NOT NULL THEN dd.idsr_adm1_name ELSE ab.adm1_name END) AS adm1_name,
		lower(CASE WHEN dd.idsr_adm2_name IS NOT NULL THEN dd.idsr_adm2_name ELSE ab.adm2_name END) AS adm2_name
		FROM admin2_afro_master_subset1 ab
		LEFT JOIN district_discrepencies_2 dd 
			ON ab.my_id = dd.my_id
			AND dd.boundaries_adm0_name IS NOT NULL 
			AND ab.in_idsr = 'true'
)
UPDATE idsr ir SET adm2_my_id = my_id FROM projection p
WHERE lower(ir.adm0_name) = lower(p.adm0_name) AND lower(ir.adm1_name) = lower(p.adm1_name) AND lower(ir.adm2_name) = lower(p.adm2_name);
ALTER TABLE idsr ADD COLUMN y integer;
UPDATE idsr SET y = EXTRACT(YEAR FROM epidemic_week);
CREATE INDEX idsr_week_adm2_id_d_id_idx ON idsr(epidemic_week ASC, adm2_my_id, d_id);