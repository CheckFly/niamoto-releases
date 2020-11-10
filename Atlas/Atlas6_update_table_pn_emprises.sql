------------------------------------------------------
--dependecies
--atlas_pn.pn_emprises, atlas_pn.pn_carto_forest
--
--DROP TABLE IF EXISTS atlas_pn.pn_emprises_forest CASCADE;
--CREATE TABLE atlas_pn.pn_emprises_forest AS


-----------------------------------------------------------------------	
---Query returned successfully: 01:25:24 hours execution time.
--Query returned successfully: 0 rows affected, 01:37:10 hours execution time.
--Query returned successfully: 0 rows affected, 01:36:49 hours execution time.
-----------------------------------------------------------------------	

-----------------------------------------------------------------------		
---------------Update land & land_um area (in hectare)
-----------------------------------------------------------------------		
	UPDATE atlas_pn.pn_emprises a
	SET land_area_ha=st_area(st_transform(geom,32758))/10000
	--,	    land_um_area_ha=st_area(st_transform(um_geom,32758))/10000
;

---------------------------------------------
---------------Update land_um_area_ha,mining_um_area_ha,reserve_area_ha (in hectare)
----Query returned successfully: 27 rows affected, 20.1 secs execution time.
-----------------------------------------------------------------------	
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_um_utm AS (SELECT (st_dump(st_transform(geom,32758))).geom geom FROM atlas_pn.pn_emprises WHERE gid=2),
		
		shape_reserve_utm AS (SELECT st_transform(geom, 32758) geom FROM atlas_pn.pn_emprises WHERE type='Réserve'),
		--shape_mining_utm AS (SELECT st_union(st_makevalid(st_transform(geom, 32758))) geom FROM dimenc_cadastre_minier_wgs84),
		shape_mining_utm AS (SELECT (st_dump(st_transform(geom, 32758))).geom geom FROM dimenc_cadastre_minier_wgs84),
		shape_emprises_um_utm AS 
			(SELECT gid, 
				CASE WHEN gid<=2 THEN b.geom ELSE st_intersection(a.geom,b.geom) END geom
				FROM shape_emprises_utm a, shape_um_utm b 
				WHERE b.geom IS NOT NULL AND ST_Intersects(a.geom,b.geom)
			),
		shape_mining_um_utm AS (
		
			SELECT gid, sum(st_area(st_intersection (a.geom, b.geom))) mining_area
				FROM shape_emprises_um_utm a, shape_mining_utm b
				
			WHERE 
				a.geom IS NOT NULL AND ST_Intersects(a.geom,b.geom)
			GROUP by gid
		),
		shape_reserve_um_utm AS (
			SELECT gid, sum(st_area(st_intersection (a.geom, b.geom))) reserve_area
				FROM shape_emprises_um_utm a, shape_reserve_utm b
			WHERE 
				a.geom IS NOT NULL AND ST_Intersects(a.geom,b.geom)
			GROUP by gid
		)


		
------------------------------------------
	UPDATE atlas_pn.pn_emprises a
	SET 
		mining_um_area_ha=COALESCE(b.mining_um_area,0)::numeric,
		reserve_area_ha=COALESCE(b.reserve_um_area,0)::numeric,
		land_um_area_ha=COALESCE(b.um_area,0)::numeric
	FROM			
		(SELECT 
			a.gid, 
			sum(st_area(a.geom))/10000 as um_area,
			mining_area/10000 as mining_um_area,
			reserve_area/10000 as reserve_um_area
		FROM 
			shape_emprises_um_utm a
		LEFT JOIN shape_mining_um_utm b on a.gid=b.gid
		LEFT JOIN shape_reserve_um_utm c on a.gid=c.gid
		GROUP BY a.gid, mining_area,reserve_area
		--ORDER BY gid
		) b
;
-----------------------------------------------------------------------


	-- 
-- 			
-- -------------------------------------			
-- 	UPDATE atlas_pn.pn_emprises a
-- 	SET 
-- 		mining_um_area_ha=COALESCE(b.mining_um_area/10000,0)::numeric,
-- 	FROM 
-- 	(SELECT 
-- 		gid, sum(st_area(st_intersection (a.geom, b.geom))) as mining_um_area,
-- 		sum (st_area(a.geom)) as um_area
-- 	FROM 
-- 		shape_emprises_um_utm a, shape_mining_utm b
-- 	WHERE 
-- 		ST_Intersects(a.geom,b.geom)
-- 	GROUP BY gid) b
-- 	WHERE a.gid=b.gid
-- ;




