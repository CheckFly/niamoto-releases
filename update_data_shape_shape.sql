 update niamoto_portal.data_shape_shape

SET fragment_meff_cbc = (
SELECT  fragment_meff_cbc
FROM niamoto_preprocess.emprises pe
WHERE pe.gid=id) 