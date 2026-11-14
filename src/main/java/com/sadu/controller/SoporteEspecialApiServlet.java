package com.sadu.controller;

import com.sadu.dao.SoporteEspecialDAO;
import com.sadu.modelo.DocumentoSoporteEspecial;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * API REST para la gestión de soportes especiales:
 * Microfilminas, Fotografías y búsqueda de texto indexado por OCR.
 *
 * ENDPOINTS:
 *   GET    /api/soporte-especial?ocr=acta         → Búsqueda por texto OCR indexado
 *   GET    /api/soporte-especial?idDocumento=1    → Listar soportes vinculados a un documento
 *   GET    /api/soporte-especial?tipo=MICROFILMINA→ Listar por tipo (MICROFILMINA, FOTOGRAFIA, etc.)
 *   GET    /api/soporte-especial?id=1             → Obtener detalle de un soporte por ID
 *   POST   /api/soporte-especial                  → Crear nuevo registro (Body JSON)
 *   PUT    /api/soporte-especial?id=1             → Actualizar metadatos u OCR (Body JSON)
 *   DELETE /api/soporte-especial?id=1             → Eliminar registro
 */
@WebServlet(name = "SoporteEspecialApiServlet", urlPatterns = {"/api/soporte-especial"})
public class SoporteEspecialApiServlet extends HttpServlet {

    private final SoporteEspecialDAO dao = new SoporteEspecialDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        String ocrQuery    = request.getParameter("ocr");
        String idDocParam  = request.getParameter("idDocumento");
        String tipoParam   = request.getParameter("tipo");
        String idParam     = request.getParameter("id");

        try {
            // 1. Búsqueda por texto OCR
            if (ocrQuery != null && !ocrQuery.trim().isEmpty()) {
                List<DocumentoSoporteEspecial> lista = dao.buscarPorOCR(ocrQuery.trim());
                out.print(listaToJson(lista));
                return;
            }

            // 2. Consulta por ID específico de soporte
            if (idParam != null && !idParam.trim().isEmpty()) {
                int idSoporte = Integer.parseInt(idParam.trim());
                DocumentoSoporteEspecial s = dao.obtenerPorId(idSoporte);
                if (s != null) {
                    out.print(soporteToJson(s));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Soporte especial no encontrado con ID: " + idSoporte + "\"}");
                }
                return;
            }

            // 3. Consulta por Documento
            if (idDocParam != null && !idDocParam.trim().isEmpty()) {
                int idDocumento = Integer.parseInt(idDocParam.trim());
                List<DocumentoSoporteEspecial> lista = dao.obtenerPorIdDocumento(idDocumento);
                out.print(listaToJson(lista));
                return;
            }

            // 4. Consulta por Tipo de Soporte
            if (tipoParam != null && !tipoParam.trim().isEmpty()) {
                List<DocumentoSoporteEspecial> lista = dao.listarPorTipo(tipoParam.trim().toUpperCase());
                out.print(listaToJson(lista));
                return;
            }

            // Por defecto: listar todos los soportes
            List<DocumentoSoporteEspecial> lista = dao.listarPorTipo("TODOS");
            out.print(listaToJson(lista));

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"ID inválido. Debe ser un número entero.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Error interno al procesar consulta: " + esc(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        try {
            String body = leerBody(request);
            if (estaVacio(body)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"El cuerpo JSON de la petición no puede estar vacío\"}");
                return;
            }

            String idDocStr        = extraerCampo(body, "idDocumento");
            String tipoSoporte     = extraerCampo(body, "tipoSoporte");
            String rolloCaja       = extraerCampo(body, "rolloCaja");
            String numeroFotograma = extraerCampo(body, "numeroFotograma");
            String rutaMasterTiff  = extraerCampo(body, "rutaMasterTiff");
            String rutaAccesoWeb   = extraerCampo(body, "rutaAccesoWeb");
            String resolucionStr   = extraerCampo(body, "resolucionDpi");
            String profundidad     = extraerCampo(body, "profundidadColor");
            String hashSha256      = extraerCampo(body, "hashSha256");
            String textoOcr        = extraerCampo(body, "textoOcr");
            String observaciones   = extraerCampo(body, "observacionesConservacion");

            if (estaVacio(idDocStr) || estaVacio(tipoSoporte) || estaVacio(rutaAccesoWeb)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Campos obligatorios requeridos: idDocumento, tipoSoporte, rutaAccesoWeb\"}");
                return;
            }