--update landum_atrea
-- -----------------------------------------------------------------------		
-- --------------update reserve_UM_area_ha (UM area covered by reserves)
-- ---Query returned successfully: 9 rows affected, 1.2 secs execution time.
-- -----------------------------------------------------------------------			
-- 	WITH 
-- 		shape_emprises_um_utm AS (SELECT gid, st_transform(um_geom,32758) geom FROM atlas_pn.pn_emprises),
-- 		shape_reserve_utm AS (SELECT st_transform(geom, 32758) geom FROM  atlas_pn.pn_emprises where type='Réserve')
-- 	UPDATE atlas_pn.pn_emprises a
-- 	SET 
-- 		reserve_um_area_ha=COALESCE(.reserve_um_area_ha/10000,0)::numeric
-- 	FROM 
-- 	(SELECT 
-- 		gid, sum(st_area(st_intersection (a.geom, b.geom))) as reserve_um_area_ha
-- 	FROM 
-- 		shape_emprises_um_utm a, shape_reserve_utm b
-- 	WHERE 
-- 		ST_Intersects(a.geom,b.geom)
-- 	GROUP BY gid) b
-- 	WHERE a.gid=b.gid
-- ;
-- -------------------------------------------------------------------------
-- -----------------------------------------------------------------------		
-- --------------update mining_UM_area_ha (UM area covered by mining)
-- ---Query returned successfully: 19 rows affected, 02:46 minutes execution time.
-- -----------------------------------------------------------------------			
-- 	WITH 
-- 		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
-- 		shape_um_utm AS (SELECT st_transform(geom,32758) geom FROM atlas_pn.pn_emprises WHERE gid=2),
-- 		shape_mining_utm AS (SELECT st_union(st_makevalid(st_transform(geom, 32758))) geom FROM dimenc_cadastre_minier_wgs84),
-- 		shape_emprises_um_utm AS 
-- 			(SELECT gid, 
-- 				CASE WHEN gid<=2 THEN b.geom ELSE (st_dump(st_intersection(a.geom,b.geom))).geom END geom
-- 				FROM shape_emprises_utm a, shape_um_utm b 
-- 				WHERE b.geom IS NOT NULL AND ST_Intersects(a.geom,b.geom)
-- 			)
-- -------------------------------------			
-- 	UPDATE atlas_pn.pn_emprises a
-- 	SET 
-- 		mining_um_area_ha=COALESCE(b.mining_um_area/10000,0)::numeric,
-- 	FROM 
-- 	(SELECT 
-- 		gid, sum(st_area(st_intersection (a.geom, b.geom))) as mining_um_area,
-- 		sum (st_area(a.geom)) as um_area
-- 	FROM 
-- 		shape_emprises_um_utm a, shape_mining_utm b
-- 	WHERE 
-- 		ST_Intersects(a.geom,b.geom)
-- 	GROUP BY gid) b
-- 	WHERE a.gid=b.gid
-- ;
-- -------------------------------------------------------------------------

-----------------------------------------------------------------------		
---------------Update Rainfal min & max (in millimeter)
--Query returned successfully: 27 rows affected, 14.4 secs execution time.
-----------------------------------------------------------------------
WITH 
	shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
	shape_rainfall_utm AS (SELECT st_transform(geom,32758) geom, grid_code rainfall FROM meteo_points_aurelhy_wgs84),
	rainfall AS (SELECT
		gid, min(rainfall) min_rainfall, max(rainfall) max_rainfall
		FROM
			shape_emprises_utm a,  shape_rainfall_utm b
		WHERE 
			st_coveredby (b.geom, a.geom)
		GROUP BY gid
		)
	 UPDATE atlas_pn.pn_emprises a
		SET 
			rainfall_min=min_rainfall::integer, 
			rainfall_max=max_rainfall::integer
		FROM rainfall b
		WHERE
			a.gid=b.gid

;
-----------------------------------------------------------------------		
---------------Update altitude median, max (in meter)
--Query returned successfully: 27 rows affected, 48.5 secs execution time.
-----------------------------------------------------------------------
	WITH 
		shape_emprises_utm AS (SELECT gid, name, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		mnt_union AS (SELECT st_transform(st_union(rast),32758) rast from raster_mnt_srtm90  WHERE NOT ST_BandIsNoData(rast)),
		mnt_land AS --clip mnt and emprises --> mnt_land decompose by gid
				(SELECT 
					b.gid,
					name,
					st_clip(rast,geom,-9999,true) as rast 
					FROM
						mnt_union a, shape_emprises_utm b
					WHERE 
						ST_Intersects(rast, geom)
				),
		mnt_stats AS 
			(SELECT gid,max(val) AS max_elevation,percentile_cont(0.50) WITHIN GROUP (ORDER BY val asc) AS median_elevation from 
				(SELECT gid, (st_pixelaspolygons(rast)).* from mnt_land) b
				WHERE val>=0
				GROUP BY gid
		)
		UPDATE atlas_pn.pn_emprises a
		SET 
			elevation_median=median_elevation::integer, 
			elevation_max=max_elevation::integer
		FROM mnt_stats b
		WHERE
			a.gid=b.gid
		
;

		
-------------------------------------------------------------------------		
--------------Update forest_area_ha & forest_um_area_ha-----------------------------
---Query returned successfully: 23 rows affected, 58:02 minutes execution time.
--carto_pn3 -->Query returned successfully: 27 rows affected, 02:45:45 hours execution time.
-----------------------------------------------------------------------		
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom, st_buffer(st_transform(geom,32758),1) geom_buff FROM atlas_pn.pn_emprises),
		shape_um_utm AS (SELECT st_transform(geom,32758) geom FROM atlas_pn.pn_emprises WHERE gid=2),
		shape_carto_pn_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
		shape_forest_emprises_utm AS 
			(SELECT a.gid, 
				CASE 
					WHEN gid=1 then TRUE
					ELSE ST_Contains(a.geom_buff, b.geom) ---add a 1m buffer to emrpise geom ensure to include patch sharing boundaries
				END as is_within,
				CASE 
					WHEN gid=1 then b.geom
					ELSE st_intersection(a.geom,b.geom) 
				END as geom 
			FROM shape_emprises_utm a, shape_carto_pn_utm b WHERE ST_Intersects(a.geom,b.geom)
			)
	UPDATE atlas_pn.pn_emprises a
	SET 
		forest_area_ha=COALESCE(b.forest_area/10000,0)::numeric, 
		forest_in_ha=COALESCE(b.forest_in /10000,0)::numeric, 
		forest_um_area_ha=COALESCE(b.forest_um_area/10000,0)::numeric, 
		forest_perimeter_km=COALESCE(b.forest_perimeter/1000,0)::numeric,
	--patchiness
		nb_patchs=COALESCE(b.nb_patchs,0)::integer, 
		nb_patchs_in=COALESCE(b.nb_patchs_in,0)::integer, 
		--r_in_median=b.r_in_median,
		forest_geom=st_transform(st_simplify(st_multi(b.forest_geom) ,100,false),4326) ::geometry(MultiPolygon,4326)
		--forest_geom=st_transform(st_multi(b.forest_geom),4326) ::geometry(MultiPolygon,4326)
	FROM	
		(SELECT
			a.gid,
			sum(st_area(a.geom)) as forest_area,
			sum(st_area(st_intersection(a.geom,b.geom))) as forest_um_area,
			--TODO --Attention le périmètre est pas exact car les fragments interceptés par la commune sont faussement tronqués
				--soit on filtre sur les patchs is_within soit on recalcul autrement !!
			sum(st_perimeter(a.geom))as forest_perimeter,
			count(a.geom) as nb_patchs,
			count(a.geom) FILTER (WHERE a.is_within) as nb_patchs_in,
			sum(st_area(a.geom)) FILTER (WHERE a.is_within) as forest_in,
			percentile_cont(0.50) 
				WITHIN GROUP (ORDER BY
				(2*PI()*sqrt(st_area(a.geom)/PI()))/ST_perimeter(a.geom) asc)  
				FILTER (WHERE a.is_within) 
			AS r_in_median,
			st_union(a.geom) forest_geom
			--st_union(a.geom) FILTER (WHERE NOT a.is_within) interforest_geom 
		FROM 
			shape_forest_emprises_utm a
		LEFT JOIN  --left join to conserve emprise that didn't get um_area
			shape_um_utm b
		ON
			ST_Intersects(a.geom,b.geom)
		WHERE 
			a.geom IS NOT NULL
		GROUP BY gid
		) b
	WHERE 
		a.gid=b.gid
