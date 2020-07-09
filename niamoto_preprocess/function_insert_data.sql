-- FUNCTION: niamoto_preprocess.insert_data()

-- DROP FUNCTION niamoto_preprocess.insert_data();

CREATE OR REPLACE FUNCTION niamoto_preprocess.insert_data(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
				INSERT INTO niamoto_preprocess.emprises
				SELECT * FROM atlas_pn.pn_emprises;
				INSERT INTO niamoto_preprocess.emprises_holdridge
				SELECT * FROM atlas_pn.pn_emprises_holdridge;
				INSERT INTO niamoto_preprocess.emprises_raster
				SELECT * FROM atlas_pn.pn_emprises_raster;
				INSERT INTO niamoto_preprocess.carto_forest
				SELECT * FROM atlas_pn.pn_carto_forest;
				INSERT INTO niamoto_preprocess.taxon_referentiel
				SELECT * FROM occurences.letouze_taxon_referentiel
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_preprocess.insert_data()
    OWNER TO amapiac;
