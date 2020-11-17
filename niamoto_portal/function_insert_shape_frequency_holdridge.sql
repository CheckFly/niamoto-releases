-- FUNCTION: niamoto_portal.insert_shape_frequency_holdridge()

-- DROP FUNCTION niamoto_portal.insert_shape_frequency_holdridge();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_shape_frequency_holdridge(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
		
				
INSERT INTO niamoto_portal.data_shape_frequency(class_object, class_name, class_value, shape_id, class_index)

	Select * from (

	SELECT 'holdridge_forest', 'Sec', CASE WHEN land_area_ha > 0 THEN   round(forest_holdridge1_ha/land_area_ha::numeric, 2)  ELSE 0 END class_value, gid, 1 FROM data_preprocess.emprises WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	UNION ALL SELECT 'holdridge_forest', 'Humide', CASE WHEN land_area_ha > 0 THEN  round(forest_holdridge2_ha/land_area_ha::numeric, 2) ELSE 0 END class_value, gid, 2 FROM data_preprocess.emprises WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

	UNION ALL SELECT 'holdridge_forest', 'Très Humide', CASE WHEN land_area_ha > 0 THEN  round(forest_holdridge3_ha/land_area_ha::numeric, 2) ELSE 0 END class_value, gid, 3 FROM data_preprocess.emprises WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

	UNION ALL SELECT 'holdridge_forest_out', 'Sec', CASE WHEN land_area_ha > 0 THEN  round((land_holdridge1_ha-forest_holdridge1_ha)/land_area_ha::numeric, 2) ELSE 0 END class_value, gid, 1 FROM data_preprocess.emprises WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

	UNION ALL SELECT 'holdridge_forest_out', 'Humide', CASE WHEN land_area_ha > 0 THEN  round((land_holdridge2_ha-forest_holdridge2_ha)/land_area_ha::numeric, 2) ELSE 0 END class_value, gid, 2 FROM data_preprocess.emprises WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

	UNION ALL SELECT 'holdridge_forest_out', 'Très Humide', CASE WHEN land_area_ha > 0 THEN  round((land_holdridge3_ha-forest_holdridge3_ha)/land_area_ha::numeric, 2) ELSE 0 END class_value, gid, 3 FROM data_preprocess.emprises WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
	) as holdridge
	order by 4,1,5
;
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape_frequency_holdridge()
    OWNER TO amapiac;
