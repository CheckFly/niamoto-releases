#!/bin/bash 
psql -d amapiac -h niamoto.ird.nc -U amapiac \
-f niamoto_preprocess/function_create_table.sql \
-f niamoto_preprocess/function_drop_table.sql \
-f niamoto_preprocess/function_create_view_mat.sql \
-f niamoto_preprocess/function_insert_data.sql \
-f niamoto_preprocess/function_install.sql \
-f niamoto_preprocess/function_quartiles.sql \
-f niamoto_portal/function_insert_data.sql \
-f niamoto_portal/function_insert_shape.sql \
-f niamoto_portal/function_insert_shape_frequency_cover.sql \
-f niamoto_portal/function_insert_shape_frequency_elevation.sql \
-f niamoto_portal/function_insert_shape_frequency_fragmentation.sql \
-f niamoto_portal/function_insert_shape_frequency_holdridge.sql