-- FUNCTION: niamoto_portal.insert_site_info()

-- DROP FUNCTION niamoto_portal.insert_site_info();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_site_info(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
		
            TRUNCATE niamoto_portal.portal_siteinfo;

            -- ALTER SEQUENCE portal_siteinfo_id_seq RESTART WITH 1;

            INSERT INTO niamoto_portal.portal_siteinfo(
	        "dateUpdateData")
	        VALUES (now());

            RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_site_info()
    OWNER TO amapiac;