;	
-----------------------------------------------------------------------
-----------------------------------------------------------------------	    
-----------------------------------------------------------------------		
--------------update ppe_area_ha (area covered by perimeter of water conservation)
--Query returned successfully: 24 rows affected, 10.1 secs execution time.
-----------------------------------------------------------------------		

	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_ppe_utm AS (SELECT st_transform(geom, 32758) geom FROM atlas_pn.pn_emprises WHERE gid=3)
		
	UPDATE atlas_pn.pn_emprises a
	SET 
		ppe_area_ha=COALESCE(b.ppe_area/10000,0)::numeric
	FROM 
	(

	SELECT 
		gid,
		CASE WHEN gid = 1 OR gid = 3 THEN st_area(b.geom)
		ELSE sum(st_area(st_intersection (a.geom, b.geom))) 
		END as ppe_area
	FROM 
		shape_emprises_utm a, shape_ppe_utm b
	WHERE 
		ST_Intersects(a.geom,b.geom)
	GROUP BY gid, b.geom

	 ) b
	WHERE a.gid=b.gid
;

-----------------------------------------------------------------------		
-------------- update forest_ppe_ha -------------------------------
---Query returned successfully: 24 rows affected, 22:33 minutes execution time.
-----------------------------------------------------------------------		
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_carto_pn_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
		shape_ppe_utm AS (SELECT st_transform(geom, 32758) geom FROM atlas_pn.pn_emprises WHERE gid=3),
		shape_forest_ppe_utm AS
			(SELECT st_intersection(a.geom,b.geom) geom
			   FROM shape_carto_pn_utm a, shape_ppe_utm b 
			  WHERE ST_Intersects(a.geom,b.geom)
			),
		shape_forest_ppe_emprises_utm AS 
			(SELECT gid, coalesce(st_area(st_intersection(a.geom,b.geom)),0) area
			FROM shape_emprises_utm a, shape_forest_ppe_utm b WHERE b.geom IS NOT NULL AND ST_Intersects(a.geom,b.geom)
			)
	UPDATE 
		atlas_pn.pn_emprises a
	SET 
		forest_ppe_ha=COALESCE(b.area/10000,0)::numeric
	FROM
		(SELECT gid, sum(area) area FROM shape_forest_ppe_emprises_utm b GROUP BY gid) b
	WHERE
		a.gid=b.gid
;


-----------------------------------------------------------------------		
--------------update mining_area_ha (area covered by mining)
---Query returned successfully: 16 rows affected, 02:07 minutes execution time
-----------------------------------------------------------------------		
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_mining_utm AS (SELECT st_union(st_transform(geom, 32758)) geom FROM dimenc_cadastre_minier_wgs84)
		
	UPDATE atlas_pn.pn_emprises a
	SET 
		mining_area_ha=COALESCE(b.mining_area/10000,0)
	FROM 
	(SELECT 
		gid, sum(st_area(st_intersection (a.geom, b.geom))) as mining_area
	FROM 
		shape_emprises_utm a, shape_mining_utm b
	WHERE 
		ST_Intersects(a.geom,b.geom)
	GROUP BY gid) b
	WHERE a.gid=b.gid
;
-----------------------------------------------------------------------	    

	


-----------------------------------------------------------------------		
--------------update reserve_area_ha (area covered by reserves)
---Query returned successfully: 13 rows affected, 4.8 secs execution time.
-----------------------------------------------------------------------			
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_reserve_utm AS (SELECT st_transform(geom, 32758) geom FROM atlas_pn.pn_emprises where type='Réserve')
	UPDATE atlas_pn.pn_emprises a
	SET 
		reserve_area_ha=COALESCE(b.reserve_area_ha/10000,0)::numeric
	FROM 
	(SELECT 
		gid, sum(st_area(st_intersection (a.geom, b.geom))) as reserve_area_ha
	FROM 
		shape_emprises_utm a, shape_reserve_utm b
	WHERE 
		ST_Intersects(a.geom,b.geom)
	GROUP BY gid) b
	WHERE a.gid=b.gid
