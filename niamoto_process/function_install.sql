-- FUNCTION: niamoto_preprocess.install()

-- DROP FUNCTION niamoto_preprocess.install();

CREATE OR REPLACE FUNCTION niamoto_preprocess.install(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE passed BOOLEAN;
        BEGIN
				-- NIAMOTO PREPROCESS
				SELECT niamoto_preprocess.drop_table() INTO passed;
				SELECT niamoto_preprocess.create_table() INTO passed;
				SELECT niamoto_preprocess.insert_data() INTO passed;
				SELECT niamoto_preprocess.create_view_mat() INTO passed;
				
				-- NIAMOTO PORTAL
				SELECT niamoto_portal.insert_data() INTO passed;
		
                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_preprocess.install()
    OWNER TO amapiac;
