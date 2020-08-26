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
            ALTER SEQUENCE portal_ressource_id_seq RESTART WITH 1
            INSERT INTO niamoto_portal.portal_ressource
            SELECT support, who, description, journal, issue, pages, year, link
            FROM niamoto_preprocess.ressources;
          
          RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_ressources()
    OWNER TO amapiac;
