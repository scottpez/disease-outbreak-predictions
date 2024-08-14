SELECT lower(e.adm0_name) AS mycountry, sum(totalcases) AS totalcases, sum(totaldeaths) AS totaldeaths 
FROM idsr e GROUP BY e.adm0_name;