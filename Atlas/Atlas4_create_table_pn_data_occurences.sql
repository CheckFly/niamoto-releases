---CREATE the table pn_data_occurences containing all occurrences with metrics (taxon, dbh, height, elevation, mnt, holdridge,...)
---------------------------------------------------------------------------------------------------------------------------------
--Query returned successfully: 131293 rows affected, 32:35 minutes execution time.
--Query returned successfully: 131260 rows affected, 33:08 minutes execution time.
--Query returned successfully: 131463 rows affected, 27:40 minutes execution time.
--Query returned successfully: 130493 rows affected, 33:09 minutes execution time.
---Query returned successfully: 130489 rows affected, 31:34 minutes execution time.
--Query returned successfully: 131606 rows affected, 32:05 minutes execution time.
--dependencies
--occurences.occ_amap, occurences.occ_gps, occurences.occ_jpbutin, occurences.occ_ncpippn, occurences.occ_virot, occurences.occ_niamoto, occurences.letouze_taxon_referentiel
--meteo_points_aurelhy_wgs84, raster_holdrige_wgs84, raster_srtm90_classified_wgs84
--atlas_pn.pn_carto_forest, atlas.pn_emprise
DROP TABLE IF EXISTS atlas_pn.pn_data_occurences CASCADE;

CREATE TABLE atlas_pn.pn_data_occurences
(
  id_source integer,
  source text,
  id_taxon_ref integer,
  id_family integer,
  id_genus integer,
  id_species integer,
  id_infra integer,
  --longitude double precision,
 -- latitude double precision,
  dbh numeric,
  height numeric,
  phenology text,
  month_obs integer,
  wood_density numeric,
  leaf_sla numeric,
  bark_thickness numeric,
  leaf_area numeric,
  leaf_thickness numeric,
  leaf_ldmc  numeric,
  strate  numeric,

  --year_obs integer,
  elevation numeric,
  rainfall numeric,
  holdridge integer,
 -- in_pn boolean  DEFAULT false,
  province character varying(3), 
  in_forest boolean  DEFAULT false,
  in_um boolean  DEFAULT false,

  geo_pt geometry(Point,4326),
  CONSTRAINT table_pn_data_occurences_pkey PRIMARY KEY (id_source,source)
);


------INSERT raw data from the union of several occurences tables (schema occurences)
--Query returned successfully: 131327 rows affected, 9.8 secs execution time.
INSERT INTO atlas_pn.pn_data_occurences (id_source,source, id_taxon_ref,id_family, id_genus,id_species,id_infra,dbh,height,
					phenology,month_obs,
					wood_density,
					leaf_sla,
					bark_thickness,
					leaf_area,
					leaf_thickness,
					leaf_ldmc,
					strate,
					geo_pt)

