-- FUNCTION: niamoto_portal.insert_data()

-- DROP FUNCTION niamoto_portal.insert_data();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_data(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE passed BOOLEAN;
        BEGIN
				
				SELECT niamoto_portal.insert_shape() INTO passed;
				SELECT niamoto_portal.insert_shape_frequency_cover() INTO passed;
				SELECT niamoto_portal.insert_shape_frequency_elevation() INTO passed;
				SELECT niamoto_portal.insert_shape_frequency_holdridge() INTO passed;
				SELECT niamoto_portal.insert_shape_frequency_fragmentation() INTO passed;
                SELECT niamoto_portal.insert_taxon() INTO passed;
                SELECT niamoto_portal.insert_taxon_frequency_phenology() INTO passed;
                SELECT niamoto_portal.insert_taxon_frequency() INTO passed;
                SELECT niamoto_portal.insert_taxon_frequency_stat() INTO passed;
                SELECT niamoto_portal.insert_plot() INTO passed;
                SELECT niamoto_portal.insert_plot_frequency() INTO passed;
                SELECT niamoto_portal.insert_list_tree() INTO passed;
                RETURN 1;
                
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_data()
    OWNER TO amapiac;
