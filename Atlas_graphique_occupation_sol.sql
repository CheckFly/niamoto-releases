-----------superficie forestière par commune
Select a.gid, name, a.forest_area_ha, a.forest_area_ha/b.forest_area_ha contrib_pn, a.forest_um_area_ha, a.forest_um_area_ha/b.forest_um_area_ha contrib_pn_um
from atlas_pn.pn_emprises a, (Select forest_area_ha, forest_um_area_ha from atlas_pn.pn_emprises where gid=1) b
where a.type='Commune'
order by contrib_pn DESC;
-----------------mines et conservation
select gid, name, 
	(reserve_area_ha-reserve_um_area_ha)/land_area_ha reserve_no_um, 
	reserve_um_area_ha/land_area_ha reserve_um, 
	mining_um_area_ha/land_area_ha mining_um,
	CASE WHEN landum_area_ha>0 THEN mining_um_area_ha/landum_area_ha ELSE 0 END mining_um_land
FROM atlas_pn.pn_emprises 
WHERE land_area_ha>0 
ORDER BY gid;
--------- couverture forestière---------------
Select gid, type, name,
(land_area_ha-forest_area_ha)/land_area_ha as noforest,
forest_area_ha/land_area_ha as forest
from atlas_pn.pn_emprises where type='Commune'  order by forest;

--------- concessions minière sur UM----------
Select gid, name, 
Case WHEN forest_um_area_ha>0 then (forest_um_area_ha-forest_mining_ha)/forest_um_area_ha else 0 end as no_mining,
Case WHEN forest_um_area_ha>0 then forest_mining_ha/forest_um_area_ha else 0 end as mining
from atlas_pn.pn_emprises where type='Commune'  order by mining, no_mining;

--------- protection de la forêt (forêt + réserves + mines sur forêt)---
Select gid, name,(land_area_ha-forest_area_ha) land, (forest_area_ha - forest_reserve_ha - forest_mining_ha) forest_hors_perimeter,
forest_reserve_ha, forest_mining_ha
from atlas_pn.pn_emprises where type='Commune' order by name

----------occurences par communes---------------------
With nb_occurences_total as (select nb_occurences nb_total from atlas_pn.pn_emprises where gid=1)
Select gid, name, nb_occurences, nb_occurences/nb_total as contrib_province
from atlas_pn.pn_emprises,nb_occurences_total
where type ='Commune'
order by contrib_province DESC

----------Onglet occupation (type forestiers, proportion forêts)-----------------------------
SELECT gid, name,
	case when forest_area_ha>0 then round(((forest_area_ha -forest_100m_ha)/forest_area_ha)::numeric,5) else 0 end as forest_secondaire,
	case when forest_area_ha>0 then round(((forest_100m_ha-forest_ssdm80_ha)/forest_area_ha)::numeric,5) else 0 end as  forest_mature,
	case when forest_area_ha>0 then round((forest_ssdm80_ha/forest_area_ha)::numeric,5) else 0 end as forest_coeur,
	CASE WHEN land_area_ha>0 then
		round(((land_area_ha-forest_area_ha)/land_area_ha)::numeric,5)
	     ELSE 0
	END as land,
	CASE WHEN land_area_ha>0 then
		round((forest_area_ha/land_area_ha)::numeric,5)
	     ELSE 0
	END as forest,
	CASE WHEN (land_area_ha - landum_area_ha)>0 then
		round( (((land_area_ha - landum_area_ha)-(forest_area_ha - forest_um_area_ha))/(land_area_ha - landum_area_ha))::numeric,5) 
	     ELSE 0
	END as land_no_um_noforest,

	CASE WHEN (land_area_ha - landum_area_ha)>0 then
		round(((forest_area_ha - forest_um_area_ha)/(land_area_ha - landum_area_ha))  ::numeric,5) 
	     ELSE 0
	END as  land_no_um_forest,

		--landum_area_ha,
	CASE WHEN landum_area_ha>0 THEN
		round(((landum_area_ha -forest_um_area_ha)/landum_area_ha)::numeric,5) 
	ELSE 0 END as landum_noforest,

	CASE WHEN landum_area_ha>0 THEN
		round((forest_um_area_ha/landum_area_ha)::numeric,5) 
	ELSE 0 END as landum_noforest,
	
	CASE WHEN forest_area_ha>0 THEN
		round(((forest_area_ha - forest_reserve_ha - forest_mining_ha)/forest_area_ha)::numeric,5) 
	ELSE 0 END as forest_hors_perimeter,
	
	CASE WHEN forest_area_ha>0 THEN
		round((forest_reserve_ha/forest_area_ha)::numeric,5) 
	ELSE 0 END as forest_reserve, 

	CASE WHEN forest_area_ha>0 THEN
		round((forest_mining_ha/forest_area_ha)::numeric,5) 
	ELSE 0 END as forest_mining

FROM atlas_pn.pn_emprises order by gid 


----------Holdrige1 distribution by emprises-------------------------------------
SELECT gid_emprise, type,name,
	sum(pixelcount) FILTER (WHERE classe=1 AND mnt_object='land') land_1,
	sum(pixelcount) FILTER (WHERE classe=2 AND mnt_object='land') land_2,
	sum(pixelcount) FILTER (WHERE classe=3 AND mnt_object='land') land_3,
	sum(pixelcount) FILTER (WHERE classe=4 AND mnt_object='land') land_4,
	sum(pixelcount) FILTER (WHERE classe=5 AND mnt_object='land') land_5,
	sum(pixelcount) FILTER (WHERE classe=1 AND mnt_object='forest') forest_1,
	sum(pixelcount) FILTER (WHERE classe=2 AND mnt_object='forest') forest_2,
	sum(pixelcount) FILTER (WHERE classe=3 AND mnt_object='forest') forest_3,
	sum(pixelcount) FILTER (WHERE classe=4 AND mnt_object='forest') forest_4,
	sum(pixelcount) FILTER (WHERE classe=5 AND mnt_object='forest') forest_5

