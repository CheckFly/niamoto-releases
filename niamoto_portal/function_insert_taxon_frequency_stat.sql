-- FUNCTION: niamoto_portal.insert_taxon_frequency_phenology()

-- DROP FUNCTION niamoto_portal.insert_taxon_frequency_phenology();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_taxon_frequency(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN


INSERT INTO niamoto_portal.data_taxon_frequency (taxon_id, class_object, class_name, class_value) 				  
(SELECT  1, 'stats', 'sum_occ', sum(occ_count)
	FROM niamoto_preprocess.data_taxon_taxon where id_rang=10;

UNION ALL

SELECT dtf.taxon_id, dtf.class_object, dtf.class_name, round((dtf.class_value/ht.total)::numeric,2)*100 class_value, dtf.class_index
	FROM niamoto_preprocess.data_taxon_frequency dtf
    LEFT JOIN holdridge_total ht ON dtf.taxon_id=ht.taxon_id
	where dtf.class_object = 'holdridge'


);

	
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_taxon_frequency()
    OWNER TO amapiac;