;
-------------------------------------------------------------------------







-----------------------------------------------------------------------
-- ---TO DELETED		
-- --------------update forest_100m_ha------------------------------------
-- --Query returned successfully: 21 rows affected, 02:54 minutes execution time.
-- -----------------------------------------------------------------------
-- 	WITH 
-- 		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
-- 		shape_carto_pn_utm AS (SELECT st_transform(f_geom100,32758) geom FROM atlas_pn.pn_carto_forest),
-- 		shape_forest_emprises_utm AS
-- 			(SELECT a.gid, 
-- 				CASE 
-- 					WHEN gid=1 then st_area(b.geom) --for the province, the entire geom
-- 					ELSE st_area(st_intersection(a.geom,b.geom)) 
-- 				END as area 
-- 			FROM shape_emprises_utm a, shape_carto_pn_utm b 
-- 			WHERE ST_Intersects(a.geom,b.geom)
-- 			)
-- 	UPDATE 
-- 		atlas_pn.pn_emprises a
-- 	SET 
-- 		forest_100m_ha=b.area /10000
-- 	FROM
-- 		(SELECT gid, sum(area) area FROM shape_forest_emprises_utm b GROUP BY gid) b
-- 	WHERE
-- 		a.gid=b.gid
-- ;
-- -----------------------------------------------------------------------
---REPLACE BY-----------------------------------------------------------------------		
--------------update forest_secondary_ha------------------------------------
--Query returned successfully: 21 rows affected, 02:54 minutes execution time.
-----------------------------------------------------------------------
--By default forest_secondary = forest_area to avoid error when there is so few forest that no secondary forest is available (less than 100 m)
--UPDATE atlas_pn.pn_emprises set forest_secondary_ha=forest_area_ha;

	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_carto_pn_utm AS (SELECT st_transform(f_geom100,32758) geom FROM atlas_pn.pn_carto_forest),
		shape_forest_emprises_utm AS
			(SELECT a.gid, 
				CASE 
					WHEN gid=1 then st_area(b.geom) --for the province, the entire geom
					ELSE st_area(st_intersection(a.geom,b.geom)) 
				END as area 
			FROM shape_emprises_utm a LEFT JOIN shape_carto_pn_utm b 
			ON ST_Intersects(a.geom,b.geom)
			)
	UPDATE 
		atlas_pn.pn_emprises a
	SET 
		forest_secondary_ha=COALESCE(forest_area_ha - area,0)::numeric
	FROM
		(SELECT gid,  COALESCE(sum(area),0) / 10000 area FROM shape_forest_emprises_utm b GROUP BY gid) b
	WHERE
		a.gid=b.gid
;
-----------------------------------------------------------------------


-- ---TO DELETED--------------------------------------------------------------------		
-- ---------------- update forest_ssdm80_ha ------------------------------
-- --Query returned successfully: 21 rows affected, 11.7 secs execution time.
-- -----------------------------------------------------------------------		
-- 	WITH 
-- 		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
-- 		shape_ssdm_utm AS (SELECT st_transform(f_geomssdm, 32758) geom FROM atlas_pn.pn_carto_forest WHERE f_geomssdm is not null),
-- 		shape_emprises_ssdm_utm AS 
-- 			(SELECT a.gid, 
-- 				CASE 
-- 					WHEN gid=1 then b.geom --for the province, the entire geom
-- 					ELSE st_intersection(a.geom,b.geom) 
-- 				END as geom 
-- 			FROM shape_emprises_utm a, shape_ssdm_utm b WHERE ST_Intersects(a.geom,b.geom)
-- 			)
-- 
-- 	---update the field 'forest_ssdm80_ha' of the table 'atlas_pn.pn_emprises'
-- 	UPDATE
-- 		atlas_pn.pn_emprises a
-- 	SET 
-- 		forest_ssdm80_ha=b.area/10000
-- 	FROM
-- 		(SELECT gid, sum(st_area(geom)) area FROM shape_emprises_ssdm_utm b GROUP BY gid) b
-- 	WHERE
-- 		a.gid=b.gid
-- ;
-- ---REPLACE BY--------------------------------------------------------------------
-----------------------------------------------------------------------	
---------------- update forest_core_ha ------------------------------
--Query returned successfully: 27 rows affected, 24 msec execution time.
-----------------------------------------------------------------------		
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_ssdm_utm AS (SELECT st_transform(f_geomssdm, 32758) geom FROM atlas_pn.pn_carto_forest WHERE f_geomssdm is not null),
		shape_emprises_ssdm_utm AS 
			(SELECT a.gid, 
				CASE 
					WHEN gid=1 then b.geom --for the province, the entire geom
					ELSE st_intersection(a.geom,b.geom) 
				END as geom 
			FROM shape_emprises_utm a LEFT JOIN shape_ssdm_utm b ON ST_Intersects(a.geom,b.geom)
			)

	---update the field 'forest_core_ha' of the table 'atlas_pn.pn_emprises'
	UPDATE
		atlas_pn.pn_emprises a
	SET 
		forest_core_ha=COALESCE(area,0)::numeric,
		forest_mature_ha=COALESCE(forest_area_ha-forest_secondary_ha-area,0)::numeric
	FROM
		(SELECT gid, COALESCE(sum(st_area(geom)),0) / 10000 area FROM shape_emprises_ssdm_utm b GROUP BY gid) b
	WHERE
		a.gid=b.gid
;

-----------------------------------------------------------------------	
-----------------------------------------------------------------------
-----------------------------------------------------------------------	




