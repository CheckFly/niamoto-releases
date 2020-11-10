--dependecies
--georep_limites_provinciales_wgs84,georep_fusion_peridotites_wgs84,georep_limites_communales_wgs84,carto_reserves_wgs84
--

--Create and fill a table of shape in wgs84 (geom) with area (land, um, forest, forestum) and some general statistics of fragmentation (nb_fragment, avg_circle_ratio, min, max)
------------------------------------------------------
--Query returned successfully: 24 rows affected, 15.5 secs execution time.
--Query returned successfully: 21 rows affected, 01:07:10 hours execution time (full province nord & communes)
DROP TABLE IF EXISTS atlas_pn.pn_emprises CASCADE;
CREATE TABLE atlas_pn.pn_emprises
(gid SERIAL,
  type character varying(50)  NOT NULL,
  name character varying(50)  NOT NULL,

  land_area_ha numeric  DEFAULT 0,
  land_um_area_ha numeric  DEFAULT 0,
  
  land_holdridge1_ha numeric DEFAULT 0,
  land_holdridge2_ha numeric DEFAULT 0,
  land_holdridge3_ha numeric DEFAULT 0,
  
  reserve_area_ha numeric  DEFAULT 0,
  reserve_um_area_ha numeric  DEFAULT 0,
  
  mining_area_ha numeric  DEFAULT 0,
  mining_um_area_ha numeric  DEFAULT 0,

  ppe_area_ha numeric  DEFAULT 0,


  forest_area_ha numeric  DEFAULT 0,
  forest_um_area_ha numeric  DEFAULT 0,

  forest_reserve_ha numeric  DEFAULT 0,
  forest_mining_ha numeric  DEFAULT 0,
  forest_ppe_ha numeric  DEFAULT 0,
---to detele  
--  forest_100m_ha numeric  DEFAULT 0,
--  forest_ssdm80_ha numeric  DEFAULT 0,
---
--replace by
forest_secondary_ha numeric DEFAULT 0,
forest_mature_ha numeric DEFAULT 0,
forest_core_ha numeric DEFAULT 0,
----

  forest_aob2015_ha numeric  DEFAULT 0,

  forest_holdridge1_ha numeric DEFAULT 0,
  forest_holdridge2_ha numeric DEFAULT 0,
  forest_holdridge3_ha numeric DEFAULT 0,

  forest_inf300m_ha numeric DEFAULT 0,
  forest_300_600m_ha numeric DEFAULT 0,
  forest_sup600m_ha numeric DEFAULT 0,

  forest_perimeter_km numeric  DEFAULT 0,
  nb_patchs integer  DEFAULT 0,

  fragment_meff_cbc numeric  DEFAULT 0,
  nb_patchs_in integer  DEFAULT 0,
  forest_in_ha numeric  DEFAULT 0,
  --r_in_median numeric  DEFAULT 0,

  nb_plots integer  DEFAULT 0,
  nb_occurences integer  DEFAULT 0,
  nb_families integer  DEFAULT 0,
  nb_species integer  DEFAULT 0,
  --n_unique_species integer  DEFAULT 0,

elevation_median integer,
elevation_max integer,
rainfall_min integer,
rainfall_max integer,

--add geometry (land, um_land, pt_occurences, pt_plots)
  geom geometry(MultiPolygon,4326),
  --um_geom geometry (MultiPolygon,4326),
  forest_geom geometry (MultiPolygon,4326),
  pt_plot geometry(MultiPoint,4326),
  pt_occ geometry(MultiPoint,4326),
  CONSTRAINT table_pn_emprises_pkey PRIMARY KEY (gid)
);
--Vacuum FULL atlas_pn.pn_emprises;


------------------------------------------------------
--create shape to be used, transform all in UTM metric SRID (UTM-wgs84=32758)
------------------------------------------------------------------------------------------------------------
----Insert the geometry of any shapes (emprises) to be proceed in a MultiPolygon 4326 system
---BEWARE TO KEEP ORDER OF gid=1 (province), gid=2 (ultramafic) and gid=3 (ppe=perimeter of wate protection)

---gid=1 --> North province
WITH pn_union AS (SELECT geom FROM georep_limites_provinciales_wgs84 WHERE gid=1)
	INSERT INTO atlas_pn.pn_emprises (type,name,geom)
	SELECT 'Province', 'province Nord', geom ::geometry(MultiPolygon,4326) from pn_union;

--gid=2 --> Peridotite
WITH pn_union AS (SELECT geom FROM atlas_pn.pn_emprises WHERE gid=1),
     peridotite AS (SELECT 'ultramafique' entite, st_union(st_intersection(a.geom,b.geom)) geom from georep_fusion_peridotites_wgs84 a, pn_union b WHERE ST_Intersects(a.geom,b.geom))
	INSERT INTO atlas_pn.pn_emprises (type,name,geom)
	SELECT 'Substrat', entite,geom ::geometry(MultiPolygon,4326) from peridotite a;
--special treatments for gid=1 and gid=2
-- the um_geom of the gid1 = geom of the gid2
	--UPDATE atlas_pn.pn_emprises a SET um_geom=b.geom FROM (SELECT geom FROM atlas_pn.pn_emprises  WHERE gid=2) b WHERE a.gid=1;
