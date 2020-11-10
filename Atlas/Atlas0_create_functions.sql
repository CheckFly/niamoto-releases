------------------------------------------------------
---Function to generate a histogram of pixel distribution into the imput raster
------------------------------------------------------
DROP FUNCTION IF EXISTS atlas_pn.pn_classifyraster(raster, integer, integer);
CREATE OR REPLACE FUNCTION atlas_pn.pn_classifyraster(rast raster,classmin integer, classmax integer)
RETURNS TABLE (classe double precision, pixelcount integer)
AS
$BODY$
	BEGIN
	RETURN QUERY 
		(SELECT
			min ::float as classe,
			sum(count) ::integer pixelcount
		FROM
			(SELECT	
				(ST_Histogram(rast,1,classmax,ARRAY[1])).* AS hist
			  WHERE NOT ST_BandIsNoData(rast,1,true) --exclude rasters with only NODATA values (speed the query for rasters in multi-rows)
			) b
		WHERE min between classmin and classmax
		GROUP BY min
		ORDER BY min
		);
	END
$BODY$
LANGUAGE 'plpgsql'
STABLE;
COMMENT ON FUNCTION atlas_pn.pn_classifyraster(raster, integer, integer) IS 'return a table of the pixel distribution of the input raster splitted by classes';
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------



------------------------------------------------------
---Function to generate a grid from a geometry, width and height
------------------------------------------------------
DROP FUNCTION atlas_pn.pn_makegrid_2d(geometry, integer, integer);
CREATE OR REPLACE FUNCTION atlas_pn.pn_makegrid_2d (
  bound_polygon public.geometry,
  width_step integer,
  height_step integer
)
RETURNS public.geometry AS
$body$
DECLARE
  Xmin DOUBLE PRECISION;
  Xmax DOUBLE PRECISION;
  Ymax DOUBLE PRECISION;
  X DOUBLE PRECISION;
  Y DOUBLE PRECISION;
  NextX DOUBLE PRECISION;
  NextY DOUBLE PRECISION;
  CPoint public.geometry;
  sectors public.geometry[];
  i INTEGER;
  SRID INTEGER;
BEGIN
  Xmin := ST_XMin(bound_polygon);
  Xmax := ST_XMax(bound_polygon);
  Ymax := ST_YMax(bound_polygon);
  SRID := ST_SRID(bound_polygon);

  Y := ST_YMin(bound_polygon); --current sector's corner coordinate
  i := -1;
  <<yloop>>
  LOOP
    IF (Y > Ymax) THEN  
        EXIT;
    END IF;

    X := Xmin;
    <<xloop>>
    LOOP
      IF (X > Xmax) THEN
          EXIT;
      END IF;

      CPoint := ST_SetSRID(ST_MakePoint(X + width_step/2, Y+ height_step/2), SRID);
      NextX := X + width_step;
     

      i := i + 1;
      sectors[i] := ST_Expand(CPoint,width_step/2,height_step/2);

      X := NextX;
    END LOOP xloop;
    Y := Y + height_step;
  END LOOP yloop;

  RETURN ST_Collect(sectors);
END;
$body$
LANGUAGE 'plpgsql';



------------------------------------------------------
---Function to compute quartiles (Q1, Q2=median, Q3) from an one dimension array of numeric data (double precision)
---Return an array of 3 dimensions [q1, q2, q3]
------------------------------------------------------
DROP FUNCTION  IF EXISTS atlas_pn.pn_quartiles(double precision[]);
CREATE OR REPLACE FUNCTION atlas_pn.pn_quartiles(array_asc double precision[])
  RETURNS double precision[] AS
$BODY$

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
$BODY$
LANGUAGE plpgsql
STABLE;
COMMENT ON FUNCTION atlas_pn.pn_quartiles(double precision[]) IS 'Compute quartiles (Q1, Q2=median, Q3) from one dimension array of numeric data (double precision) & Return an array of 3 dimensions [q1, q2, q3]';

