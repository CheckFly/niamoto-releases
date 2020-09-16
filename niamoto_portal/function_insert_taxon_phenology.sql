-- FUNCTION: niamoto_portal.insert_taxon_frequency_phenology()

-- DROP FUNCTION niamoto_portal.insert_taxon_frequency_phenology();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_taxon_frequency_phenology(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN


with 
pheno_fleur_total as (SELECT taxon_id, class_object, case when sum(class_value)>0 then sum(class_value) else 1 end  total
	FROM niamoto_preprocess.data_taxon_frequency
	where class_object = 'pheno_fleur'
	GROUP BY taxon_id, class_object),

pheno_fruit_total as (SELECT taxon_id, class_object, case when sum(class_value)>0 then sum(class_value) else 1 end  total
	FROM niamoto_preprocess.data_taxon_frequency
	where class_object = 'pheno_fruit'
	GROUP BY taxon_id, class_object)

INSERT INTO niamoto_portal.data_taxon_frequency (taxon_id, class_object, class_name, class_value, class_index) 				  
(SELECT dtf.taxon_id, dtf.class_object, dtf.class_name, round((dtf.class_value/pft.total)::numeric,2) class_value, class_index
	FROM niamoto_preprocess.data_taxon_frequency dtf
	LEFT JOIN pheno_fleur_total pft ON dtf.taxon_id=pft.taxon_id
	where dtf.class_object = 'pheno_fleur'
	
UNION ALL
	

					  
SELECT dtf.taxon_id, dtf.class_object, dtf.class_name, round((dtf.class_value/pft.total)::numeric,2) class_value, class_index
	FROM niamoto_preprocess.data_taxon_frequency dtf
	LEFT JOIN pheno_fruit_total pft ON dtf.taxon_id=pft.taxon_id
	where dtf.class_object = 'pheno_fruit');
	
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_taxon_frequency_phenology()
    OWNER TO amapiac;
