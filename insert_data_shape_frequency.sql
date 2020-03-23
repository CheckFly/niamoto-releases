

--Delete and fill the data_shape_frequency in the niamoto portal
--DELETE FROM niamoto_portal.data_shape_frequency;
WITH 
	shape_emprises AS (SELECT gid, name FROM atlas_pn.pn_emprises),
	data_elevation_land AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='land' GROUP BY gid_emprise, class_elevation),
	data_elevation_forest AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='forest' GROUP BY gid_emprise, class_elevation),

	data_elevation_landum AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='land_um' GROUP BY gid_emprise, class_elevation),
	data_elevation_forestum AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='forest_um' GROUP BY gid_emprise, class_elevation),

	grid_elevation AS (SELECT gid,name, series FROM generate_series(100,1700,100) series cross join shape_emprises),
	area_land_emprise AS (SELECT gid, land_area_ha, landum_area_ha FROM atlas_pn.pn_emprises),
	ratio_emprise AS (SELECT gid, CASE WHEN sum_land>0 then land_area_ha/sum_land ELSE 0 END r_land, CASE WHEN sum_landum>0 then landum_area_ha/sum_landum ELSE 0 END r_landum FROM atlas_pn.pn_emprises 
				LEFT JOIN 
				(SELECT gid_emprise, sum(pixelcount) filter (where mnt_object='land') sum_land,  sum(pixelcount) filter (where mnt_object='land_um') sum_landum 
				FROM atlas_pn.pn_emprises_raster GROUP BY gid_emprise) a
				ON gid=gid_emprise
			 )







INSERT INTO niamoto_portal.data_shape_frequency (shape_id, class_object, class_name, class_value)
	SELECT a.gid shape_id, 'land_elevation' as class_object, series as class_name, round(coalesce(r_land*b.pixelcount,0)::numeric,0) as class_value
	FROM grid_elevation a
	LEFT JOIN data_elevation_land b
	ON a.gid=b.gid_emprise and a.series=b.class_elevation
	LEFT JOIN ratio_emprise g
	ON a.gid=g.gid

UNION ALL

SELECT a.gid shape_id, 'forest_elevation' as class_object, series as class_name, round(coalesce(b.pixelcount,0)::numeric,0) as class_value
FROM grid_elevation a
LEFT JOIN data_elevation_forest b
ON a.gid=b.gid_emprise and a.series=b.class_elevation
LEFT JOIN ratio_emprise g
ON a.gid=g.gid


UNION ALL

SELECT a.gid shape_id, 'land_um_elevation' as class_object, series as class_name, round(r_land*coalesce(b.pixelcount,0)::numeric,0) as class_value
FROM grid_elevation a
LEFT JOIN data_elevation_landum b
ON a.gid=b.gid_emprise and a.series=b.class_elevation
LEFT JOIN ratio_emprise g
ON a.gid=g.gid

UNION ALL

SELECT a.gid shape_id, 'forest_um_elevation' as class_object, series as class_name, round(r_land*coalesce(b.pixelcount,0)::numeric,0) as class_value
FROM grid_elevation a
LEFT JOIN data_elevation_forestum b
ON a.gid=b.gid_emprise and a.series=b.class_elevation
LEFT JOIN ratio_emprise g
ON a.gid=g.gid

UNION ALL

SELECT a.gid shape_id, 'ratio_forest_num_elevation' as class_object, series as class_name, case when (coalesce(r_land*b1.pixelcount,0)-coalesce(r_land*b2.pixelcount,0))=0 then 0 else  round((r_land*coalesce(c1.pixelcount,0)-r_land*coalesce(c2.pixelcount,0))/(coalesce(r_land*b1.pixelcount,0)-coalesce(r_land*b2.pixelcount,0))::numeric,5) end as class_value
	FROM grid_elevation a
	LEFT JOIN data_elevation_land b1
	ON a.gid=b1.gid_emprise and a.series=b1.class_elevation
	LEFT JOIN data_elevation_forest c1
    ON a.gid=c1.gid_emprise and a.series=c1.class_elevation
    LEFT JOIN data_elevation_landum b2
    ON a.gid=b2.gid_emprise and a.series=b2.class_elevation
    LEFT JOIN data_elevation_forestum c2
    ON a.gid=c2.gid_emprise and a.series=c2.class_elevation 
	LEFT JOIN ratio_emprise g
	ON a.gid=g.gid
	
UNION ALL

SELECT a.gid shape_id, 'ratio_forest_um_elevation' as class_object, series as class_name, case when coalesce(r_land*b.pixelcount,0)=0 then 0 else  round(r_land*coalesce(c.pixelcount,0)/coalesce(r_land*b.pixelcount,0)::numeric,5) end as class_value
FROM grid_elevation a
LEFT JOIN data_elevation_landum b
ON a.gid=b.gid_emprise and a.series=b.class_elevation
LEFT JOIN data_elevation_forestum c
ON a.gid=c.gid_emprise and a.series=c.class_elevation 
LEFT JOIN ratio_emprise g
ON a.gid=g.gid

;
