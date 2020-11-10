-- FUNCTION: niamoto_portal.insert_taxon_frequency_phenology()

-- DROP FUNCTION niamoto_portal.insert_taxon_frequency_phenology();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_taxon_frequency_stat(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN


INSERT INTO niamoto_portal.data_taxon_frequency (taxon_id, class_object, class_name, class_value) 				  
(SELECT  1, 'stats', 'sum_occ', sum(occ_count)
	FROM data_preprocess.data_taxon where id_rang=10



);

	
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_taxon_frequency_stat()
    OWNER TO amapiac;
