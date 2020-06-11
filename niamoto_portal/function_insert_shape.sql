-- FUNCTION: niamoto_portal.insert_shape()

-- DROP FUNCTION niamoto_portal.insert_shape();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_shape(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
		
		
TRUNCATE niamoto_portal.data_shape_shape CASCADE;

with 
	emprises AS (SELECT * from niamoto_preprocess.emprises),
	--total_pn AS (SELECT gid, forest_area_ha  from niamoto_preprocess.emprises),
	shape_emprises_utm AS (SELECT gid, st_transform(geom,32758) geom FROM niamoto_preprocess.emprises),
	shape_rainfall_utm AS (SELECT st_transform(geom,32758) geom, grid_code rainfall FROM meteo_points_aurelhy_wgs84),
	rainfall AS (SELECT
		gid, min(rainfall) min_rainfall, max(rainfall) max_rainfall
		FROM
			shape_emprises_utm a,  shape_rainfall_utm b
		WHERE 
			st_coveredby (b.geom, a.geom)
		GROUP BY gid
		),
	forest_elevation AS 
		(SELECT gid_emprise gid,
			forest_inf_300*(forest_area_ha/total) forest_inf_300,
			forest_300_600*(forest_area_ha/total) forest_300_600,
			forest_sup_600*(forest_area_ha/total) forest_sup_600
		FROM (SELECT gid_emprise, 
			sum(pixelcount) FILTER (WHERE class_elevation<=300) forest_inf_300,
			sum(pixelcount) FILTER (WHERE class_elevation>300 AND class_elevation<=600) forest_300_600,
			sum(pixelcount) FILTER (WHERE class_elevation>600) forest_sup_600,
			sum(pixelcount) as total,
			forest_area_ha
			FROM niamoto_preprocess.emprises_raster a, emprises b
			WHERE mnt_object='forest' AND a.gid_emprise=b.gid
			GROUP BY gid_emprise, forest_area_ha
		      ) a 
	        WHERE total >0
		),
	land_holdridge AS
		(SELECT gid_emprise gid,
			land_holdridge1*(land_area_ha/total) land_holdridge1,
			land_holdridge2*(land_area_ha/total) land_holdridge2,
			land_holdridge3*(land_area_ha/total) land_holdridge3
		FROM (SELECT gid_emprise, 
			sum(pixelcount) FILTER (WHERE classe=1) land_holdridge1,
			sum(pixelcount) FILTER (WHERE classe=2) land_holdridge2,
			sum(pixelcount) FILTER (WHERE classe=3) land_holdridge3,
			sum(pixelcount) as total,
			land_area_ha
			FROM niamoto_preprocess.emprises_holdridge a, emprises b
			WHERE mnt_object= 'land' AND a.gid_emprise=b.gid
			GROUP BY gid_emprise, land_area_ha
		    ) a 
		WHERE total >0
		),
	forest_holdridge AS
		(SELECT gid_emprise gid,
			forest_holdridge1*(forest_area_ha/total) forest_holdrige1,
			forest_holdridge2*(forest_area_ha/total) forest_holdrige2,
			forest_holdridge3*(forest_area_ha/total) forest_holdrige3
		FROM (SELECT gid_emprise, 
			sum(pixelcount) FILTER (WHERE classe<=2) forest_holdridge1,
			sum(pixelcount) FILTER (WHERE classe=3) forest_holdridge2,
			sum(pixelcount) FILTER (WHERE classe>=4) forest_holdridge3,
			sum(pixelcount) as total,
			forest_area_ha
			FROM niamoto_preprocess.emprises_holdridge a, emprises b
			WHERE mnt_object = 'forest' AND a.gid_emprise=b.gid
			GROUP BY gid_emprise, forest_area_ha
		    ) a 
		WHERE total >0
		)

INSERT INTO niamoto_portal.data_shape_shape(
    id,
    label,
    type_shape,
    location,
    land_area,
    land_um_area,
    land_holdridge1,
    land_holdridge2,
    land_holdridge3,
    forest_area,
    forest_um_area,
    forest_in,
    forest_reserve,
    forest_mining,
    forest_perimeter,
    forest_secondary,
    forest_primary,
    forest_heart,
    forest_inf_300,
    forest_300_600,
    forest_sup_600,
    forest_holdridge1,
    forest_holdridge2,
    forest_holdridge3,
    forest_ppe,
    reserve_area,
    reserve_um_area,
    mining_area,
    mining_um_area,
    min_rainfall,
    max_rainfall,
    ppe_area,
    forest_cover,
    forest_cover_um,
    forest_cover_num,
    nb_patchs,
    nb_patchs_in,
    r_in_median,
    nb_plots,
    nb_occurence,
    nb_families,
    nb_species,
    n_unique_species,
    fragment_meff_cbc,
    um_geom,
    forest_geom
  )
SELECT
  b.gid,
  name,
  type,
  geom,
  round(land_area_ha::numeric, 0),
  round(land_um_area_ha::numeric, 0),
  round(COALESCE(land_holdridge1,0)::numeric, 0) land_holdridge1,
  round(COALESCE(land_holdridge2,0)::numeric, 0) land_holdridge2,
  round(COALESCE(land_holdridge3,0)::numeric, 0) land_holdridge3,
  round(forest_area_ha :: numeric, 0),
  round(forest_um_area_ha::numeric, 0), 
  round(forest_in_ha :: numeric, 0),
  round(forest_reserve_ha::numeric, 0), 
  round(forest_mining_ha::numeric, 0),
  round(forest_perimeter_km :: numeric, 0),
  round((forest_area_ha-forest_100m_ha)::numeric, 0), 
  round((forest_100m_ha-forest_ssdm80_ha)::numeric, 0), 
  round(forest_ssdm80_ha::numeric, 0),
  round(COALESCE(forest_inf_300,0)::numeric, 0),
  round(COALESCE(forest_300_600,0)::numeric, 0),
  round(COALESCE(forest_sup_600,0)::numeric, 0),
  round(COALESCE(forest_holdrige1,0)::numeric, 0),
  round(COALESCE(forest_holdrige2,0)::numeric, 0),
  round(COALESCE(forest_holdrige3,0)::numeric, 0),
  round(forest_ppe_ha::numeric, 0),
  round(reserve_area_ha::numeric, 0), 
  round(reserve_um_area_ha::numeric, 0),
  round(mining_area_ha::numeric, 0),
  round(mining_um_area_ha::numeric, 0),
  min_rainfall, 
  max_rainfall,
  round(ppe_area_ha::numeric, 0),
  round(COALESCE(forest_area_ha/land_area_ha,0) ::numeric, 0),
  round(COALESCE(CASE WHEN (land_area_ha-land_um_area_ha)>0 THEN (forest_area_ha-forest_um_area_ha)/(land_area_ha-land_um_area_ha) ELSE 0 END,0) ::numeric, 0) ,
  round(COALESCE(CASE WHEN land_um_area_ha>0 THEN forest_um_area_ha/land_um_area_ha ELSE 0 END,0) ::numeric, 0),
  nb_patchs,
  nb_patchs_in,
  r_in_median,
  nb_plots,
  nb_occurences,
  nb_families,
  nb_species,
  n_unique_species,
  fragment_meff_cbc,
  um_geom,
  forest_geom
FROM emprises b 
LEFT JOIN forest_elevation a ON b.gid=a.gid
LEFT JOIN forest_holdridge c ON b.gid=c.gid
LEFT JOIN rainfall d ON b.gid=d.gid
LEFT JOIN land_holdridge e ON b.gid=e.gid
ORDER BY b.gid;
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape()
    OWNER TO amapiac;
