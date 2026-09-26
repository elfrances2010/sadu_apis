package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.Documento;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Clase DAO que maneja todas las operaciones de base de datos
 * relacionadas con la tabla documentos del sistema SADU.
 *
 * Operaciones disponibles:
 *   registrarDocumento()      → INSERT de un nuevo documento
 *   listarDocumentos()        → SELECT todos los documentos con nombre de usuario
 *   buscarDocumentos()        → SELECT con filtros por nombre, tipo, dependencia y estado
 *   listarArchivados()        → SELECT solo documentos con estado ARCHIVADO
 *   buscarPorCodigoOQr()      → SELECT por código exacto o código QR (consulta rápida)
 *   existeCodigo()            → Verifica si un código ya está registrado
 *   generarCodigo()           → Genera un código único automático (DOC-AÑO-SECUENCIA)
 */
public class DocumentoDAO {

    /**
     * Registra un nuevo documento en la base de datos.
     *
     * @param doc Objeto Documento con todos los datos a insertar
     * @return true si se insertó correctamente, false si ocurrió un error
     */
    public boolean registrarDocumento(Documento doc) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "INSERT INTO documentos " +
                         "(codigo, nombre_documento, tipo_documento, dependencia, " +
                         " fecha_documento, ruta_archivo, qr_codigo, trd, estado, id_usuario) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, doc.getCodigo());
            ps.setString(2, doc.getNombreDocumento());
            ps.setString(3, doc.getTipoDocumento());
            ps.setString(4, doc.getDependencia());
            ps.setDate(5,   doc.getFechaDocumento());
            ps.setString(6, doc.getRutaArchivo());
            ps.setString(7, doc.getQrCodigo());
            ps.setString(8, doc.getTrd());
            ps.setString(9, doc.getEstado());
            ps.setInt(10,   doc.getIdUsuario());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    /**
     * Lista todos los documentos registrados en el sistema,
     * incluyendo el nombre completo del usuario que lo registró (JOIN).
     * Ordenados del más reciente al más antiguo.
     *
     * @return Lista de objetos Documento con todos sus datos
     */
    public List<Documento> listarDocumentos() {
        List<Documento> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            String sql = "SELECT d.id_documento, d.codigo, d.nombre_documento, " +
                         "       d.tipo_documento, d.dependencia, d.fecha_documento, " +
                         "       d.ruta_archivo, d.qr_codigo, d.trd, d.estado, " +
                         "       d.id_usuario, u.nombre_completo, d.fecha_registro " +
                         "FROM documentos d " +
                         "INNER JOIN usuarios u ON d.id_usuario = u.id_usuario " +
                         "ORDER BY d.fecha_registro DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearDocumento(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * Busca documentos aplicando filtros combinados.
     * Los campos vacíos o nulos se ignoran en la búsqueda.
     *
     * @param nombre      Texto a buscar en el nombre del documento (búsqueda parcial)
     * @param tipo        Tipo de documento exacto (puede ser vacío)
     * @param dependencia Dependencia exacta (puede ser vacía)
     * @param estado      Estado del documento (puede ser vacío)
     * @return Lista de documentos que coinciden con los filtros
     */
    public List<Documento> buscarDocumentos(
            String nombre,
            String tipo,
            String dependencia,
            String estado) {

        List<Documento> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            StringBuilder sql = new StringBuilder(
                "SELECT d.id_documento, d.codigo, d.nombre_documento, " +
                "       d.tipo_documento, d.dependencia, d.fecha_documento, " +
                "       d.ruta_archivo, d.qr_codigo, d.trd, d.estado, " +
                "       d.id_usuario, u.nombre_completo, d.fecha_registro " +
                "FROM documentos d " +
                "INNER JOIN usuarios u ON d.id_usuario = u.id_usuario " +
                "WHERE 1=1 "
            );

            List<Object> parametros = new ArrayList<>();

            if (nombre != null && !nombre.trim().isEmpty()) {
                sql.append("AND d.nombre_documento LIKE ? ");
                parametros.add("%" + nombre.trim() + "%");
            }

            if (tipo != null && !tipo.trim().isEmpty()) {
                sql.append("AND d.tipo_documento = ? ");
                parametros.add(tipo.trim());
            }

            if (dependencia != null && !dependencia.trim().isEmpty()) {
                sql.append("AND d.dependencia = ? ");
                parametros.add(dependencia.trim());
            }

            if (estado != null && !estado.trim().isEmpty()) {
                sql.append("AND d.estado = ? ");
                parametros.add(estado.trim());
            }

            sql.append("ORDER BY d.fecha_registro DESC");

            ps = con.prepareStatement(sql.toString());

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearDocumento(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * ════════════════════════════════════════════════════════════
     * NUEVO MÉTODO — Lista únicamente los documentos con estado ARCHIVADO.
     * Usado por la página documentos_registrados.jsp, que es una vista
     * de SOLO CONSULTA de documentos ya finalizados/archivados.
     * ════════════════════════════════════════════════════════════
     *
     * @return Lista de documentos archivados, ordenados del más reciente al más antiguo
     */
    public List<Documento> listarArchivados() {
        List<Documento> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            String sql = "SELECT d.id_documento, d.codigo, d.nombre_documento, " +
                         "       d.tipo_documento, d.dependencia, d.fecha_documento, " +
                         "       d.ruta_archivo, d.qr_codigo, d.trd, d.estado, " +
                         "       d.id_usuario, u.nombre_completo, d.fecha_registro " +
                         "FROM documentos d " +
                         "INNER JOIN usuarios u ON d.id_usuario = u.id_usuario " +
                         "WHERE d.estado = 'ARCHIVADO' " +
                         "ORDER BY d.fecha_registro DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearDocumento(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * ════════════════════════════════════════════════════════════
     * NUEVO MÉTODO — Búsqueda rápida por código exacto o código QR.
     * Permite a cualquier funcionario verificar un documento sin
     * pasar por el formulario completo de gestión.
     * ════════════════════════════════════════════════════════════
     *
     * Busca coincidencia en AMBOS campos (codigo o qr_codigo),
     * sin importar mayúsculas/minúsculas, sin filtrar por estado
     * (encuentra el documento esté REGISTRADO, EN_PROCESO o ARCHIVADO).
     *
     * @param texto Código o código QR a buscar (ej: "DOC-2025-001" o "QR-DOC-2025-001")
     * @return Lista de documentos que coinciden (normalmente 0 o 1 resultado)
     */
    public List<Documento> buscarPorCodigoOQr(String texto) {
        List<Documento> lista = new ArrayList<>();

        // Si no se envía texto, retornar lista vacía sin consultar la BD
        if (texto == null || texto.trim().isEmpty()) {
            return lista;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            // UPPER() en ambos lados para que la búsqueda no distinga mayúsculas/minúsculas
            String sql = "SELECT d.id_documento, d.codigo, d.nombre_documento, " +
                         "       d.tipo_documento, d.dependencia, d.fecha_documento, " +
                         "       d.ruta_archivo, d.qr_codigo, d.trd, d.estado, " +
                         "       d.id_usuario, u.nombre_completo, d.fecha_registro " +
                         "FROM documentos d " +
                         "INNER JOIN usuarios u ON d.id_usuario = u.id_usuario " +
                         "WHERE UPPER(d.codigo) = UPPER(?) " +
                         "   OR UPPER(d.qr_codigo) = UPPER(?) " +
                         "ORDER BY d.fecha_registro DESC";

            ps = con.prepareStatement(sql);
            String textoLimpio = texto.trim();
            ps.setString(1, textoLimpio);
            ps.setString(2, textoLimpio);

            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearDocumento(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * Verifica si un código de documento ya existe en la base de datos.
     * Se usa antes de registrar para evitar duplicados.
     *
     * @param codigo Código a verificar
     * @return true si el código ya existe, false si está disponible
     */
    public boolean existeCodigo(String codigo) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT COUNT(*) FROM documentos WHERE codigo = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, codigo);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return false;
    }

    /**
     * Genera automáticamente un código único para el documento
     * con el formato: DOC-AÑO-SECUENCIA
     * Ejemplo: DOC-2025-001, DOC-2025-002, DOC-2025-015
     *
     * @return Código único generado
     */
    public String generarCodigo() {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            int anio = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

            String sql = "SELECT COUNT(*) FROM documentos " +
                         "WHERE YEAR(fecha_registro) = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, anio);
            rs = ps.executeQuery();

            int secuencia = 1;
            if (rs.next()) {
                secuencia = rs.getInt(1) + 1;
            }

            return String.format("DOC-%d-%03d", anio, secuencia);

        } catch (Exception e) {
            e.printStackTrace();
            return "DOC-" + System.currentTimeMillis();
        } finally {
            cerrarRecursos(rs, ps, con);
        }
    }

    /**
     * Mapea una fila del ResultSet a un objeto Documento.
     * Centraliza la lógica de mapeo para no repetirla en cada método.
     *
     * @param rs ResultSet posicionado en la fila actual
     * @return Objeto Documento con los datos de la fila
     */
    private Documento mapearDocumento(ResultSet rs) throws Exception {
        Documento doc = new Documento();
        doc.setIdDocumento(rs.getInt("id_documento"));
        doc.setCodigo(rs.getString("codigo"));
        doc.setNombreDocumento(rs.getString("nombre_documento"));
        doc.setTipoDocumento(rs.getString("tipo_documento"));
        doc.setDependencia(rs.getString("dependencia"));
        doc.setFechaDocumento(rs.getDate("fecha_documento"));
        doc.setRutaArchivo(rs.getString("ruta_archivo"));
        doc.setQrCodigo(rs.getString("qr_codigo"));
        doc.setTrd(rs.getString("trd"));
        doc.setEstado(rs.getString("estado"));
        doc.setIdUsuario(rs.getInt("id_usuario"));
        doc.setNombreUsuario(rs.getString("nombre_completo"));
        doc.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        return doc;
    }

    /**
     * Cierra los recursos de base de datos de forma segura.
     * Se llama siempre en el bloque finally para evitar fugas de conexión.
     */
    private void cerrarRecursos(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (ps  != null) ps.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
    }
}