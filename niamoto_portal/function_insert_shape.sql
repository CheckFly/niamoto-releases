-- FUNCTION: niamoto_portal.insert_shape()
-- DROP FUNCTION niamoto_portal.insert_shape();
CREATE
OR REPLACE FUNCTION niamoto_portal.insert_shape() RETURNS integer LANGUAGE 'plpgsql' COST 100 VOLATILE 
AS $BODY$ 
BEGIN 
TRUNCATE niamoto_portal.data_shape_shape CASCADE;

INSERT INTO
  niamoto_portal.data_shape_shape(
    id,
    label,
    type_shape,
    location,
    land_area,
    land_um_area,
    forest_area,
    forest_um_area,
    forest_in,
    forest_reserve,
    forest_mining,
    forest_perimeter,
    nb_patchs,
    nb_plots,
    nb_occurence,
    nb_families,
    nb_species,
    elevation_median,
    elevation_max,
    rainfall_min,
    rainfall_max,
    fragment_meff_cbc,
    geom_forest
  )
SELECT
  gid,
  name,
  type,
  geom,
  land_area_ha,
  land_um_area_ha,
  forest_area_ha,
  forest_um_area_ha,
  forest_in_ha,
  forest_reserve_ha,
  forest_mining_ha,
  forest_perimeter_km,
  nb_patchs,
  nb_plots,
  nb_occurences,
  nb_families,
  nb_species,
  elevation_median,
  elevation_max,
  rainfall_min,
  rainfall_max,
  fragment_meff_cbc,
  forest_geom
FROM
  data_preprocess.emprises
WHERE province = 'PN'
ORDER BY
gid;

RETURN 1;

END;

$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape() OWNER TO amapiac;