-----------------------------------------------------------------------		
--------------update forest_mining_ha-----------------------------
--Query returned successfully: 21 rows affected, 26:58 minutes execution time.
-----------------------------------------------------------------------		
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_mining_utm AS (SELECT st_union(st_transform(geom, 32758)) geom FROM dimenc_cadastre_minier_wgs84),
		shape_carto_pn_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
		shape_forest_emprises_utm AS ---crop forest by emprises
			(SELECT a.gid, 
				CASE 
					WHEN gid=1 then b.geom --for the province, the entire geom
					ELSE st_intersection(a.geom,b.geom) 
				END as geom 
			FROM shape_emprises_utm a, shape_carto_pn_utm b WHERE ST_Intersects(a.geom,b.geom)
			),
		shape_forest_mining_utm AS --intersect forest_by_emprises and shape_mining
			(SELECT a.gid, st_area(st_intersection(a.geom,b.geom)) area
			   FROM shape_forest_emprises_utm a, shape_mining_utm b 
			  WHERE ST_Intersects(a.geom,b.geom)
			)
	UPDATE 
		atlas_pn.pn_emprises a
	SET 
		forest_mining_ha=COALESCE(b.area/10000,0)::numeric
	FROM
		(SELECT gid, sum(area) area FROM shape_forest_mining_utm b GROUP BY gid) b
	WHERE
		a.gid=b.gid
;
-----------------------------------------------------------------------		



-----------------------------------------------------------------------		
-------------- update forest_reserve_ha -------------------------------
---Query returned successfully: 6 rows affected, 02:59 minutes execution time.
-----------------------------------------------------------------------		
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_carto_pn_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
		shape_reserve_utm AS (SELECT st_transform(geom, 32758) geom FROM  atlas_pn.pn_emprises where type='Réserve'),
		shape_forest_emprises_utm AS 
			(SELECT a.gid, 
				CASE 
					WHEN gid=1 then b.geom --for the province, the entire geom
					ELSE st_intersection(a.geom,b.geom) 
				END as geom 
			FROM shape_emprises_utm a, shape_carto_pn_utm b WHERE ST_Intersects(a.geom,b.geom)
			),
		shape_forest_reserve_utm AS
			(SELECT a.gid, st_area(st_intersection(a.geom,b.geom)) area
			   FROM shape_forest_emprises_utm a, shape_reserve_utm b 
			  WHERE ST_Intersects(a.geom,b.geom)
			)
	UPDATE 
		atlas_pn.pn_emprises a
	SET 
		forest_reserve_ha=COALESCE(b.area/10000,0)::numeric
	FROM
		(SELECT gid, sum(area) area FROM shape_forest_reserve_utm b GROUP BY gid) b
	WHERE
		a.gid=b.gid
;
-----------------------------------------------------------------------	
---------------- update f_holdridge1_ha, f_holdridge2_ha,f_holdridge3_ha
-----------------update land_holdridge1_ha, land_holdridge2_ha, land_holdridge3_ha
-----------------from raster_holdrige_wgs84 
WITH
	shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
	mnt_holdrige_utm AS (SELECT st_transform(rast, 32758) rast from raster_holdrige_wgs84 WHERE NOT ST_BandIsNoData(rast,1,true)),
	shape_forest_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
	shape_forest_emprise AS
		(SELECT gid, geom 
		FROM 
			(SELECT gid, 
			CASE WHEN gid=1 THEN a.geom ELSE st_intersection (a.geom, b.geom) END geom
			FROM shape_forest_utm a, shape_emprises_utm b
			WHERE ST_Intersects(a.geom, b.geom)
			) b  
		WHERE ST_GeometryType (geom) IN ( 'ST_Polygon','ST_MultiPolygon')
		),
	data_holdridge_land AS (
		SELECT gid, classe as classe_holdridge, sum(pixelcount) pixelcount FROM
			(SELECT gid, (atlas_pn.pn_classifyraster(st_clip(rast,geom,-9999,true),1,3)).* 
			FROM mnt_holdrige_utm a, shape_emprises_utm b 
			WHERE ST_Intersects(rast, geom)
			) b
		GROUP BY gid, classe_holdridge
	),
	data_holdridge_forest AS (
		SELECT gid, classe as classe_holdridge, sum(pixelcount) pixelcount FROM
			(SELECT gid, (atlas_pn.pn_classifyraster(st_clip(rast,geom,-9999,true),1,3)).* 
			FROM mnt_holdrige_utm a, shape_forest_emprise b 
			WHERE ST_Intersects(rast, geom)
			) b
		GROUP BY gid, classe_holdridge
	),
	grid_holdridge AS (SELECT gid, series FROM generate_series(1,3) series cross join shape_emprises_utm),
	area_land_emprise AS (SELECT gid, land_area_ha, forest_area_ha FROM atlas_pn.pn_emprises)
------------------------------------------------------------------------------
	UPDATE 
		atlas_pn.pn_emprises a
	SET 
		forest_holdridge1_ha=COALESCE(r_forest*forest_holdridge1,0)::numeric,
		forest_holdridge2_ha=COALESCE(r_forest*forest_holdridge2,0)::numeric,
		forest_holdridge3_ha=COALESCE(r_forest*forest_holdridge3,0)::numeric,
		land_holdridge1_ha=COALESCE(r_land*land_holdridge1,0)::numeric,
		land_holdridge2_ha=COALESCE(r_land*land_holdridge2,0)::numeric,
		land_holdridge3_ha=COALESCE(r_land*land_holdridge3,0)::numeric
	FROM
		(SELECT
			a.gid, 
			sum(b.pixelcount) FILTER (WHERE b.classe_holdridge=1) AS land_holdridge1,
			sum(b.pixelcount) FILTER (WHERE b.classe_holdridge=2) AS land_holdridge2,
			sum(b.pixelcount) FILTER (WHERE b.classe_holdridge=3) AS land_holdridge3,
			sum(c.pixelcount) FILTER (WHERE c.classe_holdridge=1) AS forest_holdridge1,
			sum(c.pixelcount) FILTER (WHERE c.classe_holdridge=2) AS forest_holdridge2,
			sum(c.pixelcount) FILTER (WHERE c.classe_holdridge=3) AS forest_holdridge3,
			CASE WHEN sum(b.pixelcount)=0 THEN 0 ELSE land_area_ha/sum(b.pixelcount) END as r_land,
			CASE WHEN sum(c.pixelcount)=0 THEN 0 ELSE forest_area_ha/sum(c.pixelcount) END as r_forest
		FROM
			grid_holdridge a
		LEFT JOIN 
			area_land_emprise f ON a.gid=f.gid
		LEFT JOIN 
			data_holdridge_land b ON a.gid=b.gid AND a.series=b.classe_holdridge
		LEFT JOIN 
			data_holdridge_forest c ON a.gid=c.gid AND a.series=c.classe_holdridge
		GROUP BY a.gid, forest_area_ha, land_area_ha
		) b
	WHERE a.gid=b.gid
	;	

