package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.DocumentoSoporteEspecial;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object (DAO) para la gestión técnica y archivística de
 * microfilminas y fotografías digitalizadas (Soporte Especial) en SADU.
 */
public class SoporteEspecialDAO {

    /**
     * Registra un nuevo soporte especial vinculado a un documento existente.
     */
    public boolean registrarSoporte(DocumentoSoporteEspecial esp) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "INSERT INTO documento_soporte_especial " +
                         "(id_documento, tipo_soporte, rollo_caja, numero_fotograma, " +
                         " ruta_master_tiff, ruta_acceso_web, resolucion_dpi, profundidad_color, " +
                         " hash_sha256, texto_ocr, observaciones_conservacion) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setInt(1, esp.getIdDocumento());
            ps.setString(2, esp.getTipoSoporte());
            ps.setString(3, esp.getRolloCaja());
            ps.setString(4, esp.getNumeroFotograma());
            ps.setString(5, esp.getRutaMasterTiff());
            ps.setString(6, esp.getRutaAccesoWeb());
            ps.setInt(7, esp.getResolucionDpi());
            ps.setString(8, esp.getProfundidadColor());
            ps.setString(9, esp.getHashSha256());
            ps.setString(10, esp.getTextoOcr());
            ps.setString(11, esp.getObservacionesConservacion());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    /**
     * Obtiene los soportes especiales asociados a un documento específico.
     */
    public List<DocumentoSoporteEspecial> obtenerPorIdDocumento(int idDocumento) {
        List<DocumentoSoporteEspecial> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT s.*, d.codigo, d.nombre_documento " +
                         "FROM documento_soporte_especial s " +
                         "INNER JOIN documentos d ON s.id_documento = d.id_documento " +
                         "WHERE s.id_documento = ? " +
                         "ORDER BY s.id_soporte ASC";

            ps = con.prepareStatement(sql);
            ps.setInt(1, idDocumento);
            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearSoporte(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }
        return lista;
    }

    /**
     * Búsqueda por texto indexado mediante OCR.
     * Utiliza índice FULLTEXT si está disponible o búsqueda booleana con fallback LIKE.
     */
    public List<DocumentoSoporteEspecial> buscarPorOCR(String criterio) {
        List<DocumentoSoporteEspecial> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            // Primero intentamos búsqueda FULLTEXT con MATCH...AGAINST
            String sql = "SELECT s.*, d.codigo, d.nombre_documento " +
                         "FROM documento_soporte_especial s " +
                         "INNER JOIN documentos d ON s.id_documento = d.id_documento " +
                         "WHERE MATCH(s.texto_ocr) AGAINST(? IN BOOLEAN MODE) " +
                         "OR s.texto_ocr LIKE ? " +
                         "ORDER BY s.fecha_digitalizacion DESC LIMIT 50";

            ps = con.prepareStatement(sql);
            ps.setString(1, criterio + "*");
            ps.setString(2, "%" + criterio + "%");
            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearSoporte(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }
        return lista;
    }

    /**
     * Lista soportes por tipo específico o todos si es 'TODOS' o null.
     */
    public List<DocumentoSoporteEspecial> listarPorTipo(String tipoSoporte) {
        List<DocumentoSoporteEspecial> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql;
            if (tipoSoporte == null || tipoSoporte.trim().isEmpty() || "TODOS".equalsIgnoreCase(tipoSoporte.trim())) {
                sql = "SELECT s.*, d.codigo, d.nombre_documento " +
                      "FROM documento_soporte_especial s " +
                      "INNER JOIN documentos d ON s.id_documento = d.id_documento " +
                      "ORDER BY s.fecha_digitalizacion DESC";
                ps = con.prepareStatement(sql);
            } else {
                sql = "SELECT s.*, d.codigo, d.nombre_documento " +
                      "FROM documento_soporte_especial s " +
                      "INNER JOIN documentos d ON s.id_documento = d.id_documento " +
                      "WHERE s.tipo_soporte = ? " +
                      "ORDER BY s.fecha_digitalizacion DESC";
                ps = con.prepareStatement(sql);
                ps.setString(1, tipoSoporte.trim());
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearSoporte(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }
        return lista;
    }

    /**
     * Obtiene un soporte específico por su ID primario.
     */
    public DocumentoSoporteEspecial obtenerPorId(int idSoporte) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT s.*, d.codigo, d.nombre_documento " +
                         "FROM documento_soporte_especial s " +
                         "INNER JOIN documentos d ON s.id_documento = d.id_documento " +
                         "WHERE s.id_soporte = ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, idSoporte);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapearSoporte(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }
        return null;
    }

    /**
     * Actualiza los metadatos y el texto OCR de un soporte especial.
     */
    public boolean actualizarSoporte(DocumentoSoporteEspecial esp) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "UPDATE documento_soporte_especial SET " +
                         "tipo_soporte = ?, rollo_caja = ?, numero_fotograma = ?, " +
                         "ruta_master_tiff = ?, ruta_acceso_web = ?, resolucion_dpi = ?, " +
                         "profundidad_color = ?, hash_sha256 = ?, texto_ocr = ?, " +
                         "observaciones_conservacion = ? " +
                         "WHERE id_soporte = ?";

            ps = con.prepareStatement(sql);
            ps.setString(1, esp.getTipoSoporte());
            ps.setString(2, esp.getRolloCaja());
            ps.setString(3, esp.getNumeroFotograma());
            ps.setString(4, esp.getRutaMasterTiff());
            ps.setString(5, esp.getRutaAccesoWeb());
            ps.setInt(6, esp.getResolucionDpi());
            ps.setString(7, esp.getProfundidadColor());
            ps.setString(8, esp.getHashSha256());
            ps.setString(9, esp.getTextoOcr());
            ps.setString(10, esp.getObservacionesConservacion());
            ps.setInt(11, esp.getIdSoporte());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    /**
     * Elimina un registro de soporte especial.
     */
    public boolean eliminarSoporte(int idSoporte) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "DELETE FROM documento_soporte_especial WHERE id_soporte = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idSoporte);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    /**
     * Mapea un ResultSet a un objeto DocumentoSoporteEspecial.
     */
    private DocumentoSoporteEspecial mapearSoporte(ResultSet rs) throws Exception {
        DocumentoSoporteEspecial s = new DocumentoSoporteEspecial();
        s.setIdSoporte(rs.getInt("id_soporte"));
        s.setIdDocumento(rs.getInt("id_documento"));
        s.setTipoSoporte(rs.getString("tipo_soporte"));
        s.setRolloCaja(rs.getString("rollo_caja"));
        s.setNumeroFotograma(rs.getString("numero_fotograma"));
        s.setRutaMasterTiff(rs.getString("ruta_master_tiff"));
        s.setRutaAccesoWeb(rs.getString("ruta_acceso_web"));
        s.setResolucionDpi(rs.getInt("resolucion_dpi"));
        s.setProfundidadColor(rs.getString("profundidad_color"));
        s.setHashSha256(rs.getString("hash_sha256"));
        s.setTextoOcr(rs.getString("texto_ocr"));
        s.setObservacionesConservacion(rs.getString("observaciones_conservacion"));
        s.setFechaDigitalizacion(rs.getTimestamp("fecha_digitalizacion"));

        try {
            s.setCodigoDocumento(rs.getString("codigo"));
            s.setNombreDocumento(rs.getString("nombre_documento"));
        } catch (Exception ignored) {
            // Campos opcionales según el SELECT
        }

        return s;
    }

    private void cerrarRecursos(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception ignored) {}
        try { if (ps  != null) ps.close();  } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
}

