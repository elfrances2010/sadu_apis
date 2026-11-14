package com.sadu.modelo;

import java.sql.Timestamp;

/**
 * Modelo que representa el soporte especial de un documento en SADU:
 * Microfilminas, Fotografías, Negativos o Diapositivas.
 * Integra:
 *  1. Objeto visual digitalizado (Master TIFF + Acceso Web).
 *  2. Metadatos técnicos, descriptivos y de conservación analógica.
 *  3. Texto indexado por OCR para búsqueda de texto completo.
 */
public class DocumentoSoporteEspecial {

    private int idSoporte;
    private int idDocumento;
    private String tipoSoporte;               // MICROFILMINA, FOTOGRAFIA, NEGATIVO, DIAPOSITIVA
    private String rolloCaja;                 // Rollo o caja de archivo físico
    private String numeroFotograma;           // Número de fotograma o posición
    private String rutaMasterTiff;            // Archivo original sin pérdida (Master de preservación)
    private String rutaAccesoWeb;             // Archivo de visualización ligera (WebP/JPEG)
    private int resolucionDpi;                // DPI (ej. 300, 400, 600)
    private String profundidadColor;          // Grises 8-bit, Color 24-bit
    private String hashSha256;                // Hash de integridad del archivo
    private String textoOcr;                  // Texto extraído por OCR
    private String observacionesConservacion; // Estado físico del soporte original
    private Timestamp fechaDigitalizacion;    // Fecha de captura

    // Datos relacionales del documento asociado (opcionales al consultar)
    private String codigoDocumento;
    private String nombreDocumento;

    public DocumentoSoporteEspecial() {
        this.resolucionDpi = 300;
        this.profundidadColor = "Escala de grises (8-bit)";
    }

    // Getters y Setters
    public int getIdSoporte() {
        return idSoporte;
    }

    public void setIdSoporte(int idSoporte) {
        this.idSoporte = idSoporte;
    }

    public int getIdDocumento() {
        return idDocumento;
    }

    public void setIdDocumento(int idDocumento) {
        this.idDocumento = idDocumento;
    }

    public String getTipoSoporte() {
        return tipoSoporte;
    }

    public void setTipoSoporte(String tipoSoporte) {
        this.tipoSoporte = tipoSoporte;
    }

    public String getRolloCaja() {
        return rolloCaja;
    }

    public void setRolloCaja(String rolloCaja) {
        this.rolloCaja = rolloCaja;
    }

    public String getNumeroFotograma() {
        return numeroFotograma;
    }

    public void setNumeroFotograma(String numeroFotograma) {
        this.numeroFotograma = numeroFotograma;
    }

    public String getRutaMasterTiff() {
        return rutaMasterTiff;
    }

    public void setRutaMasterTiff(String rutaMasterTiff) {
        this.rutaMasterTiff = rutaMasterTiff;
    }

    public String getRutaAccesoWeb() {
        return rutaAccesoWeb;
    }

    public void setRutaAccesoWeb(String rutaAccesoWeb) {
        this.rutaAccesoWeb = rutaAccesoWeb;
    }

    public int getResolucionDpi() {
        return resolucionDpi;
    }

    public void setResolucionDpi(int resolucionDpi) {
        this.resolucionDpi = resolucionDpi;
    }

    public String getProfundidadColor() {
        return profundidadColor;
    }

    public void setProfundidadColor(String profundidadColor) {
        this.profundidadColor = profundidadColor;
    }

    public String getHashSha256() {
        return hashSha256;
    }

    public void setHashSha256(String hashSha256) {
        this.hashSha256 = hashSha256;
    }

    public String getTextoOcr() {
        return textoOcr;
    }

    public void setTextoOcr(String textoOcr) {
        this.textoOcr = textoOcr;
    }

    public String getObservacionesConservacion() {
        return observacionesConservacion;
    }

    public void setObservacionesConservacion(String observacionesConservacion) {
        this.observacionesConservacion = observacionesConservacion;
    }

    public Timestamp getFechaDigitalizacion() {
        return fechaDigitalizacion;
    }

    public void setFechaDigitalizacion(Timestamp fechaDigitalizacion) {
        this.fechaDigitalizacion = fechaDigitalizacion;
    }

    public String getCodigoDocumento() {
        return codigoDocumento;
    }

    public void setCodigoDocumento(String codigoDocumento) {
        this.codigoDocumento = codigoDocumento;
    }

    public String getNombreDocumento() {
        return nombreDocumento;
    }

    public void setNombreDocumento(String nombreDocumento) {
        this.nombreDocumento = nombreDocumento;
    }
}