---------------- update f_holdridge1_ha, f_holdridge2_ha,f_holdridge3_ha
-----------------udate forest_inf300m_ha, forest_300_600m_ha, forest_sup600m_ha
-----------------update land_holdridge1_ha, land_holdridge2_ha, land_holdridge3_ha
-----------------from atlas_pn.pn_emprises_raster 
--Query returned successfully: 27 rows affected, 284 msec execution time.
-----------------------------------------------------------------------	
-- 	
-- 	WITH 
-- 		emprises AS (SELECT * from atlas_pn.pn_emprises),
-- 		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
-- 		 forest_elevation AS
-- 			(SELECT gid, 
-- 				sum (forest_ha)  FILTER (WHERE class_elevation<=300) forest_inf_300,
-- 				sum (forest_ha)  FILTER (WHERE class_elevation>300 AND class_elevation<=600) forest_300_600,
-- 				sum (forest_ha)  FILTER (WHERE class_elevation>600) forest_sup_600
-- 				FROM atlas_pn.pn_emprises_raster a
-- 				GROUP BY a.gid
-- 			),
-- 		forest_holdridge AS
-- 			(SELECT gid_emprise gid,
-- 				forest_holdridge1*(forest_area_ha/total) forest_holdrige1,
-- 				forest_holdridge2*(forest_area_ha/total) forest_holdrige2,
-- 				forest_holdridge3*(forest_area_ha/total) forest_holdrige3
-- 			FROM (SELECT gid_emprise, 
-- 				sum(pixelcount) FILTER (WHERE classe=1) forest_holdridge1,
-- 				sum(pixelcount) FILTER (WHERE classe=2) forest_holdridge2,
-- 				sum(pixelcount) FILTER (WHERE classe=3) forest_holdridge3,
-- 				sum(pixelcount) as total,
-- 				forest_area_ha
-- 				FROM atlas_pn.pn_emprises_holdridge a, emprises b
-- 				WHERE mnt_object = 'forest' AND a.gid_emprise=b.gid
-- 				GROUP BY gid_emprise, forest_area_ha
-- 			    ) a 
-- 			WHERE total >0
-- 			),
-- 			land_holdridge AS
-- 		(SELECT gid_emprise gid,
-- 			land_holdridge1*(land_area_ha/total) land_holdridge1,
-- 			land_holdridge2*(land_area_ha/total) land_holdridge2,
-- 			land_holdridge3*(land_area_ha/total) land_holdridge3
-- 		FROM (SELECT gid_emprise, 
-- 			sum(pixelcount) FILTER (WHERE classe=1) land_holdridge1,
-- 			sum(pixelcount) FILTER (WHERE classe=2) land_holdridge2,
-- 			sum(pixelcount) FILTER (WHERE classe=3) land_holdridge3,
-- 			sum(pixelcount) as total,
-- 			land_area_ha
-- 			FROM atlas_pn.pn_emprises_holdridge a, emprises b
-- 			WHERE mnt_object= 'land' AND a.gid_emprise=b.gid
-- 			GROUP BY gid_emprise, land_area_ha
-- 		    ) a 
-- 		WHERE total >0
-- 		)
-- 
-- 	UPDATE 
-- 		atlas_pn.pn_emprises a
-- 	SET 
-- 		forest_holdridge1_ha=f_holdridge1,
-- 		forest_holdridge2_ha=f_holdridge2,
-- 		forest_holdridge3_ha=f_holdridge3,
-- 		forest_inf300m_ha=forest_inf_300,
-- 		forest_300_600m_ha=forest_300_600,
-- 		forest_sup600m_ha=forest_sup_600,
-- 		land_holdridge1_ha=land_holdridge1,
-- 		land_holdridge2_ha=land_holdridge2,
-- 		land_holdridge3_ha=land_holdridge3
-- 	FROM
-- 		(SELECT b.gid, 
-- 		COALESCE(forest_holdrige1,0)::numeric(10,4) f_holdridge1,
-- 		COALESCE(forest_holdrige2,0)::numeric(10,4) f_holdridge2,
-- 		COALESCE(forest_holdrige3,0)::numeric(10,4) f_holdridge3,
-- 		COALESCE(forest_inf_300,0)::numeric(10,4) forest_inf_300,
-- 		COALESCE(forest_300_600,0)::numeric(10,4) forest_300_600,
-- 		COALESCE(forest_sup_600,0)::numeric(10,4) forest_sup_600,
-- 		COALESCE(land_holdridge1,0)::numeric(10,4) land_holdridge1,
-- 		COALESCE(land_holdridge2,0)::numeric(10,4) land_holdridge2,
-- 		COALESCE(land_holdridge3,0)::numeric(10,4) land_holdridge3
-- 
-- 		FROM emprises b 
-- 		LEFT JOIN forest_holdridge c ON b.gid=c.gid
-- 		LEFT JOIN forest_elevation d ON b.gid=d.gid
-- 		LEFT JOIN land_holdridge e ON b.gid=e.gid
-- 		) b
-- 	WHERE 
-- 		a.gid=b.gid
-- ;

