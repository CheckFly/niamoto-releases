-- FUNCTION: niamoto_portal.insert_taxon()

-- DROP FUNCTION niamoto_portal.insert_taxon();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_taxon(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        DECLARE 
            tree CURSOR 
              FOR SELECT * 
              FROM niamoto_preprocess.taxon 
              WHERE parent_id IS NULL ORDER BY id;
            max_tree_id integer default null;

            taxon_rec RECORD;

            leaf CURSOR 
              FOR SELECT * 
              FROM niamoto_preprocess.taxon 
              WHERE parent_id IS NOT NULL ORDER BY id_rang, id;
            leaf_rec RECORD;

            gauche_parent BIGINT DEFAULT NULL;
            droite_parent BIGINT DEFAULT NULL;

        BEGIN

          TRUNCATE niamoto_portal.data_taxon_taxon CASCADE;

          OPEN tree;
          LOOP
            FETCH tree INTO taxon_rec;
            EXIT WHEN NOT FOUND;
            SELECT INTO max_tree_id (select max(tree_id) from niamoto_portal.data_taxon_taxon);
            IF max_tree_id IS NULL THEN
              max_tree_id :=1;
            ELSE
              max_tree_id := max_tree_id + 1;
            END IF;

            -- raise notice 'Value: %', max_tree_id;
            
            INSERT INTO niamoto_portal.data_taxon_taxon (id,full_name, rank_name, id_endemia, id_rang, lft, rght, tree_id, level )
            VALUES (taxon_rec.id, taxon_rec.full_name, taxon_rec.rank_name, taxon_rec.id_endemia, taxon_rec.id_rang, 1,2,max_tree_id,0);

          END LOOP;
          CLOSE tree;

          OPEN leaf;
          LOOP
            FETCH leaf INTO leaf_rec;
            EXIT WHEN NOT FOUND;

            SELECT * INTO taxon_rec FROM niamoto_portal.data_taxon_taxon WHERE id = leaf_rec.parent_id;
            INSERT INTO niamoto_portal.data_taxon_taxon (id,full_name, rank_name, id_endemia, id_rang, parent_id, lft, rght, tree_id, level) 
            VALUES (leaf_rec.id, leaf_rec.full_name, leaf_rec.rank_name, leaf_rec.id_endemia, leaf_rec.id_rang,leaf_rec.parent_id, 0, 0, taxon_rec.tree_id ,taxon_rec.level +1);
            
            SELECT lft INTO gauche_parent FROM niamoto_portal.data_taxon_taxon WHERE id = leaf_rec.parent_id;
            SELECT rght INTO droite_parent FROM niamoto_portal.data_taxon_taxon WHERE id = leaf_rec.parent_id;
            
            UPDATE niamoto_portal.data_taxon_taxon SET lft = lft + 2
            WHERE lft > gauche_parent and tree_id = taxon_rec.tree_id;
            
            UPDATE niamoto_portal.data_taxon_taxon SET rght = rght + 2
            WHERE (rght >= droite_parent OR (rght > gauche_parent + 1 AND rght < droite_parent)) and tree_id = taxon_rec.tree_id;
            
            UPDATE niamoto_portal.data_taxon_taxon SET lft = gauche_parent + 1, rght = gauche_parent + 2 WHERE id = leaf_rec.id and tree_id = taxon_rec.tree_id;

          END LOOP;
          CLOSE leaf;
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_taxon()
    OWNER TO amapiac;
