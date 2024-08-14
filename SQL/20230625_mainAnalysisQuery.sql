WITH projection AS (
	SELECT foo1.my_id,
	foo1.adm0_name,
	foo1.epidemic_week, 
	foo1.y, 
	COALESCE(foo3.totalcases, 0) AS totalcases FROM (
		SELECT ab.my_id, ab.adm0_name, e.epidemic_week, e.y FROM admin2_afro_master_subset1 ab
		CROSS JOIN (
			SELECT DISTINCT epidemic_week, y FROM idsr
		) e WHERE ab.in_idsr = 'true'
	) foo1
	LEFT JOIN 
	(
		SELECT	
		sum(ir.totalcases) AS totalcases,
		ir.epidemic_week,
		ir.y,
		ir.adm2_my_id
		FROM idsr ir
		INNER JOIN diseases d
		ON ir.d_id = d.id
		AND lower(d.disease) =  ANY ('{"malaria", "malaria (imported)", "malaria confirmed", "malaria tested"}'::text[])
		GROUP BY adm2_my_id, epidemic_week, y
	) foo3
	ON foo1.my_id = foo3.adm2_my_id AND foo1.epidemic_week = foo3.epidemic_week AND foo1.y = foo3.y
)
SELECT 
p.my_id,
p.adm0_name,
p.epidemic_week,
p.y,
pr.val_precipitation, 
tp.val_temperature,
trees.val AS val_trees,
trees.percent_cov AS percent_cov_trees,
crops.val AS val_crops,
crops.percent_cov AS percent_cov_crops,
builtup.val AS val_builtup,
builtup.percent_cov AS percent_cov_builtup,
bareground.val AS val_bareground,
bareground.percent_cov AS percent_cov_bareground,
rangeland.val AS val_rangeland,
rangeland.percent_cov AS percent_cov_rangeland,
pf.pop_total / pf.count_total AS relative_pop_density,
pf.pop_near_water,
rw.val_wealth,
floor(ef.val_elevation) AS val_elevation,
p.totalcases
FROM 
projection p
LEFT JOIN precipitation_full pr
ON p.my_id = pr.my_id AND p.epidemic_week = pr.epidemic_week
LEFT JOIN temperature_full tp
ON p.my_id = tp.my_id AND p.epidemic_week = tp.epidemic_week
LEFT JOIN landcover_full trees 
ON p.my_id = trees.my_id AND p.y = trees."year" AND trees.clas = 'trees'
LEFT JOIN landcover_full crops 
ON p.my_id = crops.my_id AND p.y = crops."year" AND crops.clas = 'crops'
LEFT JOIN landcover_full builtup 
ON p.my_id = builtup.my_id AND p.y = builtup."year" AND builtup.clas = 'builtup'
LEFT JOIN landcover_full bareground 
ON p.my_id = bareground.my_id AND p.y = bareground."year" AND bareground.clas = 'bareground'
LEFT JOIN landcover_full rangeland 
ON p.my_id = rangeland.my_id AND p.y = rangeland."year" AND rangeland.clas = 'rangeland'
LEFT JOIN population_full pf
ON p.my_id = pf.my_id AND (CASE WHEN p.y > 2020 THEN 2020 ELSE p.y END) = pf."year"
LEFT JOIN relativewealth_full rw
ON p.my_id = rw.my_id
LEFT JOIN elevation_full ef
ON p.my_id = ef.my_id
ORDER BY p.epidemic_week ASC;