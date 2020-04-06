WITH 
	shape_emprises AS (SELECT gid, name FROM atlas_pn.pn_emprises), -- where gid=2),
	data_elevation_land AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='land' GROUP BY gid_emprise, class_elevation),
	data_elevation_forest AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='forest' GROUP BY gid_emprise, class_elevation),

	data_elevation_landum AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='land_um' GROUP BY gid_emprise, class_elevation),
	data_elevation_forestum AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='forest_um' GROUP BY gid_emprise, class_elevation),

	data_elevation_forest_core AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='forest_core' GROUP BY gid_emprise, class_elevation),
	data_elevation_forest_mature AS (SELECT gid_emprise, class_elevation, sum(pixelcount) pixelcount FROM atlas_pn.pn_emprises_raster WHERE mnt_object='forest_mature' GROUP BY gid_emprise, class_elevation),



	grid_elevation AS (SELECT gid,name, series FROM generate_series(100,1700,100) series cross join shape_emprises),
	area_land_emprise AS (SELECT gid, land_area_ha, land_um_area_ha FROM atlas_pn.pn_emprises),
	ratio_emprise AS (SELECT gid, land_area_ha/sum_land r_land, CASE WHEN sum_landum>0 THEN land_um_area_ha/sum_landum ELSE 0 END r_landum FROM atlas_pn.pn_emprises 
				left join 
				(select gid_emprise, sum(pixelcount) filter (where mnt_object='land') sum_land,  sum(pixelcount) filter (where mnt_object='land_um') sum_landum 
				from atlas_pn.pn_emprises_raster group by gid_emprise) a
				ON gid=gid_emprise)

SELECT 
	a.gid, 
	a.name,
	series as elevation, 
	CASE WHEN b.pixelcount>0 THEN c.pixelcount/b.pixelcount ::numeric ELSE 0 END::numeric(6,4) AS num_forest,
	CASE WHEN d.pixelcount>0 THEN -1*e.pixelcount/d.pixelcount::numeric ELSE 0 END::numeric(6,3) AS um_forest,
	(r_land*c.pixelcount)::numeric(10,4) AS forest, 
	(r_land*(b.pixelcount-c.pixelcount))::numeric(10,4) as noforest, 
	(r_land *(c.pixelcount-h.pixelcount -i.pixelcount))::numeric(10,4) as forest_secondary,
	(r_land*i.pixelcount)::numeric(10,4) as forest_mature,
	(r_land*h.pixelcount)::numeric(10,4) as forest_core
FROM
	grid_elevation a 
LEFT JOIN 
	data_elevation_land b ON a.gid=b.gid_emprise AND a.series=b.class_elevation
LEFT JOIN 
	data_elevation_forest c ON a.gid=c.gid_emprise AND a.series=c.class_elevation
LEFT JOIN 
	data_elevation_landum d ON a.gid=d.gid_emprise AND a.series=d.class_elevation
LEFT JOIN 
	data_elevation_forestum e ON a.gid=e.gid_emprise AND a.series=e.class_elevation
LEFT JOIN 
	area_land_emprise f ON a.gid=f.gid
LEFT JOIN 
	ratio_emprise g ON a.gid=g.gid
LEFT JOIN 
	data_elevation_forest_core h ON a.gid=h.gid_emprise AND a.series=h.class_elevation
LEFT JOIN 
	data_elevation_forest_mature i ON a.gid=i.gid_emprise AND a.series=i.class_elevation
ORDER BY gid, elevation
