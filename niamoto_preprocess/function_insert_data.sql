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
				SELECT * FROM occurences.letouze_taxon_referentiel;
				INSERT INTO niamoto_preprocess.shape_forest_emprises_utm
				 SELECT a.gid,a.name,
						CASE
							WHEN a.gid = 1 THEN true
							ELSE st_coveredby(st_transform(b.f_geom, 32758), st_transform(a.geom, 32758))
						END AS is_within,
						CASE
							WHEN a.gid = 1 THEN ST_Multi(st_transform(b.f_geom, 32758))
							ELSE ST_Multi(st_intersection(st_transform(a.geom, 32758), st_transform(b.f_geom, 32758)))
						END AS geom
				FROM niamoto_preprocess.emprises a,
					niamoto_preprocess.carto_forest b
				WHERE st_intersects(st_transform(a.geom, 32758), st_transform(b.f_geom, 32758));
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_preprocess.insert_data()
    OWNER TO amapiac;
