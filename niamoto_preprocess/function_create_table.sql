-- FUNCTION: niamoto_preprocess.create_table()

-- DROP FUNCTION niamoto_preprocess.create_table();

CREATE OR REPLACE FUNCTION niamoto_preprocess.create_table(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
        BEGIN
				-- SEQUENCE: niamoto_preprocess.emprises_gid_seq

				CREATE SEQUENCE niamoto_preprocess.emprises_gid_seq
					INCREMENT 1
					START 1
					MINVALUE 1
					MAXVALUE 2147483647
					CACHE 1;

				ALTER SEQUENCE niamoto_preprocess.emprises_gid_seq
					OWNER TO amapiac;

				-- Table: niamoto_preprocess.emprises

				CREATE TABLE niamoto_preprocess.emprises
				(
					gid integer NOT NULL DEFAULT nextval('niamoto_preprocess.emprises_gid_seq'::regclass),
					type character varying(50) COLLATE pg_catalog."default" NOT NULL,
					name character varying(50) COLLATE pg_catalog."default" NOT NULL,
					land_area_ha numeric DEFAULT 0,
					land_um_area_ha numeric DEFAULT 0,
					reserve_area_ha numeric DEFAULT 0,
					reserve_um_area_ha numeric DEFAULT 0,
					mining_area_ha numeric DEFAULT 0,
					mining_um_area_ha numeric DEFAULT 0,
					ppe_area_ha numeric DEFAULT 0,
					forest_ppe_ha numeric DEFAULT 0,
					forest_area_ha numeric DEFAULT 0,
					forest_um_area_ha numeric DEFAULT 0,
					forest_reserve_ha numeric DEFAULT 0,
					forest_mining_ha numeric DEFAULT 0,
					forest_100m_ha numeric DEFAULT 0,
					forest_ssdm80_ha numeric DEFAULT 0,
					forest_aob2015_ha numeric DEFAULT 0,
					forest_perimeter_km numeric DEFAULT 0,
					nb_patchs integer DEFAULT 0,
					fragment_meff_cbc numeric DEFAULT 0,
					nb_patchs_in integer DEFAULT 0,
					forest_in_ha numeric DEFAULT 0,
					r_in_median numeric DEFAULT 0,
					nb_plots integer DEFAULT 0,
					nb_occurences integer DEFAULT 0,
					nb_families integer DEFAULT 0,
					nb_species integer DEFAULT 0,
					n_unique_species integer DEFAULT 0,
					geom geometry(MultiPolygon,4326),
					um_geom geometry(MultiPolygon,4326),
					forest_geom geometry(MultiPolygon,4326),
					pt_plot geometry(MultiPoint,4326),
					pt_occ geometry(MultiPoint,4326),
					CONSTRAINT table_emprises_pkey PRIMARY KEY (gid)
				)
				WITH (
					OIDS = FALSE
				)
				TABLESPACE pg_default;

				ALTER TABLE niamoto_preprocess.emprises
					OWNER to amapiac;

				-- Table: niamoto_preprocess.emprises_holdridge
				
				CREATE TABLE niamoto_preprocess.emprises_holdridge
				(
					gid_emprise integer NOT NULL,
					mnt_object text COLLATE pg_catalog."default" NOT NULL,
					classe integer NOT NULL,
					pixelcount integer,
					CONSTRAINT table_emprises_holdridge_pkey PRIMARY KEY (gid_emprise, mnt_object, classe)
				)
				WITH (
					OIDS = FALSE
				)
				TABLESPACE pg_default;

				ALTER TABLE niamoto_preprocess.emprises_holdridge
					OWNER to amapiac;
		
				-- Table: niamoto_preprocess.emprises_raster

				CREATE TABLE niamoto_preprocess.emprises_raster
				(
					gid_emprise integer NOT NULL,
					mnt_object text COLLATE pg_catalog."default" NOT NULL,
					class_elevation integer NOT NULL,
					class_rainfall integer NOT NULL,
					pixelcount integer,
					CONSTRAINT table_emprises_raster_pkey PRIMARY KEY (gid_emprise, mnt_object, class_elevation, class_rainfall)
				)
				WITH (
					OIDS = FALSE
				)
				TABLESPACE pg_default;

				ALTER TABLE niamoto_preprocess.emprises_raster
					OWNER to amapiac;
					
			-- SEQUENCE: niamoto_preprocess.carto_forest_id_seq

			CREATE SEQUENCE niamoto_preprocess.carto_forest_id_seq
				INCREMENT 1
				START 1
				MINVALUE 1
				MAXVALUE 2147483647
				CACHE 1;

			ALTER SEQUENCE niamoto_preprocess.carto_forest_id_seq
				OWNER TO amapiac;

			-- Table: niamoto_preprocess.carto_forest

			CREATE TABLE niamoto_preprocess.carto_forest
			(
				id integer NOT NULL DEFAULT nextval('niamoto_preprocess.carto_forest_id_seq'::regclass),
				gid_carto integer,
				f_geom geometry(Polygon,4326),
				f_geom100 geometry(MultiPolygon,4326),
				f_geom300 geometry(MultiPolygon,4326),
				f_geomssdm geometry(MultiPolygon,4326),
				f_geomaob geometry(MultiPolygon,4326),
				count_holdridge integer,
				CONSTRAINT table_carto_forest_pkey PRIMARY KEY (id)
			)
			WITH (
				OIDS = FALSE
			)
			TABLESPACE pg_default;

			ALTER TABLE niamoto_preprocess.carto_forest
				OWNER to amapiac;

			-- Table: taxon_referentiel

			-- DROP TABLE niamoto_preprocesstaxon_referentiel;

			CREATE TABLE niamoto_preprocess.taxon_referentiel
			(
				id_taxon_ref integer NOT NULL,
				id_rang integer,
				tax_id_taxon_ref integer,
				tax2_id_taxon_ref integer,
				basionyme double precision,
				nom_taxon_ref character varying(255) COLLATE pg_catalog."default",
				statut character varying(1) COLLATE pg_catalog."default",
				basename character varying(255) COLLATE pg_catalog."default",
				authors character varying(255) COLLATE pg_catalog."default",
				nomenclature text COLLATE pg_catalog."default",
				id_florical integer,
				id_endemia integer,
				id_florical2012 integer,
				id_florical2017 integer,
				id_ncpippn integer,
				is_tree boolean DEFAULT false,
				is_liana boolean DEFAULT false,
				CONSTRAINT letouze_taxon_referentiel_pkey PRIMARY KEY (id_taxon_ref)
			)
			WITH (
				OIDS = FALSE
			)
			TABLESPACE pg_default;

			ALTER TABLE niamoto_preprocess.taxon_referentiel
				OWNER to amapiac;

			

                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_preprocess.create_table()
    OWNER TO amapiac;
