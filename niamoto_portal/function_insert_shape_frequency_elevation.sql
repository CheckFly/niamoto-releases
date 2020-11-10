-- FUNCTION: niamoto_portal.insert_shape_frequency_elevation()

-- DROP FUNCTION niamoto_portal.insert_shape_frequency_elevation();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_shape_frequency_elevation(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN

INSERT INTO
	niamoto_portal.data_shape_frequency (shape_id, class_object, class_name, class_value)
SELECT
	gid,
	'land_elevation',
	class_elevation,
	land_ha
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL

SELECT
	gid,
	'forest_elevation',
	class_elevation,
	forest_ha
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL

SELECT
	gid,
	'land_um_elevation',
	class_elevation,
	land_um_ha
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL


SELECT
	gid,
	'forest_um_elevation',
	class_elevation,
	forest_um_ha
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL

SELECT
	gid,
	'ratio_forest_num_elevation',
	class_elevation,
	@ratio_forest_num
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL

SELECT
	gid,
	'ratio_forest_um_elevation',
	class_elevation,
	@ratio_forest_um
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL

SELECT
	gid,
	'ratio_forest_core_elevation',
	class_elevation,
	CASE
		WHEN forest_ha > 0 THEN round(forest_core_ha / forest_ha :: numeric, 2)
		ELSE 0
	END as class_value
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL

SELECT
	gid,
	'ratio_forest_mature_elevation',
	class_elevation,
	CASE
		WHEN forest_ha > 0 THEN round(forest_mature_ha / forest_ha :: numeric, 2)
		ELSE 0
	END as class_value
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	
UNION ALL

SELECT
	gid,
	'ratio_forest_second_elevation',
	class_elevation,
	CASE
		WHEN forest_ha > 0 THEN round(forest_secondary_ha / forest_ha :: numeric, 2)
		ELSE 0
	END as class_value
FROM
	data_preprocess.emprises_elevation 	WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id);

RETURN 1;

END;

$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape_frequency_elevation() OWNER TO amapiac;