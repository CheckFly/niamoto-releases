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

with 
strate_total as (SELECT taxon_id, class_object, case when sum(class_value)>0 then sum(class_value) else 1 end  total
	FROM niamoto_preprocess.data_taxon_frequency
	where class_object = 'strate'
	GROUP BY taxon_id, class_object),
holdridge_total as (SELECT taxon_id, class_object, case when sum(class_value)>0 then sum(class_value) else 1 end  total
	FROM niamoto_preprocess.data_taxon_frequency
	where class_object = 'holdridge'
	GROUP BY taxon_id, class_object)

INSERT INTO niamoto_portal.data_taxon_frequency (taxon_id, class_object, class_name, class_value, param3_float) 				  
(SELECT dtf.taxon_id, dtf.class_object, dtf.class_name, round((dtf.class_value/st.total)::numeric,2)*100 class_value, dtf.class_index
	FROM niamoto_preprocess.data_taxon_frequency dtf
    LEFT JOIN strate_total st ON dtf.taxon_id=st.taxon_id
	where dtf.class_object = 'strate'

UNION ALL

SELECT dtf.taxon_id, dtf.class_object, dtf.class_name, round((dtf.class_value/ht.total)::numeric,2)*100 class_value, dtf.class_index
	FROM niamoto_preprocess.data_taxon_frequency dtf
    LEFT JOIN holdridge_total ht ON dtf.taxon_id=ht.taxon_id
	where dtf.class_object = 'holdridge'

UNION ALL

SELECT dtf.taxon_id, dtf.class_object, dtf.class_name, dtf.class_value, dtf.class_index
	FROM niamoto_preprocess.data_taxon_frequency dtf
	where dtf.class_object = 'top_species' and dtf.class_index <= 10

UNION ALL

SELECT dtf.taxon_id, dtf.class_object, dtf.class_name, dtf.class_value, dtf.class_index
	FROM niamoto_preprocess.data_taxon_frequency dtf
	where dtf.class_object in ('dbh', 'rainfall', 'elevation' ));	

	
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_taxon_frequency()
    OWNER TO amapiac;
