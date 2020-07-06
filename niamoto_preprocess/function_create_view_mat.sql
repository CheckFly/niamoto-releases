-- FUNCTION: niamoto_preprocess.create_view_mat()

-- DROP FUNCTION niamoto_preprocess.create_view_mat();

CREATE OR REPLACE FUNCTION niamoto_preprocess.create_view_mat(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
				-- View: niamoto_preprocess.shape_emprises_utm

-- DROP MATERIALIZED VIEW niamoto_preprocess.shape_emprises_utm;

CREATE MATERIALIZED VIEW niamoto_preprocess.shape_emprises_utm
TABLESPACE pg_default
AS
 SELECT emprises.gid,
    emprises.name,
    st_transform(emprises.geom, 32758) AS geom
   FROM niamoto_preprocess.emprises
WITH DATA;

ALTER TABLE niamoto_preprocess.shape_emprises_utm
    OWNER TO amapiac;

COMMENT ON MATERIALIZED VIEW niamoto_preprocess.shape_emprises_utm
    IS 'dd';

-- View: niamoto_preprocess.shape_carto_utm

-- DROP MATERIALIZED VIEW niamoto_preprocess.shape_carto_utm;

CREATE MATERIALIZED VIEW niamoto_preprocess.shape_carto_utm
TABLESPACE pg_default
AS
 SELECT st_transform(carto_forest.f_geom, 32758) AS geom
   FROM niamoto_preprocess.carto_forest
WITH DATA;

ALTER TABLE niamoto_preprocess.shape_carto_utm
    OWNER TO amapiac;

-- View: niamoto_preprocess.shape_forest_emprises_utm

-- DROP MATERIALIZED VIEW niamoto_preprocess.shape_forest_emprises_utm;

CREATE MATERIALIZED VIEW niamoto_preprocess.shape_forest_emprises_utm
TABLESPACE pg_default
AS
 SELECT a.gid,
    a.name,
        CASE
            WHEN a.gid = 1 THEN true
            ELSE st_coveredby(b.geom, a.geom)
        END AS is_within,
        CASE
            WHEN a.gid = 1 THEN b.geom
            ELSE st_intersection(a.geom, b.geom)
        END AS geom
   FROM niamoto_preprocess.shape_emprises_utm a,
    niamoto_preprocess.shape_carto_utm b
  WHERE st_intersects(a.geom, b.geom)
WITH DATA;

ALTER TABLE niamoto_preprocess.shape_forest_emprises_utm
    OWNER TO amapiac;

-- View: niamoto_preprocess.data_forest

-- DROP MATERIALIZED VIEW niamoto_preprocess.data_forest;

CREATE MATERIALIZED VIEW niamoto_preprocess.data_forest
TABLESPACE pg_default
AS
 SELECT shape_forest_emprises_utm.gid,
    shape_forest_emprises_utm.name,
    st_area(shape_forest_emprises_utm.geom) / 10000::double precision AS aire_patch,
    shape_forest_emprises_utm.is_within
   FROM niamoto_preprocess.shape_forest_emprises_utm
  ORDER BY shape_forest_emprises_utm.gid, (st_area(shape_forest_emprises_utm.geom) / 10000::double precision)
WITH DATA;

ALTER TABLE niamoto_preprocess.data_forest
    OWNER TO amapiac;

-- View: niamoto_preprocess.data_stats

-- DROP MATERIALIZED VIEW niamoto_preprocess.data_stats;

CREATE MATERIALIZED VIEW niamoto_preprocess.data_stats
TABLESPACE pg_default
AS
 SELECT b.gid,
    b.total,
    b.minimum,
    b.stats[1] AS q1,
    b.stats[2] AS q2,
    b.stats[3] AS q3,
    b.maximum,
    b.average
   FROM ( SELECT data_forest.gid,
            sum(data_forest.aire_patch) AS total,
            min(data_forest.aire_patch) AS minimum,
            niamoto_preprocess.quartiles(array_agg(data_forest.aire_patch)) AS stats,
            avg(data_forest.aire_patch) AS average,
            max(data_forest.aire_patch) AS maximum
           FROM niamoto_preprocess.data_forest
          GROUP BY data_forest.gid
          ORDER BY data_forest.gid) b
WITH DATA;

ALTER TABLE niamoto_preprocess.data_stats
    OWNER TO amapiac;

		
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_preprocess.create_view_mat()
    OWNER TO amapiac;

-- View: niamoto_preprocess.taxon

-- DROP VIEW niamoto_preprocess.taxon;

CREATE OR REPLACE VIEW niamoto_preprocess.taxon
 AS
 SELECT letouze_taxon_referentiel.id_taxon_ref AS id,
    letouze_taxon_referentiel.nom_taxon_ref AS full_name,
    letouze_taxon_referentiel.basename AS rank_name,
        CASE letouze_taxon_referentiel.id_rang
            WHEN 10 THEN NULL::integer
            ELSE letouze_taxon_referentiel.tax_id_taxon_ref
        END AS parent_id,
        CASE
            WHEN letouze_taxon_referentiel.id_endemia IS NULL THEN 0
            ELSE letouze_taxon_referentiel.id_endemia
        END AS id_endemia,
    letouze_taxon_referentiel.id_rang
   FROM occurences.letouze_taxon_referentiel
  WHERE letouze_taxon_referentiel.id_ncpippn IS NOT NULL
  ORDER BY letouze_taxon_referentiel.id_rang, letouze_taxon_referentiel.id_taxon_ref, letouze_taxon_referentiel.tax_id_taxon_ref;

ALTER TABLE niamoto_preprocess.taxon
    OWNER TO amapiac;

