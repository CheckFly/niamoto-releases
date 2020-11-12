-- FUNCTION: niamoto_portal.insert_list_tree()

-- DROP FUNCTION niamoto_portal.insert_list_tree();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_list_tree(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
		
            TRUNCATE niamoto_portal.portal_tree;

            -- ALTER SEQUENCE portal_tree_id_seq RESTART WITH 1;

            INSERT INTO niamoto_portal.portal_tree (
                id_endemia,
                id_florical,
                family_name,
                genus_name,
                species_name,
                infraspecies_name,
                name,
                statut
            )

            SELECT
                id_endemia,
                id_florical,
                family_name,
                genus_name,
                species_name,
                infraspecies_name,
                name,
                statut
            FROM data_preprocess.tree_taxon
            ORDER BY family_name,genus_name, species_name;

            RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_list_tree()
    OWNER TO amapiac;
