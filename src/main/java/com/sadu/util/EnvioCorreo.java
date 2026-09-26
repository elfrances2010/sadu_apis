package com.sadu.util;

import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

/**
 * Clase utilitaria para el envío de correos electrónicos desde SADU
 * utilizando Gmail SMTP con autenticación TLS segura.
 */
public class EnvioCorreo {

    // ─────────────────────────────────────────────────────────────
    // ⚠️ COLOCA AQUÍ TUS DATOS DE GMAIL:
    // ─────────────────────────────────────────────────────────────
    private static final String REMITENTE = "tu_correo@gmail.com";          // ← Tu correo Gmail real
    private static final String CLAVE     = "abcd efgh ijkl mnop";          // ← Tu clave de 16 letras de Google
    // ─────────────────────────────────────────────────────────────

    /**
     * Envía el correo con el código de 6 dígitos para recuperar contraseña.
     *
     * @param destinatario Correo del usuario
     * @param nombreUsuario Nombre completo del usuario
     * @param codigo Código de 6 dígitos generado
     * @return true si el correo se envió con éxito, false si falló
     */
    public static boolean enviarCodigoRecuperacion(String destinatario, String nombreUsuario, String codigo) {
        try {
            // 1. Configuración de propiedades del servidor SMTP de Gmail
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

            // 2. Autenticación con el correo y la clave de aplicación
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(REMITENTE, CLAVE.replace(" ", ""));
                }
            });

            // 3. Crear el mensaje de correo
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(REMITENTE, "SADU - Sistema de Información"));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(destinatario));
            message.setSubject("Código de Recuperación de Contraseña - SADU", "UTF-8");

            // 4. Cuerpo del correo en formato HTML atractivo
            String cuerpoHtml = "<div style='font-family: Arial, sans-serif; max-width: 500px; margin: auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 10px;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "<h2 style='color: #1e3a8a; margin: 0;'>🔐 SADU Sistema Web</h2>"
                    + "<p style='color: #64748b; font-size: 14px;'>Recuperación de Acceso</p>"
                    + "</div>"
                    + "<p style='color: #334155; font-size: 15px;'>Hola <b>" + nombreUsuario + "</b>,</p>"
                    + "<p style='color: #334155; font-size: 14px;'>Has solicitado restablecer tu contraseña. Utiliza el siguiente código de seguridad:</p>"
                    + "<div style='background-color: #f1f5f9; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0;'>"
                    + "<span style='font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #1e293b;'>" + codigo + "</span>"
                    + "</div>"
                    + "<p style='color: #dc2626; font-size: 13px;'>⚠️ Este código expira en 15 minutos.</p>"
                    + "<p style='color: #64748b; font-size: 12px; margin-top: 30px; border-top: 1px solid #cbd5e1; padding-top: 10px;'>Si no solicitaste este cambio, puedes ignorar este mensaje.</p>"
                    + "</div>";

            message.setContent(cuerpoHtml, "text/html; charset=utf-8");

            // 5. Enviar el mensaje
            Transport.send(message);
            System.out.println("✅ CORREO ENVIADO CON ÉXITO A: " + destinatario);
            return true;

        } catch (Exception e) {
            System.err.println("❌ ERROR AL ENVIAR CORREO: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}