---------------------------------------------------------------------------------------------
---UPDATE the fragment_meff_cbc value in pn_emprises
---Calculate the cross-boundary connections, to avoid  the "boundary problem" 
-----an ameliorated method to compute the effective mesh indice (see Moser et al. 2007)
--Query returned successfully: 29 rows affected, 19:49 minutes execution time.
------------------------------------------------------------------------------------------
WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises), -- where gid=15),
		shape_carto_pn_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
		shape_forest_emprises_utm AS 
			(SELECT a.gid, 
				st_area(a.geom)/1E6 land_area, --area of the emprise in km²
				st_area(b.geom)/1E6 as original_area, --original area of any forest patches in km²
				CASE 
					WHEN gid=1 then b.geom
					ELSE st_intersection(a.geom,b.geom) --intersection if gid<>1, otherwise the entire geom
				END as geom 
			FROM shape_emprises_utm a, shape_carto_pn_utm b WHERE ST_Intersects(a.geom,b.geom)
			),
		dump_forest_emprises_utm AS
			(SELECT gid, land_area,	original_area, 
				(st_dump(geom)).geom geom 
			 FROM 
				shape_forest_emprises_utm
			 )

	UPDATE 
		atlas_pn.pn_emprises z
	SET 
		fragment_meff_cbc=COALESCE(meff,0)::numeric
	FROM
		(SELECT gid, sum(area_cbc)/ land_area meff 
		FROM 
			(SELECT gid, original_area*(st_area(geom)/1E6) area_cbc, land_area
				FROM dump_forest_emprises_utm 
				WHERE geom IS NOT NULL
			) b
		GROUP BY 
			gid, land_area
		) a
	WHERE 
		z.gid=a.gid
; --select gid, type,name, fragment_meff_cbc, land_area_ha/100 from atlas_pn.pn_emprises where fragment_meff_cbc>( land_area_ha/100)
-----------------------------------------------------------------------		
--------------update nb_plots (from NC-PIPPN)
---Query returned successfully: 20 rows affected, 879 msec execution time.
-----------------------------------------------------------------------		
	WITH 
		shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		shape_plot_utm AS (SELECT id_locality, st_transform(st_setsrid(st_point(longitude, latitude), 4326),32758) AS geo_pt
					FROM occurences.occ_ncpippn 
				        GROUP BY id_locality,longitude, latitude
				  )
	---update the field 'nb_plots' of the table 'atlas_pn.pn_emprises'		
	UPDATE atlas_pn.pn_emprises a
	SET 
		nb_plots=COALESCE(b.nb_plot,0)::integer,
		pt_plot=st_transform(st_multi(b.pt_plot),4326)
		
		--, count(geo_pt) nb_plot
	FROM 
		(SELECT 
			gid, count(id_locality) as nb_plot,st_union(geo_pt) pt_plot
		FROM 
			shape_emprises_utm a, shape_plot_utm b
		WHERE 
			ST_Coveredby(b.geo_pt,a.geom)
		GROUP BY gid
		) b
	WHERE a.gid=b.gid
; 
-----------------------------------------------------------------------