WITH all_species_occurences AS (SELECT id_source,source, pn_taxon_getvalid(id_taxon_ref) id_taxon_ref, longitude, latitude, 
				dbh,height,
				phenology,
				month_obs,
				wood_density ::numeric,
				leaf_sla ::numeric,
				bark_thickness ::numeric,
				leaf_area ::numeric,
				leaf_thickness ::numeric,
				leaf_ldmc  ::numeric,
				strate  ::numeric
		FROM (SELECT * 
		FROM 
			(SELECT id as id_source, 'occ_amap' as source, id_taxon_ref, longitude, latitude, dbh ::numeric, NULL ::numeric height,
				NULL ::text phenology, NULL::integer month_obs,
				NULL ::numeric wood_density,
				NULL ::numeric leaf_sla,
				NULL ::numeric bark_thickness,
				NULL ::numeric leaf_area,
				NULL ::numeric leaf_thickness,
				NULL ::numeric leaf_ldmc,
				NULL ::numeric strate 
				FROM occurences.occ_amap) as occ_amap
		UNION
			(SELECT id_source, 'occ_gps' as source, id_taxon_ref, longitude, latitude, NULL::numeric dbh, NULL::numeric height,
				phenology::text,month_obs::integer,
				NULL ::numeric wood_density,
				NULL ::numeric leaf_sla,
				NULL ::numeric bark_thickness,
				NULL ::numeric leaf_area,
				NULL ::numeric leaf_thickness,
				NULL ::numeric leaf_ldmc,
				NULL ::numeric strate 
				FROM occurences.occ_gps)

		UNION
			(SELECT id_source, 'occ_jpbutin' as source, id_taxon_ref, x_rgnc9193 longitude, y_rgnc9193 latitude, dbh::numeric, height::numeric, 
				phenology::text, month_obs::integer,
				NULL ::numeric wood_density,
				NULL ::numeric leaf_sla,
				NULL ::numeric bark_thickness,
				NULL ::numeric leaf_area,
				NULL ::numeric leaf_thickness,
				NULL ::numeric leaf_ldmc,
				NULL ::numeric strate
				FROM occurences.occ_jpbutin)

		UNION
			(SELECT id_source, 'occ_ncpippn' as source, id_taxon_ref, longitude, latitude, dbh::numeric, height::numeric, 
				phenology::text, month_obs::integer,
				wood_density ::numeric,
				leaf_sla ::numeric,
				bark_thickness ::numeric,
				leaf_area ::numeric,
				leaf_thickness ::numeric,
				leaf_ldmc  ::numeric,
				CASE WHEN lower(strate)='sous-bois' then 1
				     WHEN lower(strate)='sous-canopée' then 2
				     WHEN lower(strate)='canopée' then 3
				     WHEN lower(strate)='emergent' then 4
		                END::integer strate 
				FROM occurences.occ_ncpippn)
											
		UNION
			(SELECT id_source, 'occ_virot' as source, id_taxon_ref, longitude, latitude, dbh::numeric, height::numeric, 
				phenology::text, month_obs::integer,
				NULL ::numeric wood_density,
				NULL ::numeric leaf_sla,
				NULL ::numeric bark_thickness,
				NULL ::numeric leaf_area,
				NULL ::numeric leaf_thickness,
				NULL ::numeric leaf_ldmc,
				NULL ::numeric strate 
				FROM occurences.occ_virot)

		UNION
			(SELECT id_source, 'occ_niamoto' as source, id_taxon_ref, longitude, latitude, NULL::numeric dbh, NULL ::numeric height, 
				NULL ::text phenology, NULL::integer month_obs,
				NULL ::numeric wood_density,
				NULL ::numeric leaf_sla,
				NULL ::numeric bark_thickness,
				NULL ::numeric leaf_area,
				NULL ::numeric leaf_thickness,
				NULL ::numeric leaf_ldmc,
				NULL ::numeric strate 
				FROM occurences.occ_niamoto)
) c
),
--return the list of all trees taxa (id_taxon_ref == id_species + id_infra)
trees_taxa AS 
	(SELECT id_taxon_ref 
	FROM
		--create union between id_taxon_ref and id_species for trees
		-- all taxa, species (at least one intraspecific as tree for species with intraspecifi taxa) or infraspecific taxa that is a tree
		--all trees infraspecific
		(SELECT id_taxon_ref FROM occurences.letouze_taxon_referentiel WHERE is_tree and id_rang>21
		UNION
		-- ++ all trees species
		SELECT pn_taxon_getparent(id_taxon_ref, 21) id_taxon_ref FROM occurences.letouze_taxon_referentiel  WHERE is_tree
		) b
	GROUP BY id_taxon_ref
)

SELECT 
    id_source ::integer,
    source ::text,
    id_taxon_ref  ::integer,
    pn_taxon_getparent(id_taxon_ref,10):: integer id_family,
    pn_taxon_getparent(id_taxon_ref,14):: integer id_genus,
    pn_taxon_getparent(id_taxon_ref,21):: integer id_species,
    CASE 
	WHEN id_taxon_ref<>pn_taxon_getparent(id_taxon_ref,21) THEN id_taxon_ref
	ELSE NULL
    END id_infra,
    dbh ::numeric,
    height :: numeric,
    phenology ::text,
    month_obs ::integer,
    wood_density ::numeric,
    leaf_sla ::numeric,
    bark_thickness ::numeric,
    leaf_area ::numeric,
    leaf_thickness ::numeric,
    leaf_ldmc  ::numeric,
    strate  ::numeric,
    CASE WHEN (longitude BETWEEN 163 AND 168.5) AND (latitude BETWEEN -23 AND -19) THEN
	st_setsrid(st_point(longitude, latitude), 4326) ::geometry(POINT,4326) 
	ELSE NULL
    END  AS geo_pt
FROM 
	all_species_occurences
