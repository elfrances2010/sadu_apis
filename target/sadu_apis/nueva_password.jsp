<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    // Verificar que el usuario pasó por la verificación del código
    HttpSession sesion = request.getSession(false);
    if (sesion == null || !Boolean.TRUE.equals(sesion.getAttribute("recuperacion_verificado"))) {
        response.sendRedirect("recuperar_password.jsp");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva Contraseña - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            margin: 0;
            background: linear-gradient(135deg, #1f3b57 0%, #2f5579 50%, #1b4332 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: Arial, sans-serif;
        }

        .caja {
            background: white;
            border-radius: 18px;
            padding: 40px 44px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }

        .logo {
            text-align: center;
            margin-bottom: 24px;
        }

        .logo .icono { font-size: 52px; display: block; margin-bottom: 8px; }
        .logo h2 { color: #1f3b57; font-size: 24px; font-weight: bold; margin: 0; }
        .logo p { color: #9ca3af; font-size: 13px; margin: 6px 0 0; }

        label {
            font-size: 13px;
            font-weight: bold;
            color: #374151;
            display: block;
            margin-bottom: 6px;
        }

        input[type="password"] {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            box-sizing: border-box;
            margin-bottom: 6px;
            transition: border-color 0.25s;
        }

        input[type="password"]:focus {
            border-color: #1f3b57;
            box-shadow: 0 0 6px rgba(31,59,87,0.2);
        }

        .fortaleza-barra {
            height: 4px;
            border-radius: 4px;
            background-color: #e2e8f0;
            margin-bottom: 16px;
            overflow: hidden;
        }

        .fortaleza-relleno {
            height: 100%;
            border-radius: 4px;
            transition: width 0.4s, background-color 0.4s;
            width: 0%;
        }

        .ayuda {
            font-size: 12px;
            color: #9ca3af;
            margin-bottom: 16px;
        }

        /* Indicador visual de coincidencia de contraseñas */
        .coincidencia {
            font-size: 12px;
            margin-bottom: 20px;
            height: 16px;
        }

        .coincidencia.ok { color: #10b981; }
        .coincidencia.no { color: #ef4444; }

        .btn-guardar {
            width: 100%;
            background-color: #2d6a4f;
            color: white;
            border: none;
            padding: 13px;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-bottom: 14px;
        }

        .btn-guardar:hover { background-color: #1b4332; }

        .alerta-error {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fca5a5;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 13px;
            margin-bottom: 18px;
        }

        .pasos {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-bottom: 24px;
        }

        .paso { width: 32px; height: 6px; border-radius: 4px; background-color: #e2e8f0; }
        .paso.activo { background-color: #1f3b57; }
        .paso.completado { background-color: #10b981; }
    </style>
</head>
<body>

<div class="caja">

    <div class="logo">
        <span class="icono">🔑</span>
        <h2>Nueva contraseña</h2>
        <p>Establece tu nueva contraseña de acceso</p>
    </div>

    <!-- Indicador de pasos: paso 3 de 3 -->
    <div class="pasos">
        <div class="paso completado"></div>
        <div class="paso completado"></div>
        <div class="paso activo"></div>
    </div>

    <%-- Alerta de error --%>
    <% if (error != null) { %>
        <div class="alerta-error">⚠️ <%= error %></div>
    <% } %>

    <!--
        Formulario paso 3: nueva contraseña.
        Envía por POST al NuevaPasswordServlet.
    -->
    <form action="nuevaPassword" method="post" onsubmit="return validar()">

        <label for="nuevaPassword">Nueva contraseña</label>
        <input
            type="password"
            id="nuevaPassword"
            name="nuevaPassword"
            placeholder="Mínimo 6 caracteres"
            minlength="6"
            required
            oninput="evaluarFortaleza(this.value); verificarCoincidencia()"
        >
        <!-- Barra de fortaleza -->
        <div class="fortaleza-barra">
            <div class="fortaleza-relleno" id="fortaleza-relleno"></div>
        </div>
        <p class="ayuda" id="fortaleza-texto">Ingresa tu nueva contraseña.</p>

        <label for="confirmarPassword">Confirmar contraseña</label>
        <input
            type="password"
            id="confirmarPassword"
            name="confirmarPassword"
            placeholder="Repite la contraseña"
            required
            oninput="verificarCoincidencia()"
        >
        <div class="coincidencia" id="coincidencia-msg"></div>

        <button type="submit" class="btn-guardar">✅ Guardar nueva contraseña</button>
    </form>
</div>

<script>
    /**
     * Evalúa la fortaleza de la contraseña.
     */
    function evaluarFortaleza(valor) {
        const relleno = document.getElementById("fortaleza-relleno");
        const texto   = document.getElementById("fortaleza-texto");

        if (valor.length === 0) {
            relleno.style.width = "0%";
            texto.textContent = "Ingresa tu nueva contraseña.";
            texto.style.color = "#9ca3af";
            return;
        }

        let puntos = 0;
        if (valor.length >= 6)  puntos++;
        if (valor.length >= 10) puntos++;
        if (/[a-z]/.test(valor) && /[A-Z]/.test(valor)) puntos++;
        if (/[0-9]/.test(valor))    puntos++;
        if (/[^a-zA-Z0-9]/.test(valor)) puntos++;

        if (puntos <= 1) {
            relleno.style.width = "25%";
            relleno.style.backgroundColor = "#dc2626";
            texto.textContent = "Contraseña débil";
            texto.style.color = "#dc2626";
        } else if (puntos <= 3) {
            relleno.style.width = "60%";
            relleno.style.backgroundColor = "#f59e0b";
            texto.textContent = "Contraseña regular";
            texto.style.color = "#92400e";
        } else {
            relleno.style.width = "100%";
            relleno.style.backgroundColor = "#10b981";
            texto.textContent = "Contraseña fuerte ✓";
            texto.style.color = "#065f46";
        }
    }

    /**
     * Verifica en tiempo real si las dos contraseñas coinciden.
     */
    function verificarCoincidencia() {
        const p1  = document.getElementById("nuevaPassword").value;
        const p2  = document.getElementById("confirmarPassword").value;
        const msg = document.getElementById("coincidencia-msg");

        if (p2.length === 0) { msg.textContent = ""; return; }

        if (p1 === p2) {
            msg.textContent = "✓ Las contraseñas coinciden";
            msg.className = "coincidencia ok";
        } else {
            msg.textContent = "✗ Las contraseñas no coinciden";
            msg.className = "coincidencia no";
        }
    }

    /**
     * Valida el formulario antes de enviar.
     */
    function validar() {
        const p1 = document.getElementById("nuevaPassword").value;
        const p2 = document.getElementById("confirmarPassword").value;

        if (p1.length < 6) {
            alert("La contraseña debe tener al menos 6 caracteres.");
            return false;
        }

        if (p1 !== p2) {
            alert("Las contraseñas no coinciden. Por favor verifica.");
            return false;
        }

        return true;
    }
</script>

</body>
</html>
