DROP TABLE district_discrepencies_2;
CREATE TABLE district_discrepencies_2 (idsr_adm0_name, idsr_adm1_name, idsr_adm2_name, boundaries_adm0_name, boundaries_adm1_name, boundaries_adm2_name) 
	AS SELECT DISTINCT adm0_na, adm1_na, adm2_na, NULL, NULL, NULL FROM (
		SELECT et.adm0_na, et.adm1_na, et.adm2_na, ab.gid FROM epidemics et
		LEFT OUTER JOIN admin2_afro_master ab ON 
		lower(et.adm0_na) = lower(ab.adm0_name)
		AND lower(et.adm1_na) = lower(ab.adm1_name)
		AND lower(et.adm2_na) = lower(ab.adm2_name)
	) foo WHERE foo.gid IS NULL;
ALTER TABLE district_discrepencies_2 ADD COLUMN id SERIAL PRIMARY KEY;
UPDATE district_discrepencies_2 d SET 
boundaries_adm0_name = lower(dd.boundaries_adm0_name), 
boundaries_adm1_name = lower(dd.boundaries_adm1_name), 
boundaries_adm2_name = lower(dd.boundaries_adm2_name) 
FROM district_discrepencies dd 
WHERE lower(d.idsr_adm0_name) = lower(dd.idsr_adm0_name)
AND lower(d.idsr_adm1_name) = lower(dd.idsr_adm1_name)
AND lower(d.idsr_adm2_name) = lower(dd.idsr_adm2_name);
ALTER TABLE district_discrepencies_2 ADD COLUMN my_id integer;
UPDATE district_discrepencies_2 dd SET my_id = ab.my_id 
FROM admin2_afro_master_subset1 ab WHERE 
dd.boundaries_adm0_name = ab.adm0_name AND 
dd.boundaries_adm1_name = ab.adm1_name AND 
dd.boundaries_adm2_name = ab.adm2_name;

SELECT ab.adm0_name, ab.adm1_name, ab.adm2_name, sum(foo.totalcases) AS totalcases, foo.epidemic_week FROM 
admin2_afro_master_subset1 ab LEFT OUTER JOIN
(
SELECT 
e.totalcases,
e.epidemic_week,
lower(CASE WHEN dd.boundaries_adm0_name IS NULL THEN e.adm0_na ELSE dd.boundaries_adm0_name END) AS adm0_name,
lower(CASE WHEN dd.boundaries_adm1_name IS NULL THEN e.adm1_na ELSE dd.boundaries_adm1_name END) AS adm1_name,
lower(CASE WHEN dd.boundaries_adm2_name IS NULL THEN e.adm2_na ELSE dd.boundaries_adm2_name END) AS adm2_name
FROM epidemics e 
LEFT OUTER JOIN district_discrepencies_2 dd 
ON e.adm0_na = dd.idsr_adm0_name 
AND e.adm1_na = dd.idsr_adm1_name 
AND e.adm2_na = dd.idsr_adm2_name
) foo
ON ab.adm0_name = foo.adm0_name
AND ab.adm1_name = foo.adm1_name
AND ab.adm2_name = foo.adm2_name
GROUP BY ab.adm0_name, ab.adm1_name, ab.adm2_name, foo.epidemic_week
ORDER BY 4 desc;