WHERE 
	--retain only tree taxa (according to infra or species statut)
	id_taxon_ref IN (SELECT id_taxon_ref from trees_taxa)
;

--make some check to clean potential aberrant values
UPDATE atlas_pn.pn_data_occurences SET dbh=NULL WHERE dbh<=0;
UPDATE atlas_pn.pn_data_occurences SET height=NULL WHERE dbh<=0;
UPDATE atlas_pn.pn_data_occurences SET month_obs=NULL WHERE month_obs NOT BETWEEN 1 AND 12;
UPDATE atlas_pn.pn_data_occurences SET phenology=NULL WHERE month_obs IS NULL;
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
------UPDATE the field province according to the intersection with the Caledonian shape (PN, PIL and PS)
-------------------------------------------------------------------------------------------
WITH 
	shape_caledonia AS (SELECT 
				CASE WHEN gid=1 THEN 'PN'
				     WHEN gid=2 THEN 'PIL'
				     WHEN gid=3 THEN 'PS'
				END province,
				st_transform(geom, 32758) geom_utm 
			   FROM georep_limites_provinciales_wgs84
			   ),
	uniques_geo_pt AS (SELECT geo_pt, st_transform(geo_pt, 32758) geo_pt_utm FROM atlas_pn.pn_data_occurences WHERE geo_pt IS NOT NULL GROUP BY geo_pt),
	caledonia_uniques_geo_pt AS (SELECT province, geo_pt FROM uniques_geo_pt a, shape_caledonia b WHERE  st_coveredby(a.geo_pt_utm, b.geom_utm))
	UPDATE 
		atlas_pn.pn_data_occurences a
	SET 
		province=b.province
	FROM 
		caledonia_uniques_geo_pt b
	WHERE 
		a.geo_pt=b.geo_pt
;
--- delete geo_pt outside the shape_caledonia
UPDATE atlas_pn.pn_data_occurences SET geo_pt=NULL WHERE province IS NULL
;
		
-------------------------------------------------------------------------------------------
------UPDATE the field IN_FOREST according to the intersection with the forest shape (only province Nord)
---Query returned successfully: 51923 rows affected, 04:20 minutes execution time.
-------------------------------------------------------------------------------------------
WITH 
	shape_carto_pn AS (SELECT st_transform(f_geom, 32758) geom_utm FROM atlas_pn.pn_carto_forest),
	data_occurences AS (SELECT geo_pt, st_transform(geo_pt, 32758) geo_pt_utm FROM atlas_pn.pn_data_occurences WHERE geo_pt IS NOT NULL GROUP BY geo_pt),
	--unique geop_pt included within the shape_carto_pn
	shape_uniques_geo_pt AS
	(SELECT a.geo_pt
		FROM
			data_occurences a,
			shape_carto_pn b
		WHERE ST_CoveredBy(a.geo_pt_utm,b.geom_utm)
	)
--intersection between uniques_geo_pt and data_occurences
	UPDATE 
		atlas_pn.pn_data_occurences a
	SET 
		in_forest=True
	WHERE 
		a.geo_pt IN (SELECT geo_pt FROM shape_uniques_geo_pt)
;
-------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------
------UPDATE the field IN_UM according to the intersection with the um shape
-------------------------------------------------------------------------------------------
--Query returned successfully: 73320 rows affected, 01:32 minutes execution time.
--Query returned successfully: 74001 rows affected, 01:34 minutes execution time.
WITH 
	--use the full shape peridotite to insersect occurences out of provicne Nord limits
	shape_emprises_um AS (SELECT st_transform(geom, 32758) geom_utm FROM georep_fusion_peridotites_wgs84),
	data_occurences AS (SELECT geo_pt, st_transform(geo_pt, 32758) geo_pt_utm FROM atlas_pn.pn_data_occurences WHERE geo_pt IS NOT NULL GROUP BY geo_pt),
	--unique geop_pt included within the shape_emprises_um
	shape_uniques_geo_pt AS
		(SELECT a.geo_pt
		FROM
			data_occurences a,
			shape_emprises_um b
		WHERE ST_CoveredBy(a.geo_pt_utm,b.geom_utm)
		)
--intersection between uniques_geo_pt and data_occurences
	UPDATE 
		atlas_pn.pn_data_occurences a
	SET 
		in_um=True
	WHERE 
		a.geo_pt IN (SELECT geo_pt FROM shape_uniques_geo_pt)