-------------------------------------------------------------------------------------------
--------------update nb_occurences, nb_families, nb_species
---Query returned successfully: 28 rows affected, 05:07 minutes execution time.
-------------------------------------------------------------------------------------------
	WITH 
		shape_emprises_utm AS    (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
		--shape_carto_pn_utm AS (SELECT st_transform(f_geom,32758) geom FROM atlas_pn.pn_carto_forest),
		data_occurences_utm AS   (SELECT id_family,id_species,in_forest, st_transform(geo_pt,32758) geo_pt FROM atlas_pn.pn_data_occurences WHERE id_species IS NOT NULL),
		geo_pt_unique_utm AS (SELECT geo_pt,in_forest FROM data_occurences_utm GROUP BY geo_pt,in_forest),
		--unique GPS coordinates rather than all points (increase speed for inventories where many occurences get the same GPS coordinates
		geo_pt_unique_emprise_utm AS  (SELECT b.gid, a.geo_pt
					  FROM geo_pt_unique_utm a, shape_emprises_utm b
					  WHERE ST_CoveredBy(a.geo_pt,b.geom)
					 ),
		--intersection between uniques_geo_pt and data_occurences
		shape_data_occurences AS (SELECT b.gid, id_family,id_species, count(id_species) nb_occurences,a.geo_pt,in_forest
					  FROM data_occurences_utm a,geo_pt_unique_emprise_utm b 
					  WHERE a.geo_pt=b.geo_pt
					  GROUP BY b.gid ,id_family, id_species,in_forest,a.geo_pt
					 )
 	---update the fields 'nb_occurences', 'nb_families', 'nb_species' of the table 'atlas_pn.pn_emprises'		
	UPDATE 
		atlas_pn.pn_emprises c
	SET 
		pt_occ=st_transform(a.pts_occ,4326),
		nb_occurences=COALESCE(a.nb_occurences,0)::integer,
		nb_families= COALESCE(a.nb_families,0)::integer,
		nb_species=COALESCE(a.nb_species,0)::integer 
	FROM
		(SELECT
			gid,
			--only select geo_pt include in forest patches
			st_multi(st_union(geo_pt) FILTER (WHERE in_forest)) pts_occ,
			count(DISTINCT id_family) nb_families,
			count(DISTINCT id_species) as nb_species,
			--sum the number of occurences by gid
			sum(nb_occurences) as nb_occurences
		FROM shape_data_occurences
		GROUP BY gid
		) a
	WHERE c.gid=a.gid
; 
-----------------------------------------------------------------------


-------------------------------------------------------------------------------------------
--------------update forest_aob2015_ha
-------------------------------------------------------------------------------------------
WITH
	shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises),
	shape_data_aob2015_utm AS (SELECT st_transform(f_geomaob,32758) geom FROM atlas_pn.pn_carto_forest),
	--to restrict to the aob-grid that does not enclosed occurences (cf. atlas_pn.pn_data_occurences)
	--	shape_occurences_utm AS (SELECT st_transform(geo_pt,32758) geom FROM atlas_pn.pn_data_occurences GROUP BY geo_pt),
	-- 	shape_nodata_utm AS (SELECT a.id FROM shape_data_aob2015_utm a, shape_occurences_utm b WHERE ST_coveredby (b.geom,a.geom) GROUP BY a.id),
	-- 	shape2_data_aob2015_utm AS (SELECT id, st_transform(geom,32758) geom FROM public.amap_data_distribution_aob2015 a WHERE a.id NOT IN (SELECT id FROM shape_nodata_utm)),
	shape_aob_emprises_utm AS 
			(SELECT a.gid, 
				CASE 
					WHEN gid=1 then b.geom --for the province, the entire geom
					ELSE st_intersection(a.geom,b.geom) 
				END as geom 
			FROM shape_emprises_utm a, shape_data_aob2015_utm b WHERE ST_Intersects(a.geom,b.geom)
			)
 	---update the fields 'forest_aob2015_ha' of the table 'atlas_pn.pn_emprises'
	UPDATE 
		atlas_pn.pn_emprises a
	SET 
		forest_aob2015_ha=COALESCE(b.aob2015_area/10000,0)::numeric
	FROM
		(SELECT 
			a.gid,
			sum(st_area(geom)) as aob2015_area
		FROM 
		 --to compute grid-minute according to new occurences use shape2_data_aob2015_utm instead of shape_data_aob2015_utm
		-- to use strictly the grid-minute published in AoB
			shape_aob_emprises_utm a
		GROUP BY a.gid
		) b
	WHERE
		a.gid=b.gid 
; 
-----------------------------------------------------------------------

-------------------------------------------------------------------------------------------
--Zero instead of Null value (according to the default value, the field should not be able to be NULL), 0 is default value
-----------------------------------------------------------------------
-- UPDATE atlas_pn.pn_emprises SET land_area_ha=0 WHERE land_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  land_um_area_ha=0 WHERE  land_um_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  reserve_area_ha=0 WHERE  reserve_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  reserve_um_area_ha=0 WHERE  reserve_um_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  mining_area_ha=0 WHERE  mining_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  mining_um_area_ha=0 WHERE  mining_um_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  ppe_area_ha=0 WHERE  ppe_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_ppe_ha=0 WHERE  forest_ppe_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_area_ha=0 WHERE  forest_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_um_area_ha=0 WHERE  forest_um_area_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_reserve_ha=0 WHERE  forest_reserve_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_mining_ha=0 WHERE  forest_mining_ha IS NULL;
-- 
-- UPDATE atlas_pn.pn_emprises SET  forest_secondary_ha=0 WHERE forest_secondary_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_mature_ha=0 WHERE  forest_mature_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_core_ha=0 WHERE  forest_core_ha IS NULL;
-- 
-- UPDATE atlas_pn.pn_emprises SET  forest_aob2015_ha=0 WHERE  forest_aob2015_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_perimeter_km=0 WHERE  forest_perimeter_km IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  nb_patchs=0 WHERE  nb_patchs IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  nb_patchs_in=0 WHERE  nb_patchs_in IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  forest_in_ha=0 WHERE  forest_in_ha IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  r_in_median=0 WHERE  r_in_median IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  nb_plots=0 WHERE  nb_plots IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  nb_occurences=0 WHERE  nb_occurences IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  nb_families=0 WHERE  nb_families IS NULL;
-- UPDATE atlas_pn.pn_emprises SET  nb_species=0 WHERE  nb_species IS NULL;
-- UPDATE atlas_pn.pn_emprises SET n_unique_species=0 WHERE n_unique_species IS NULL;




--to test fields filling 
-- 
-- Select 
-- gid,
-- type,
-- name,
-- land_area_ha,
-- land_um_area_ha,
-- land_holdridge1_ha,
-- land_holdridge2_ha,
-- land_holdridge3_ha,
-- reserve_area_ha,
-- reserve_um_area_ha,
-- mining_area_ha,
-- mining_um_area_ha,
-- ppe_area_ha,
-- forest_area_ha,
-- forest_um_area_ha,
-- forest_reserve_ha,
-- forest_mining_ha,
-- forest_ppe_ha,
-- forest_100m_ha,
-- forest_ssdm80_ha,
-- forest_secondary_ha,
-- forest_mature_ha,
-- forest_core_ha,
-- forest_aob2015_ha,
-- forest_holdridge1_ha,
-- forest_holdridge2_ha,
-- forest_holdridge3_ha,
-- forest_perimeter_km,
-- nb_patchs,
-- fragment_meff_cbc,
-- nb_patchs_in,
-- forest_in_ha,
-- r_in_median,
-- nb_plots,
-- nb_occurences,
-- nb_families,
-- nb_species,
-- n_unique_species,
-- elevation_median,
-- elevation_max,
-- rainfall_min,
-- rainfall_max
-- 
--  
--  from
--  atlas_pn.pn_emprises
--  order by gid
