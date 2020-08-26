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

            ALTER SEQUENCE portal_tree_id_seq RESTART WITH 1

            INSERT INTO niamoto_portal.portal_tree (
                id_species,
                id_endemia,
                id_florical,
                id_family,
                id_infra,
                family_name,
                genre_name,
                species_name,
                infraspecies_name,
                name,
                statut
            )

            SELECT
                id_species,
                a.id_endemia,
                a.id_florical,
                d.id_taxon_ref id_family,
                id_infra,
                d.nom_taxon_ref family_name,
                e.nom_taxon_ref genus_name,
                b.nom_taxon_ref species_name,
                c.nom_taxon_ref infraspecies_name,
                COALESCE (c.nom_taxon_ref,b.nom_taxon_ref) trees_taxa,
                CASE WHEN coalesce(c.statut , b.statut)='A' then 'Autochtone' else 'Endémique' END as statut
            FROM
                (SELECT id_taxon_ref id_infra, pn_taxon_getparent(id_taxon_ref,21) id_species, pn_taxon_getparent(id_taxon_ref,14) id_genus, pn_taxon_getparent(id_taxon_ref,10) id_family, id_florical, id_endemia
                        FROM niamoto_preprocess.taxon_referentiel
                        WHERE is_tree) a
            LEFT JOIN niamoto_preprocess.taxon_referentiel b ON a.id_species=b.id_taxon_ref
            LEFT JOIN niamoto_preprocess.taxon_referentiel c ON a.id_infra=c.id_taxon_ref and a.id_infra<>a.id_species
            LEFT JOIN niamoto_preprocess.taxon_referentiel d ON a.id_family=d.id_taxon_ref
            LEFT JOIN niamoto_preprocess.taxon_referentiel e ON a.id_genus=e.id_taxon_ref
            ORDER BY d.nom_taxon_ref,e.nom_taxon_ref, b.nom_taxon_ref;

            RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_list_tree()
    OWNER TO amapiac;