;
-------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------
------UPDATE the field RAINFALL according to the intersection with the 'meteo_points_aurelhy_wgs84' shape
-------------------------------------------------------------------------------------------
---Query returned successfully: 129460 rows affected, 08:45 minutes execution time.
---Query returned successfully: 131252 rows affected, 35:30 minutes execution time.
--Query returned successfully: 130352 rows affected, 05:08 minutes execution time.
WITH 
	shape_rainfall_utm AS (SELECT grid_code::numeric rainfall, st_transform(geom,32758) geom_utm FROM meteo_points_aurelhy_wgs84),
	data_occurences_utm AS (SELECT geo_pt, st_transform(geo_pt, 32758) geo_pt_utm FROM atlas_pn.pn_data_occurences WHERE geo_pt IS NOT NULL GROUP BY geo_pt),
	shape_uniques_geo_pt AS
		(SELECT geo_pt, round(avg(rainfall),0) rainfall --rainfall is average of aurelhy points, in a 1000 m distance
		FROM
			data_occurences_utm a,
			shape_rainfall_utm b
		WHERE
			ST_DWithin(a.geo_pt_utm,b.geom_utm,1000)
		GROUP BY a.geo_pt
		)
--intersection between uniques_geo_pt and data_occurences
	UPDATE 
		atlas_pn.pn_data_occurences a
	SET 
		rainfall=b.rainfall
	FROM
		shape_uniques_geo_pt b
	WHERE 
		a.geo_pt=b.geo_pt
;

-------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------
------UPDATE the field HOLDRIDGE according to the intersection with the raster_holdrige_wgs84
-------------------------------------------------------------------------------------------
--Query returned successfully: 131292 rows affected, 04:03 minutes execution time.
--Query returned successfully: 131271 rows affected, 03:38 minutes execution time.

WITH 
	shape_raster AS (SELECT * FROM raster_holdrige_wgs84 WHERE NOT ST_BandIsNoData(rast)),
	data_occurences AS (SELECT geo_pt FROM atlas_pn.pn_data_occurences WHERE geo_pt IS NOT NULL GROUP BY geo_pt),
	shape_uniques_geo_pt AS
		(SELECT a.geo_pt, ST_NearestValue(b.rast,1,a.geo_pt) holdridge
			FROM
				data_occurences a,
				shape_raster b
			WHERE  ST_Intersects(a.geo_pt,b.rast)
		) 
--intersection between uniques_geo_pt and data_occurences
	UPDATE 
		atlas_pn.pn_data_occurences a
	SET 
		holdridge=b.holdridge
	FROM
		shape_uniques_geo_pt b
	WHERE 
		a.geo_pt=b.geo_pt
;
-------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------
------UPDATE the field ELEVATION according to the intersection with the srtm90_classified_utm raster (1 to 17 elevation classes for 100-1700 m)
-------------------------------------------------------------------------------------------
--Query returned successfully: 131293 rows affected, 12:10 minutes execution time.
--Query returned successfully: 131256 rows affected, 08:51 minutes execution time (=NOT ST_BandIsNoData(rast)).
---Query returned successfully: 131260 rows affected, 04:52 minutes execution time (not st_transform).
WITH 
	shape_raster AS (SELECT * FROM raster_srtm90_classified_wgs84 WHERE NOT ST_BandIsNoData(rast)),
	data_occurences AS (SELECT geo_pt FROM atlas_pn.pn_data_occurences WHERE geo_pt IS NOT NULL GROUP BY geo_pt),
	--elevation for unique geop_pt with 
	shape_uniques_geo_pt AS
		(SELECT a.geo_pt, ST_NearestValue(b.rast,1,a.geo_pt) elevation
			FROM
				data_occurences a,
				shape_raster b
			WHERE ST_Intersects(a.geo_pt,b.rast)
		) 
--intersection between uniques_geo_pt and data_occurences
	UPDATE 
		atlas_pn.pn_data_occurences a
	SET 
		elevation=100*b.elevation
	FROM
		shape_uniques_geo_pt b
	WHERE 
		a.geo_pt=b.geo_pt
;
-------------------------------------------------------------------------------------------



	

---VaCUUM FULL atlas_pn.pn_data_occurences;