FROM  
	atlas_pn.pn_emprises a
LEFT JOIN
	atlas_pn.pn_emprises_holdridge b
ON 
	a.gid=b.gid_emprise
GROUP BY 
	gid_emprise, type, name
ORDER BY
	gid_emprise
----------------------------------------------------------------------------------


----------Holdrige2, pour une commune/emprise, distribution milieux et forêt---------

	SELECT gid_emprise, type,name, classe,
	sum(pixelcount) FILTER (WHERE mnt_object='land') land,
	sum(pixelcount) FILTER (WHERE mnt_object='forest') forest
FROM  
	atlas_pn.pn_emprises a
LEFT JOIN
	atlas_pn.pn_emprises_holdridge b
ON 
	a.gid=b.gid_emprise
GROUP BY 
	gid_emprise, type,name, classe
ORDER BY
	gid_emprise,classe
----------------------------------------------------
	
Select gid, name,
--land_area_ha,landum_area_ha,
	--(land_area_ha - coalesce(landum_area_ha,0)) as land_no_um,
	round(((land_area_ha - landum_area_ha)-(forest_area_ha - forest_um_area_ha))::numeric,3) as land_no_um_noforest,
	round((forest_area_ha - forest_um_area_ha)::numeric,3) as land_no_um_forest,

	--landum_area_ha,
	round((landum_area_ha -forest_um_area_ha )::numeric,3) as landum_noforest,
	round(forest_um_area_ha::numeric,3) as landum_forest


from atlas_pn.pn_emprises order by gid



------Occurences per rainfall---------------------------------------
WITH 	grid_data AS (SELECT * FROM generate_series(0,5000,200) as classe),
	land_rainfall AS (SELECT class_rainfall, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE gid_emprise=1 AND mnt_object='land'
			GROUP BY class_rainfall),
	data_rainfall AS (SELECT 200*width_bucket(rainfall,0,5000,25) AS class_rainfall, count(id_species) count_data FROM atlas_pn.pn_data_occurences 
			GROUP BY class_rainfall)
-------
	SELECT 1 as gid, 'land' as mnt_object,classe class_rainfall, COALESCE(pixelcount,0) land_area, COALESCE(count_data,0) data_count
	FROM
		grid_data a
	LEFT JOIN
		land_rainfall b ON a.classe=b.class_rainfall
	LEFT JOIN
		data_rainfall c ON a.classe=c.class_rainfall
	ORDER BY classe
---------------------------------------------------------------------

------Occurences per elevation---------------------------------------
WITH  grid_data AS (SELECT * FROM generate_series(0,1700,100) as classe),
	land_elevation AS (SELECT class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE gid_emprise=1 AND mnt_object='land'
			GROUP BY class_elevation),
	data_elevation AS (SELECT elevation AS class_elevation, count(id_species) count_data FROM atlas_pn.pn_data_occurences 
			GROUP BY class_elevation)
-----------------
SELECT 1 as gid, 'land' as mnt_object, classe class_elevation, COALESCE(pixelcount,0) land_area, COALESCE(count_data,0) data_count
FROM
	grid_data a
LEFT JOIN
	land_elevation b ON a.classe=b.class_elevation
LEFT JOIN
	data_elevation c ON a.classe=c.class_elevation
ORDER BY classe



-----------pluviométrie min et max par commune----------------------------
SELECT gid, type, name, min(class_rainfall), max(class_rainfall) 
FROM  
	atlas_pn.pn_emprises a
LEFT JOIN
	atlas_pn.pn_emprises_raster b ON a.gid=b.gid_emprise
WHERE mnt_object='land' AND pixelcount>0 
GROUP BY gid 
order by gid


-------------rainfall distribution by emprise------------
SELECT gid, class_rainfall, sum(pixelcount) FILTER (WHERE mnt_object='land') as land_count,
sum(pixelcount) FILTER (WHERE mnt_object='forest') as forest_count
FROM  
	atlas_pn.pn_emprises a
LEFT JOIN
	atlas_pn.pn_emprises_raster b ON a.gid=b.gid_emprise
WHERE pixelcount>0
GROUP BY gid, class_rainfall
order by gid, class_rainfall





-- --land_area_ha as total,
-- --landum_area_ha as total_um,
-- --forest_area_ha,forest_100m_ha,land_area_ha,forest_reserve_ha,
-- Select gid, name,
-- (forest_area_ha -forest_100m_ha)/forest_area_ha as forest_secondaire,
-- (forest_100m_ha-forest_ssdm80_ha)/forest_area_ha as forest_mature,
-- forest_ssdm80_ha/forest_area_ha as forest_coeur,
-- 
-- (land_area_ha-forest_area_ha)/land_area_ha as noforest,
-- (forest_area_ha-forest_reserve_ha)/land_area_ha as forest,
-- forest_reserve_ha/land_area_ha as forest_reserve,
-- 
-- 
-- (landum_area_ha-forest_um_area_ha)/landum_area_ha as noforest_um,
-- (forest_um_area_ha -forest_mining_ha)/landum_area_ha as forestum,
-- forest_mining_ha/landum_area_ha as forest_mining,
-- 
-- forest_reserve_ha/forest_area_ha protected_forest,
-- forest_mining_ha,
-- forest_um_area_ha,
-- 
-- land_area_ha, landum_area_ha
-- 
-- 
-- 
-- 
-- 
-- 
-- from atlas_pn.pn_emprises order by gid 