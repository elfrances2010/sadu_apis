package com.sadu.controller;

import com.google.gson.Gson;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

/**
 * Endpoint para la carga física de documentos digitales (PDF, TIFF, JPG, PNG).
 * Calcula automáticamente la huella digital (Checksum SHA-256) del archivo
 * para garantizar integridad probatoria y cumplimiento de la norma de preservación digital.
 */
@WebServlet(name = "SubirArchivoServlet", urlPatterns = {"/api/subir-archivo"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,        // 1 MB en memoria
    maxFileSize = 25 * 1024 * 1024,          // 25 MB máximo por archivo
    maxRequestSize = 30 * 1024 * 1024        // 30 MB petición total
)
public class SubirArchivoServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        PrintWriter out = response.getWriter();
        Map<String, Object> res = new HashMap<>();

        try {
            Part filePart = request.getPart("archivo");
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                res.put("ok", false);
                res.put("error", "No se recibió ningún archivo en la petición.");
                out.print(gson.toJson(res));
                return;
            }

            String nombreOriginal = getNombreArchivo(filePart);
            if (nombreOriginal == null || nombreOriginal.trim().isEmpty()) {
                nombreOriginal = "documento_" + System.currentTimeMillis();
            }

            // Sanitizar nombre de archivo
            String extension = "";
            int dotIdx = nombreOriginal.lastIndexOf(".");
            if (dotIdx > 0) {
                extension = nombreOriginal.substring(dotIdx).toLowerCase();
            }

            String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String nombreDestino = "DOC_" + timeStamp + "_" + (int)(Math.random() * 1000) + extension;

            // Carpeta de almacenamiento físico
            String uploadPath = getServletContext().getRealPath("/storage/docs");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            File archivoFinal = new File(uploadDir, nombreDestino);

            // Leer flujo de bytes, guardar y calcular SHA-256 simultáneamente
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            long totalBytes = 0;

            try (InputStream is = filePart.getInputStream();
                 FileOutputStream fos = new FileOutputStream(archivoFinal)) {

                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = is.read(buffer)) != -1) {
                    digest.update(buffer, 0, bytesRead);
                    fos.write(buffer, 0, bytesRead);
                    totalBytes += bytesRead;
                }
            }

            // Convertir hash a hexadecimal
            byte[] hashBytes = digest.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            String hashSha256 = sb.toString();

            String rutaRelativa = "storage/docs/" + nombreDestino;

            res.put("ok", true);
            res.put("rutaArchivo", rutaRelativa);
            res.put("nombreOriginal", nombreOriginal);
            res.put("tamanoBytes", totalBytes);
            res.put("tamanoLegible", formatearTamano(totalBytes));
            res.put("hashSha256", hashSha256);
            res.put("mimeType", filePart.getContentType());
            res.put("urlVisor", "ver-archivo?ruta=" + rutaRelativa);

            response.setStatus(HttpServletResponse.SC_OK);
            out.print(gson.toJson(res));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            res.put("ok", false);
            res.put("error", "Error interno al procesar el archivo: " + e.getMessage());
            out.print(gson.toJson(res));
        }
    }

    private String getNombreArchivo(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return null;
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                return new File(name).getName();
            }
        }
        return null;
    }

    private String formatearTamano(long bytes) {
        if (bytes < 1024) return bytes + " B";
        int exp = (int) (Math.log(bytes) / Math.log(1024));
        char pre = "KMGTPE".charAt(exp - 1);
        return String.format("%.1f %sB", bytes / Math.pow(1024, exp), pre);
    }
}

