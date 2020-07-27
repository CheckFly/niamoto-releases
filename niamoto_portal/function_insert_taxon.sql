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
              FROM niamoto_preprocess.data_taxon_taxon 
              WHERE parent_id IS NULL 
              ORDER BY id_rang, id;
            max_tree_id integer default null;

            taxon_rec RECORD;

            leaf CURSOR 
              FOR SELECT * 
              FROM niamoto_preprocess.data_taxon_taxon 
              WHERE parent_id IS NOT NULL 
              ORDER BY id_rang, id;
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
            
            INSERT INTO niamoto_portal.data_taxon_taxon (id,full_name, rank_name, id_endemia, id_rang, occ_count, id_florical, lft, rght, tree_id, level , bark_thickness_avg, bark_thickness_max, bark_thickness_min, dbh_avg, dbh_max, dbh_median, fleshy_fruit, freq10_max, freq_max, freq_plot1ha_max, geo_pts_pn, height_max, leaf_area_avg, leaf_area_max, leaf_area_min, leaf_ldmc_avg, leaf_ldmc_max, leaf_ldmc_min, leaf_sla_avg, leaf_sla_max, leaf_sla_min, leaf_thickness_avg, leaf_thickness_max, leaf_thickness_min, leaf_type, ncpippn_count, occ_um_count, sexual_system, wood_density_avg, wood_density_max, wood_density_min)
            VALUES (taxon_rec.id, taxon_rec.full_name, taxon_rec.rank_name, taxon_rec.id_endemia, taxon_rec.id_rang, taxon_rec.occ_count, taxon_rec.id_florical, 1,2,max_tree_id,0 , taxon_rec.bark_thickness_avg, taxon_rec.bark_thickness_max, taxon_rec.bark_thickness_min, taxon_rec.dbh_avg, taxon_rec.dbh_max, taxon_rec.dbh_median, taxon_rec.fleshy_fruit, taxon_rec.freq10_max, taxon_rec.freq_max, taxon_rec.freq_plot1ha_max, taxon_rec.geo_pts_pn, taxon_rec.height_max, taxon_rec.leaf_area_avg, taxon_rec.leaf_area_max, taxon_rec.leaf_area_min, taxon_rec.leaf_ldmc_avg, taxon_rec.leaf_ldmc_max, taxon_rec.leaf_ldmc_min, taxon_rec.leaf_sla_avg, taxon_rec.leaf_sla_max, taxon_rec.leaf_sla_min, taxon_rec.leaf_thickness_avg, taxon_rec.leaf_thickness_max, taxon_rec.leaf_thickness_min, taxon_rec.leaf_type, taxon_rec.ncpippn_count, taxon_rec.occ_um_count, taxon_rec.sexual_system, taxon_rec.wood_density_avg, taxon_rec.wood_density_max, taxon_rec.wood_density_min);

          END LOOP;
          CLOSE tree;

          OPEN leaf;
          LOOP
            FETCH leaf INTO leaf_rec;
            EXIT WHEN NOT FOUND;

            SELECT * INTO taxon_rec FROM niamoto_portal.data_taxon_taxon WHERE id = leaf_rec.parent_id;
            INSERT INTO niamoto_portal.data_taxon_taxon (id, full_name, rank_name, id_endemia, id_rang, occ_count, id_florical, lft, rght, tree_id, level, parent_id, bark_thickness_avg, bark_thickness_max, bark_thickness_min, dbh_avg, dbh_max, dbh_median, fleshy_fruit, freq10_max, freq_max, freq_plot1ha_max, geo_pts_pn, height_max, leaf_area_avg, leaf_area_max, leaf_area_min, leaf_ldmc_avg, leaf_ldmc_max, leaf_ldmc_min, leaf_sla_avg, leaf_sla_max, leaf_sla_min, leaf_thickness_avg, leaf_thickness_max, leaf_thickness_min, leaf_type, ncpippn_count, occ_um_count, sexual_system, wood_density_avg, wood_density_max, wood_density_min) 
            VALUES (leaf_rec.id, leaf_rec.full_name, leaf_rec.rank_name, leaf_rec.id_endemia, leaf_rec.id_rang, leaf_rec.occ_count, leaf_rec.id_florical, 0, 0, taxon_rec.tree_id ,taxon_rec.level +1, leaf_rec.parent_id, leaf_rec.bark_thickness_avg, leaf_rec.bark_thickness_max, leaf_rec.bark_thickness_min, leaf_rec.dbh_avg, leaf_rec.dbh_max, leaf_rec.dbh_median, leaf_rec.fleshy_fruit, leaf_rec.freq10_max, leaf_rec.freq_max, leaf_rec.freq_plot1ha_max, leaf_rec.geo_pts_pn, leaf_rec.height_max, leaf_rec.leaf_area_avg, leaf_rec.leaf_area_max, leaf_rec.leaf_area_min, leaf_rec.leaf_ldmc_avg, leaf_rec.leaf_ldmc_max, leaf_rec.leaf_ldmc_min, leaf_rec.leaf_sla_avg, leaf_rec.leaf_sla_max, leaf_rec.leaf_sla_min, leaf_rec.leaf_thickness_avg, leaf_rec.leaf_thickness_max, leaf_rec.leaf_thickness_min, leaf_rec.leaf_type, leaf_rec.ncpippn_count, leaf_rec.occ_um_count, leaf_rec.sexual_system, leaf_rec.wood_density_avg, leaf_rec.wood_density_max, leaf_rec.wood_density_min);
            
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
