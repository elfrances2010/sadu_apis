package com.sadu.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;

/**
 * Servicio encargado de la gestion de almacenamiento documental redundante
 * con verificacion de integridad mediante hash SHA-256 y auto-recuperacion.
 */
public class AlmacenamientoRedundanteService {

    private final String directorioPrimario;
    private final String directorioEspejo;

    public AlmacenamientoRedundanteService(String rutaBase) {
        this.directorioPrimario = rutaBase + File.separator + "documentos";
        this.directorioEspejo   = rutaBase + File.separator + "backups_espejo" + File.separator + "documentos";

        // Asegurar que existan los directorios
        File fPrimario = new File(directorioPrimario);
        if (!fPrimario.exists()) fPrimario.mkdirs();

        File fEspejo = new File(directorioEspejo);
        if (!fEspejo.exists()) fEspejo.mkdirs();
    }

    /**
     * Calcula la firma SHA-256 de un flujo de bytes para garantizar integridad.
     */
    public static String calcularSHA256(File archivo) throws Exception {
        if (!archivo.exists()) return null;
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        try (InputStream fis = new FileInputStream(archivo)) {
            byte[] byteArray = new byte[8192];
            int bytesCount;
            while ((bytesCount = fis.read(byteArray)) != -1) {
                digest.update(byteArray, 0, bytesCount);
            }
        }
        byte[] bytes = digest.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    /**
     * Guarda un archivo de forma redundante (primario y replica espejo)
     * retornando el hash SHA-256 calculado.
     */
    public String guardarDocumentoRedundante(String nombreArchivo, InputStream contenido) throws Exception {
        File destinoPrimario = new File(directorioPrimario, nombreArchivo);
        File destinoEspejo = new File(directorioEspejo, nombreArchivo);

        // 1. Guardar en destino primario
        Files.copy(contenido, destinoPrimario.toPath(), StandardCopyOption.REPLACE_EXISTING);

        // 2. Calcular Hash SHA-256 del primario
        String hashPrimario = calcularSHA256(destinoPrimario);

        // 3. Replicar al destino espejo
        Files.copy(destinoPrimario.toPath(), destinoEspejo.toPath(), StandardCopyOption.REPLACE_EXISTING);

        // 4. Validar integridad de la replica
        String hashEspejo = calcularSHA256(destinoEspejo);
        if (!hashPrimario.equals(hashEspejo)) {
            throw new Exception("Fallo de integridad: El hash de la réplica espejo no coincide con el primario.");
        }

        return hashPrimario;
    }

    /**
     * Mecanismo de auto-recuperacion (Self-Healing):
     * Si el archivo primario se dana o desaparece, se restaura desde la replica espejo.
     */
    public File obtenerArchivoConAutocura(String nombreArchivo) {
        File fPri = new File(directorioPrimario, nombreArchivo);
        File fEsp = new File(directorioEspejo, nombreArchivo);

        if (fPri.exists() && fPri.length() > 0) {
            return fPri;
        }

        // Si el primario no existe o esta vacio, restaurar desde la replica
        if (fEsp.exists() && fEsp.length() > 0) {
            try {
                System.out.println("[SADU-SELF-HEALING] Restaurando archivo danado desde replica: " + nombreArchivo);
                Files.copy(fEsp.toPath(), fPri.toPath(), StandardCopyOption.REPLACE_EXISTING);
                return fPri;
            } catch (Exception e) {
                System.err.println("[SADU-SELF-HEALING] Error al restaurar: " + e.getMessage());
                return fEsp;
            }
        }

        return null;
    }
}

