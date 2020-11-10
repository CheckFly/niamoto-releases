--Classify any shapes from atlas_pn.pn_emprises according to  elevation for different forest and land (land, land_um, forest, forest_um, forest_core, forest mature, forest_secondary)
-- return a Table composed of gid, mnt_object (land, land_um, forest, forest_um), class of rainfall (aurelhy by class of 200 mm) and class elevation (srtm90 by class of 100 m)
--to be process to extract elevation or rainfall count by gid_commune
---------------------------------------------------------------------
--------------------------------------------------------------------------
----CREATE the pn_forest_elevation table---------------------------------------
--------------------------------------------------------------------------
DROP TABLE IF EXISTS atlas_pn.pn_forest_elevation CASCADE;
CREATE TABLE atlas_pn.pn_forest_elevation AS
-- (
--   gid_emprise integer NOT NULL,
--   mnt_object text  NOT NULL,
--   class_elevation integer NOT NULL,
--   class_rainfall integer NOT NULL,
--   pixelcount integer,
--   CONSTRAINT table_pn_forest_elevation_pkey PRIMARY KEY (gid_emprise, mnt_object,class_elevation, class_rainfall)
-- );
-- ---------------------------------------------------------------------



WITH
	-- create utm shape to use distance (st_expand)
	shape_emprises_utm AS (SELECT gid, name, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises), -- where gid=1),
	--shape_rainfall_utm AS (SELECT st_transform(geom,32758) geom, 200*width_bucket(grid_code,0, 5000, 25)  rainfall FROM meteo_points_aurelhy_wgs84),

	shape_forest_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
	shape_forestssdm_utm AS (SELECT st_transform(f_geomssdm,32758) geom FROM atlas_pn.pn_carto_forest WHERE f_geomssdm IS NOT NULL),
	shape_forest100_utm AS (SELECT st_transform(f_geom100,32758) geom FROM atlas_pn.pn_carto_forest WHERE f_geom100 IS NOT NULL),
	shape_um_utm AS (SELECT st_transform(geom,32758) geom FROM atlas_pn.pn_emprises WHERE gid=2),
	--Create utm raster (better union raster before use to optimize computing (2 times slower on a splited raster !)
	mnt_union AS (SELECT st_transform(st_union(rast),32758) rast from raster_srtm90_classified_wgs84  WHERE NOT ST_BandIsNoData(rast)),
	--Clip utm_raster by respective utm_shape
	mnt_land AS --clip mnt and emprises --> mnt_land decompose by gid
		(SELECT 
			b.gid,
			'land' ::text as mnt_object,
			st_clip(rast,geom,-9999,true) as rast 
			FROM
				mnt_union a, shape_emprises_utm b
			WHERE 
				ST_Intersects(rast, geom)
		),
	mnt_land_um AS -- union land and um shape
		(SELECT 
			a.gid,
			'land_um' ::text as mnt_object,
			ST_Clip (a.rast,b.geom,-9999, true) as rast
			FROM
				mnt_land a, shape_um_utm b
			WHERE 
				ST_Intersects(a.rast, b.geom) --AND a.gid=b.gid
			
		),
	mnt_forest AS -- union land and forest shape
	(
		SELECT 
			a.gid,
			'forest' ::text as mnt_object,
			st_clip(rast,geom,-9999,true) as rast 
			FROM
				mnt_land a, shape_forest_utm b
			WHERE 
				ST_Intersects(rast, b.geom)
	),
	mnt_forestssdm AS -- union land and forest shape
	(
		SELECT 
			a.gid,
			'forest_core' ::text as mnt_object,
			st_clip(rast,geom,-9999,true) as rast 
			FROM
				mnt_land a, shape_forestssdm_utm b
			WHERE 
				ST_Intersects(rast, b.geom)
	),
	mnt_forest100m AS
	(
		SELECT 
			a.gid,
			'forest_100m' ::text as mnt_object,
			--st_geometrytype(geom)
			st_clip(rast,geom,-9999,true) as rast 
			FROM
				mnt_land a, shape_forest100_utm b
			WHERE 
				ST_Intersects(rast, b.geom) and NOT ST_BandIsNoData(rast,1,true)
	),
	mnt_forestum AS -- union forest and um shape
		(SELECT 
			a.gid,
			'forest_um' ::text as mnt_object,
			ST_Clip (a.rast,b.geom,-9999, true) as rast
			FROM
				mnt_land_um a, shape_forest_utm b --mnt_forest a, shape_um_utm b
			WHERE 
				ST_Intersects(a.rast, b.geom) --AND a.gid=b.gid
		),
	type_object AS (SELECT * FROM (VALUES  ('land'),('land_um'),('forest'),('forest_um'),('forest_core'),('forest_100m')) as t(mnt_object)),
	grid_data AS (SELECT gid,mnt_object,class_elevation 
			FROM generate_series(100,1700,100) class_elevation
			cross join shape_emprises_utm 
			cross join type_object
			order by gid,mnt_object,class_elevation
			),

pn_emprises_raster as (
--CREATE a temporary union query (quicker than join !)
SELECT 
	b.gid,
	--b.name as label,
	b.mnt_object::text,
	--b.class_rainfall::integer,
	b.class_elevation::integer,
	COALESCE(sum(pixelcount),0)::integer pixelcount
FROM
	grid_data b
LEFT JOIN 
	( -- union the classification of rasters
		SELECT gid, mnt_object,(atlas_pn.pn_classifyraster(rast,1,17)).* as rast  FROM mnt_land
	UNION ALL
		SELECT gid, mnt_object,(atlas_pn.pn_classifyraster(rast,1,17)).* as rast  FROM mnt_land_um
	UNION ALL
		SELECT gid, mnt_object,(atlas_pn.pn_classifyraster(rast,1,17)).* as rast  FROM mnt_forest
	UNION ALL
		 SELECT gid, mnt_object,(atlas_pn.pn_classifyraster(rast,1,17)).* as rast  FROM mnt_forestum
	UNION ALL
		SELECT gid, mnt_object,(atlas_pn.pn_classifyraster(rast,1,17)).* as rast  FROM mnt_forestssdm
	UNION ALL
		SELECT gid, mnt_object,(atlas_pn.pn_classifyraster(rast,1,17)).* as rast  FROM mnt_forest100m
	) a
ON b.gid=a.gid AND b.mnt_object=a.mnt_object AND  b.class_elevation=a.classe*100
GROUP BY  b.gid, b.mnt_object,b. class_elevation --classe --,pixelcount --,b.nb_pixels
),
--create intermediary query to be join
	--shape_emprises AS (SELECT gid, name FROM atlas_pn.pn_emprises), -- where gid=2),
	data_elevation_land AS (SELECT gid, class_elevation, sum(pixelcount) pixelcount FROM pn_emprises_raster WHERE mnt_object='land' GROUP BY gid, class_elevation),
	data_elevation_forest AS (SELECT gid, class_elevation, sum(pixelcount) pixelcount FROM pn_emprises_raster WHERE mnt_object='forest' GROUP BY gid, class_elevation),
	data_elevation_landum AS (SELECT gid, class_elevation, sum(pixelcount) pixelcount FROM pn_emprises_raster WHERE mnt_object='land_um' GROUP BY gid, class_elevation),
	data_elevation_forestum AS (SELECT gid, class_elevation, sum(pixelcount) pixelcount FROM pn_emprises_raster WHERE mnt_object='forest_um' GROUP BY gid, class_elevation),
	data_elevation_forest_core AS (SELECT gid, class_elevation, sum(pixelcount) pixelcount FROM pn_emprises_raster WHERE mnt_object='forest_core' GROUP BY gid, class_elevation),
	data_elevation_forest_100m AS (SELECT gid, class_elevation, sum(pixelcount) pixelcount FROM pn_emprises_raster WHERE mnt_object='forest_100m' GROUP BY gid, class_elevation),