            DocumentoSoporteEspecial esp = new DocumentoSoporteEspecial();
            esp.setIdDocumento(Integer.parseInt(idDocStr.trim()));
            esp.setTipoSoporte(tipoSoporte.trim().toUpperCase());
            esp.setRolloCaja(rolloCaja);
            esp.setNumeroFotograma(numeroFotograma);
            esp.setRutaMasterTiff(rutaMasterTiff);
            esp.setRutaAccesoWeb(rutaAccesoWeb);
            esp.setResolucionDpi(!estaVacio(resolucionStr) ? Integer.parseInt(resolucionStr.trim()) : 300);
            esp.setProfundidadColor(!estaVacio(profundidad) ? profundidad : "Escala de grises (8-bit)");
            esp.setHashSha256(hashSha256);
            esp.setTextoOcr(textoOcr);
            esp.setObservacionesConservacion(observaciones);

            boolean exito = dao.registrarSoporte(esp);

            if (exito) {
                response.setStatus(HttpServletResponse.SC_CREATED);
                out.print("{\"mensaje\":\"Soporte especial (Microfilmina/Foto) registrado exitosamente\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"No se pudo registrar el soporte en la base de datos\"}");
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Error al crear soporte: " + esc(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");
        if (estaVacio(idParam)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Debe proporcionar el parámetro ?id=ID para actualizar\"}");
            return;
        }

        try {
            int idSoporte = Integer.parseInt(idParam.trim());
            DocumentoSoporteEspecial existente = dao.obtenerPorId(idSoporte);

            if (existente == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"No existe soporte con ID: " + idSoporte + "\"}");
                return;
            }

            String body = leerBody(request);
            String tipoSoporte     = extraerCampo(body, "tipoSoporte");
            String rolloCaja       = extraerCampo(body, "rolloCaja");
            String numeroFotograma = extraerCampo(body, "numeroFotograma");
            String rutaMasterTiff  = extraerCampo(body, "rutaMasterTiff");
            String rutaAccesoWeb   = extraerCampo(body, "rutaAccesoWeb");
            String resolucionStr   = extraerCampo(body, "resolucionDpi");
            String profundidad     = extraerCampo(body, "profundidadColor");
            String hashSha256      = extraerCampo(body, "hashSha256");
            String textoOcr        = extraerCampo(body, "textoOcr");
            String observaciones   = extraerCampo(body, "observacionesConservacion");

            if (!estaVacio(tipoSoporte))     existente.setTipoSoporte(tipoSoporte.trim().toUpperCase());
            if (rolloCaja != null)           existente.setRolloCaja(rolloCaja);
            if (numeroFotograma != null)     existente.setNumeroFotograma(numeroFotograma);
            if (rutaMasterTiff != null)      existente.setRutaMasterTiff(rutaMasterTiff);
            if (!estaVacio(rutaAccesoWeb))   existente.setRutaAccesoWeb(rutaAccesoWeb);
            if (!estaVacio(resolucionStr))   existente.setResolucionDpi(Integer.parseInt(resolucionStr.trim()));
            if (!estaVacio(profundidad))     existente.setProfundidadColor(profundidad);
            if (hashSha256 != null)          existente.setHashSha256(hashSha256);
            if (textoOcr != null)            existente.setTextoOcr(textoOcr);
            if (observaciones != null)       existente.setObservacionesConservacion(observaciones);

            boolean exito = dao.actualizarSoporte(existente);

            if (exito) {
                out.print("{\"mensaje\":\"Soporte especial actualizado exitosamente\", \"idSoporte\":" + idSoporte + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"No se pudo actualizar el registro en la base de datos\"}");
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"El parámetro id debe ser un número entero válido\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Error al actualizar: " + esc(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");
        if (estaVacio(idParam)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Debe proporcionar el parámetro ?id=ID para eliminar\"}");
            return;
        }

        try {
            int idSoporte = Integer.parseInt(idParam.trim());
            boolean exito = dao.eliminarSoporte(idSoporte);

            if (exito) {
                out.print("{\"mensaje\":\"Soporte especial eliminado correctamente\", \"idSoporte\":" + idSoporte + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"No se encontró el registro o no pudo ser eliminado\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"El parámetro id debe ser un número entero válido\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Error al eliminar soporte: " + esc(e.getMessage()) + "\"}");
        }
    }

    // ────────────────────────────────────────────────────────────
    // MÉTODOS AUXILIARES JSON Y FORMATO
    // ────────────────────────────────────────────────────────────

    private void configurarRespuestaJson(HttpServletResponse response) {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
    }

    private String listaToJson(List<DocumentoSoporteEspecial> lista) {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < lista.size(); i++) {
            sb.append(soporteToJson(lista.get(i)));
            if (i < lista.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    private String soporteToJson(DocumentoSoporteEspecial s) {
        return "{" +
            "\"idSoporte\":"                 + s.getIdSoporte()                                + "," +
            "\"idDocumento\":"               + s.getIdDocumento()                              + "," +
            "\"codigoDocumento\":\""         + esc(s.getCodigoDocumento())                     + "\"," +
            "\"nombreDocumento\":\""         + esc(s.getNombreDocumento())                     + "\"," +
            "\"tipoSoporte\":\""             + esc(s.getTipoSoporte())                         + "\"," +
            "\"rolloCaja\":\""               + esc(s.getRolloCaja())                           + "\"," +
            "\"numeroFotograma\":\""         + esc(s.getNumeroFotograma())                     + "\"," +
            "\"rutaMasterTiff\":\""          + esc(s.getRutaMasterTiff())                      + "\"," +
            "\"rutaAccesoWeb\":\""           + esc(s.getRutaAccesoWeb())                       + "\"," +
            "\"resolucionDpi\":"             + s.getResolucionDpi()                            + "," +
            "\"profundidadColor\":\""        + esc(s.getProfundidadColor())                    + "\"," +
            "\"hashSha256\":\""              + esc(s.getHashSha256())                          + "\"," +
            "\"textoOcr\":\""                + esc(s.getTextoOcr())                            + "\"," +
            "\"observacionesConservacion\":\""+ esc(s.getObservacionesConservacion())          + "\"," +
            "\"fechaDigitalizacion\":\""     + (s.getFechaDigitalizacion() != null ? s.getFechaDigitalizacion().toString() : "") + "\"" +
        "}";
    }

    private String leerBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        String linea;
        java.io.BufferedReader reader = request.getReader();
        while ((linea = reader.readLine()) != null) sb.append(linea);
        return sb.toString();
    }

    private String extraerCampo(String json, String campo) {
        if (json == null || campo == null) return null;
        String clave = "\"" + campo + "\"";
        int idx = json.indexOf(clave);
        if (idx < 0) return null;

        int dospuntos = json.indexOf(":", idx + clave.length());
        if (dospuntos < 0) return null;

        int inicio = dospuntos + 1;
        while (inicio < json.length() && json.charAt(inicio) == ' ') inicio++;
        if (inicio >= json.length()) return null;

        if (json.charAt(inicio) == '"') {
            int fin = json.indexOf('"', inicio + 1);
            if (fin < 0) return null;
            return json.substring(inicio + 1, fin);
        } else {
            int fin = inicio;
            while (fin < json.length() && json.charAt(fin) != ',' && json.charAt(fin) != '}') fin++;
            return json.substring(inicio, fin).trim();
        }
    }

    private boolean estaVacio(String valor) {
        return valor == null || valor.trim().isEmpty();
    }

    private String esc(String texto) {
        if (texto == null) return "";
        return texto
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
    }
}

