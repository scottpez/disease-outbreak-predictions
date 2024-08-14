--"C:\Program Files\PostgreSQL\15\bin\shp2pgsql.exe" -I Admin2_Afro_Master Admin2_Afro_Master > Admin2_Afro_Master.SQL
--psql -d who -U scopez -f Admin2_Afro_Master.SQL
ALTER TABLE admin2_afro_master ADD COLUMN in_idsr boolean DEFAULT 'true';
UPDATE admin2_afro_master SET in_idsr = 'false' WHERE adm0_name IN
('algeria', 'angola', 'comoros', 'equatorial guinea', 'esitrea', 'kingdom of eswatini', 'ethiopia', 'mauritius', 'south africa');
SELECT UpdateGeometrySRID('admin2_afro_master_subset1','geom',4326);
--pgsql2shp -f "D:\work\BrightWorldLabs\coreWork\consulting\2023\WHO-AFRO\data\administrative\2\Admin2_Afro_Master_final" -u scopez -P zen0$ who "select * from Admin2_Afro_Master_subset1 where in_idsr='true'"
ALTER TABLE admin2_afro_master_subset1 ALTER COLUMN my_id TYPE integer USING my_id::integer;