-- for gid2, than um_geom = geom
	--UPDATE atlas_pn.pn_emprises SET um_geom=geom WHERE gid=2;

--gid=3
WITH pn_union AS (SELECT geom FROM atlas_pn.pn_emprises WHERE gid=1),
     shape_ppe AS (SELECT 'périmètre protection des eaux'::text entite, st_intersection(a.geom,b.geom) geom from davar_fusion_perimeter_eaux_wgs84 a, pn_union b WHERE ST_Intersects(a.geom,b.geom) and a.geom is not null)
	INSERT INTO atlas_pn.pn_emprises (type,name,geom)
	SELECT 'Captage'::text  nom, entite ,st_union(geom)::geometry(MultiPolygon,4326) geom from shape_ppe a WHERE st_GeometryType(geom)='ST_Polygon' GROUP BY nom, entite;



------------------------------------------------------

--gid=3 to 19
--Query returned successfully: 17 rows affected, 358 msec execution time.
WITH pn_union AS (SELECT commune, st_union(geom) geom from georep_limites_communales_wgs84  WHERE province='PN' GROUP BY commune ORDER BY commune) 
INSERT INTO atlas_pn.pn_emprises (type,name,geom)
SELECT 'Commune', commune,geom ::geometry(MultiPolygon,4326) from pn_union order by commune;

--gid=20 to 24
--Query returned successfully: 5 rows affected, 32 msec execution time.
WITH pn_union AS (SELECT nom, st_union(geom) geom from georep_limites_reserves_wgs84 where province='PN' GROUP BY nom ORDER BY nom) 
INSERT INTO atlas_pn.pn_emprises (type,name,geom)
SELECT 'Réserve', nom,geom ::geometry(MultiPolygon,4326) from pn_union order by nom;

---+ 5 gid linked to the 5 life zones of holdridge
--Query returned successfully: 5 rows affected, 376 msec execution time.
WITH pn_union AS (SELECT st_transform(geom,32758) geom FROM atlas_pn.pn_emprises WHERE gid=1),
	pn_lifezones AS
	(SELECT 
		'Milieu'::text as type_emprise,
		CASE 
			WHEN val = 1 THEN 'Sec'
			WHEN val = 2 THEN 'Humide'
			WHEN val = 3 THEN 'Très humide'
		END AS nom,
		-- apply a +20m buffer to ensure the union then soustract a symetric -20m buffer to restore initial area
		st_buffer(st_union(st_buffer(st_transform(geom,32758), 20)),-20) geom
	FROM
		(SELECT (ST_DumpAsPolygons (rast)).* From raster_holdrige_wgs84) a
	GROUP BY val
	ORDER BY val)

	INSERT INTO atlas_pn.pn_emprises (type,name,geom)
	SELECT type_emprise, nom, st_transform(st_intersection(a.geom, b.geom),4326) geom from 
	pn_lifezones a, pn_union b
	 WHERE ST_Intersects(a.geom,b.geom)
	;

------------------------------------------------------
--update the table by inserting um_geometry (um_geom) for gid>2 (see previous special treatment)
--make a special check to ensure the 4326 geometrye is valid (excluded wrong geometries resulting from transforming in 4326)
--Total query runtime: 16:12 minutes
------------------------------------------------------
-- WITH 
-- --intercepts in UTM mode
-- 	shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM atlas_pn.pn_emprises WHERE gid > 2),
-- 	shape_um_utm AS (SELECT st_transform(geom,32758) geom FROM atlas_pn.pn_emprises WHERE gid = 2),
-- 	shape_um_emprises_utm AS (SELECT gid, st_intersection(a.geom,b.geom) geom 
-- 					FROM shape_emprises_utm a, shape_um_utm b 
-- 					WHERE ST_Intersects(a.geom,b.geom)
-- 				  ),
-- --verify validity in WGS84 output mode
-- 	shape_wgs84 AS (SELECT gid, st_makevalid(st_transform(geom, 4326)) geom FROM shape_um_emprises_utm),
-- 	shape_dump_wgs84 AS (SELECT gid, (st_dump(geom)).geom geom FROM shape_wgs84),
-- --retain only polygon and multipolygon
-- 	shape_valid_wgs84 AS (SELECT gid, geom from shape_dump_wgs84  WHERE st_geometrytype(geom) IN ('ST_Polygon', 'ST_MultiPolygon') ),
-- 	shape_union_wgs84 AS (SELECT gid, st_multi(st_union(geom)) ::geometry(MultiPolygon,4326) geom FROM shape_valid_wgs84 GROUP BY gid)
-- 	
-- 	------------------------------------------------------
-- 	--update the table 'atlas_pn.pn_emprises' with a clean multi-polygon union UM geometry for each gid
--  	UPDATE 
-- 		atlas_pn.pn_emprises a
-- 	SET 
-- 		um_geom=b.geom
-- 	FROM
-- 		shape_union_wgs84 b
-- 	WHERE 
--  		a.gid=b.gid;



