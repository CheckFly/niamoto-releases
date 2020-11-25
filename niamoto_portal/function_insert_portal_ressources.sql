-- FUNCTION: niamoto_portal.insert_ressources()

-- DROP FUNCTION niamoto_portal.insert_ressources();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_ressources(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN

            TRUNCATE niamoto_portal.portal_ressource CASCADE;
            ALTER SEQUENCE niamoto_portal.portal_ressource_id_seq RESTART WITH 1;
            INSERT INTO niamoto_portal.portal_ressource (support, who, description, category, journal, issue, pages, year, link)
            SELECT support, authors, title, category, journal, issue, pages, year, link
            FROM data_preprocess.ressources;
          
          RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_ressources()
    OWNER TO amapiac;