--create the final gri table
	grid_elevation AS (SELECT gid,name, series FROM generate_series(100,1700,100) series cross join shape_emprises_utm),
--calculate the ratio to ajust area exactly to total shape area (=ratio to multiply to pixelcount to get ajusted area)
	ratio_pixel AS (SELECT a.gid,
				CASE WHEN sum_land>0 THEN land_area_ha/sum_land ELSE 0 END r_land,
				CASE WHEN sum_landum>0 THEN land_um_area_ha/sum_landum ELSE 0 END r_landum,
				CASE WHEN sum_forest>0 THEN forest_area_ha/sum_forest ELSE 0 END r_forest,
				CASE WHEN sum_forestum>0 THEN forest_um_area_ha/sum_forestum ELSE 0 END r_forestum,
				CASE WHEN sum_forestcore>0 THEN forest_core_ha/sum_forestcore ELSE 0 END r_forestcore,
				--CASE WHEN sum_forest100m>0 THEN (forest_mature_ha+forest_core_ha)/sum_forest100m ELSE 0 END r_forest100m,
				CASE WHEN (sum_forest-sum_forest100m)>0 THEN forest_secondary_ha/(sum_forest-sum_forest100m) ELSE 0 END r_forestsecondary,
				CASE WHEN (sum_forest100m-sum_forestcore)>0 THEN forest_mature_ha/(sum_forest100m-sum_forestcore) ELSE 0 END r_forestmature,
				CASE WHEN (sum_land-sum_forest)>0 THEN (land_area_ha-forest_area_ha)/(sum_land-sum_forest) ELSE 0 END r_noforest

				--land_area_ha, land_um_area_ha, sum_land, sum_landum 
				FROM atlas_pn.pn_emprises a
				LEFT JOIN 
					(SELECT 
						gid gid, 
						sum(pixelcount) FILTER (WHERE mnt_object='land') sum_land,  
						sum(pixelcount) FILTER (WHERE mnt_object='land_um') sum_landum,
						sum(pixelcount) FILTER (WHERE mnt_object='forest') sum_forest,
						sum(pixelcount) FILTER (WHERE mnt_object='forest_um') sum_forestum,
						sum(pixelcount) FILTER (WHERE mnt_object='forest_100m') sum_forest100m ,
						sum(pixelcount) FILTER (WHERE mnt_object='forest_core') sum_forestcore 
					FROM 
						pn_emprises_raster 
					GROUP BY 
						gid
					) b ON a.gid=b.gid
)


