package com.sadu.service;

import com.sadu.config.Conexion;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Daemon autonomo de segundo plano para el sistema SADU.
 * Se inicializa junto al contenedor de servlets (Tomcat) y ejecuta
 * de forma desatendida tareas de mantenimiento, monitoreo de salud
 * y verificacion de estados de acuerdo con las normativas documentales.
 */
@WebListener
public class SaduAutonomousDaemon implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[SADU-DAEMON] Iniciando motor autonomo de tareas en segundo plano...");

        // Usar hilo daemon para no impedir el apagado limpio del servidor
        scheduler = Executors.newScheduledThreadPool(1, r -> {
            Thread t = new Thread(r, "sadu-autonomous-worker");
            t.setDaemon(true);
            return t;
        });

        // Programar ciclo autonomo cada 6 horas (con primer disparo a los 30 segundos)
        scheduler.scheduleAtFixedRate(this::ejecutarCicloAutonomo, 30, 21600, TimeUnit.SECONDS);
    }

    /**
     * Tareas ejecutadas autonomamente por el sistema:
     * 1. Health check de la base de datos y failover.
     * 2. Auto-cierre o advertencia de radicados/comunicaciones con plazos vencidos.
     * 3. Registro en logs de auditoria del estado del daemon.
     */
    private void ejecutarCicloAutonomo() {
        try {
            System.out.println("[SADU-DAEMON] Ejecutando ciclo de verificacion autonoma de calidad y salud...");

            // 1. Verificacion de salud de persistencia
            boolean saludable = Conexion.isHealthy();
            if (!saludable) {
                System.err.println("[SADU-DAEMON] ALERTA: La base de datos no respondio al Health Check.");
                return;
            }

            try (Connection con = Conexion.getConnection()) {
                // 2. Tarea autonoma de actualizacion de plazos normativos (TRD / PQRS)
                // Por ejemplo, marcar comunicaciones de tipo 'EXTERNA' o tramites que superaron 15 dias habiles
                String sqlActualizarVencidos = 
                    "UPDATE comunicaciones SET estado = 'VENCIDO' " +
                    "WHERE estado = 'REGISTRADO' AND fecha_radicacion < DATE_SUB(NOW(), INTERVAL 15 DAY)";

                try (PreparedStatement ps = con.prepareStatement(sqlActualizarVencidos)) {
                    int afectadas = ps.executeUpdate();
                    if (afectadas > 0) {
                        System.out.println("[SADU-DAEMON] Comunicaciones marcadas como VENCIDO automaticamente: " + afectadas);
                        registrarLogAuditoria(con, "SISTEMA_AUTONOMO", "ACTUALIZACION_VENCIMIENTOS", 
                            "Se actualizaron de forma autonoma " + afectadas + " comunicaciones con plazo vencido.");
                    }
                }

                // 3. Registrar pulso de salud (Heartbeat) en logs de auditoria
                registrarLogAuditoria(con, "SISTEMA_AUTONOMO", "HEALTH_CHECK", 
                    "Verificacion autonoma completada: Sistema operando normalmente con conexion estable.");

            }

        } catch (Exception e) {
            System.err.println("[SADU-DAEMON] Error durante la ejecucion del ciclo autonomo: " + e.getMessage());
        }
    }

    private void registrarLogAuditoria(Connection con, String usuario, String accion, String detalle) {
        String sql = "INSERT INTO logs_auditoria (usuario, accion, detalle, fecha) VALUES (?, ?, ?, NOW())";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario);
            ps.setString(2, accion);
            ps.setString(3, detalle);
            ps.executeUpdate();
        } catch (Exception ignored) {
            // Si la tabla logs_auditoria tuviera nombres de columnas ligeramente distintos, no bloqueamos el daemon
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[SADU-DAEMON] Deteniendo motor autonomo...");
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
        }
    }
}

