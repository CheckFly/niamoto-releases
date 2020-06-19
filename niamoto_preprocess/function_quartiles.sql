-- FUNCTION: niamoto_preprocess.quartiles(double precision[])

-- DROP FUNCTION niamoto_preprocess.quartiles(double precision[]);

CREATE OR REPLACE FUNCTION niamoto_preprocess.quartiles(
	array_asc double precision[])
    RETURNS double precision[]
    LANGUAGE 'plpgsql'

    COST 100
    STABLE 
AS $BODY$

DECLARE
    array_value0 double precision;
    array_value1 double precision;
    a double precision;
    b double precision;
    q1 double precision;
    q2 double precision;
    q3 double precision;
    threshold double precision;
    sum_values double precision;
    total_values double precision;

BEGIN
sum_values:=0;
a:=0;
b:=0;
SELECT INTO total_values (SELECT sum(z) FROM unnest(array_asc) AS z);
threshold:=total_values/4;
    FOREACH array_value1 IN ARRAY  array_asc--
    LOOP
        -- calculate a and b of the y=ax+b line between before and after the threshold
        a:=array_value1 /(array_value1 -array_value0);
	b:=sum_values-a*array_value0;
	--test for each one because some time a r could exceed more than a single threshold
	IF sum_values+array_value1 >= threshold THEN
		IF q1 IS NULL THEN --to fill q1 only one time 
			q1:= (threshold-b)/a;
			threshold=total_values/2;
			--RETURN q1;
		END IF;
	END IF;
	IF sum_values+array_value1 >= threshold THEN
		IF q2 IS NULL THEN 
			q2:= (threshold-b)/a;
			threshold=3*total_values/4;
			--RETURN q2; --median
		END IF;
	END IF;
	IF sum_values+array_value1 >= threshold THEN
		IF q3 IS NULL THEN 
			q3:= (threshold-b)/a;
			--RETURN q3;
		END IF;
	END IF;
        sum_values:=sum_values+array_value1;
        array_value0 := array_value1 ;
    END LOOP;
     
    RETURN ARRAY[q1,q2,q3];
END
$BODY$;

ALTER FUNCTION niamoto_preprocess.quartiles(double precision[])
    OWNER TO amapiac;

COMMENT ON FUNCTION niamoto_preprocess.quartiles(double precision[])
    IS 'Compute quartiles (Q1, Q2=median, Q3) from one dimension array of numeric data (double precision) & Return an array of 3 dimensions [q1, q2, q3]';
