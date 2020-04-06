 update niamoto_portal.data_shape_shape

SET fragment_meff_cbc = (
SELECT  fragment_meff_cbc
FROM atlas_pn.pn_emprises pe
WHERE pe.gid=id) 