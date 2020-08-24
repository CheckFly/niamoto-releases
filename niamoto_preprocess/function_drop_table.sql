-- FUNCTION: niamoto_preprocess.drop_table()

-- DROP FUNCTION niamoto_preprocess.drop_table();

CREATE OR REPLACE FUNCTION niamoto_preprocess.drop_table(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
        BEGIN
				DROP SEQUENCE IF EXISTS niamoto_preprocess.emprises_gid_seq CASCADE;
				DROP SEQUENCE IF EXISTS niamoto_preprocess.carto_forest_id_seq CASCADE;
				DROP TABLE IF EXISTS niamoto_preprocess.emprises CASCADE;
				DROP TABLE IF EXISTS niamoto_preprocess.emprises_holdridge CASCADE;
				DROP TABLE IF EXISTS niamoto_preprocess.emprises_raster CASCADE;
				DROP TABLE IF EXISTS niamoto_preprocess.carto_forest CASCADE;
                DROP TABLE IF EXISTS niamoto_preprocess.taxon_referentiel CASCADE;
                DROP TABLE IF EXISTS niamoto_preprocess.shape_forest_emprises_utm CASCADE;

                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_preprocess.drop_table()
    OWNER TO amapiac;
