package com.sadu.util;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Gestor de presencia y estado de escritura ("Escribiendo...")
 * para el Chat Empresarial SADU estilo ICQ.
 */
public class UserPresenceManager {

    private static final Map<Integer, Long> heartbeats = new ConcurrentHashMap<>();
    private static final Map<Integer, Long> typingStatus = new ConcurrentHashMap<>();

    private static final long ONLINE_THRESHOLD_MS = 15000;
    private static final long TYPING_THRESHOLD_MS = 4000;

    public static void registrarHeartbeat(int idUsuario) {
        if (idUsuario > 0) {
            heartbeats.put(idUsuario, System.currentTimeMillis());
        }
    }

    public static void registrarEscritura(int idUsuario) {
        if (idUsuario > 0) {
            long ahora = System.currentTimeMillis();
            typingStatus.put(idUsuario, ahora);
            heartbeats.put(idUsuario, ahora);
        }
    }

    public static boolean isOnline(int idUsuario) {
        Long ultimo = heartbeats.get(idUsuario);
        if (ultimo == null) return false;
        return (System.currentTimeMillis() - ultimo) < ONLINE_THRESHOLD_MS;
    }

    public static boolean isTyping(int idUsuario) {
        Long ultimo = typingStatus.get(idUsuario);
        if (ultimo == null) return false;
        return (System.currentTimeMillis() - ultimo) < TYPING_THRESHOLD_MS;
    }
}