--Create the query (join)
SELECT 
	a.gid ::integer, 
	a.name as label::text,
	series ::integer as class_elevation,
-- land.pixelcount,
-- 	landum.pixelcount,	
-- 	forest.pixelcount,
-- 	forestum.pixelcount,
-- 	forestcore.pixelcount,
-- 	forest100m.pixelcount,
-- 	r_land, r_landum, r_forest, r_forestum, r_forestcore,r_forest100m
       

	(land.pixelcount*r_land) ::numeric(10,2) as land_ha,
	(landum.pixelcount*r_landum) ::numeric(10,2)  as land_um_ha,	
	(forest.pixelcount*r_forest) ::numeric(10,2)  as forest_ha,
	(forestum.pixelcount*r_forestum) ::numeric(10,2)  as forest_um_ha,
	((land.pixelcount-forest.pixelcount) *r_noforest) ::numeric(10,2)  as noforest_ha,
	
	--forest100m.pixelcount*r_forest100m as forest_100m_ha,
	((forest.pixelcount-forest100m.pixelcount)*r_forestsecondary) ::numeric(10,2)  as forest_secondary_ha,
	((forest100m.pixelcount-forestcore.pixelcount)* r_forestmature) ::numeric(10,2)  as forest_mature_ha,
	(forestcore.pixelcount*r_forestcore) ::numeric(10,2)  as forest_core_ha,
	(CASE WHEN (land.pixelcount-landum.pixelcount)>0 THEN (forest.pixelcount-forestum.pixelcount)/(land.pixelcount-landum.pixelcount)::numeric ELSE 0 END) ::numeric(7,5)  ratio_forest_num,
	(CASE WHEN landum.pixelcount>0 THEN forestum.pixelcount/landum.pixelcount::numeric ELSE 0 END)::numeric(7,5) ratio_forest_um 
FROM
	grid_elevation a
LEFT JOIN 
	data_elevation_land land ON a.gid=land.gid AND a.series=land.class_elevation
LEFT JOIN 
	data_elevation_landum landum ON a.gid=landum.gid AND a.series=landum.class_elevation
LEFT JOIN 
	data_elevation_forest forest ON a.gid=forest.gid AND a.series=forest.class_elevation
LEFT JOIN 
	data_elevation_forestum forestum ON a.gid=forestum.gid AND a.series=forestum.class_elevation
LEFT JOIN 
	data_elevation_forest_100m forest100m ON a.gid=forest100m.gid AND a.series=forest100m.class_elevation
LEFT JOIN 
	data_elevation_forest_core forestcore ON a.gid=forestcore.gid AND a.series=forestcore.class_elevation
LEFT JOIN
	ratio_pixel z ON z.gid=a.gid		
ORDER BY 
	a.gid, class_elevation
;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
----UPDATE the tree elevation fields included within the pn_emprises table
-------forest_inf_300, forest_300_600, forest_sup_600 --------------------
-----Query returned successfully: 27 rows affected, 22 msec execution time.
--------------------------------------------------------------------------
---SET to zero
UPDATE atlas_pn.pn_emprises SET forest_inf300m_ha=0, forest_300_600m_ha=0, forest_sup600m_ha=0;
--update values
UPDATE atlas_pn.pn_emprises a
SET forest_inf300m_ha=forest_inf_300,
forest_300_600m_ha=forest_300_600,
forest_sup600m_ha=forest_sup_600
FROM
(
				SELECT gid, 
				sum (forest_ha)  FILTER (WHERE class_elevation<=300) forest_inf_300,
				sum (forest_ha)  FILTER (WHERE class_elevation>300 AND class_elevation<=600) forest_300_600,
				sum (forest_ha)  FILTER (WHERE class_elevation>600) forest_sup_600
				FROM atlas_pn.pn_forest_elevation a
				GROUP BY a.gid
) b
WHERE a.gid=b.gid
;
--------------------------------------------------------------------------

