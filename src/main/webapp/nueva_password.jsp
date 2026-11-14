<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String error = (String) request.getAttribute("error");
    Boolean obligatorio = (Boolean) session.getAttribute("cambioClaveObligatorio");
    if (obligatorio == null) {
        String paramOblig = request.getParameter("obligatorio");
        if ("true".equalsIgnoreCase(paramOblig)) {
            obligatorio = true;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Nueva Contrase?a - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
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
            max-width: 460px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }

        .logo {
            text-align: center;
            margin-bottom: 24px;
        }

        .logo .icono { font-size: 52px; display: block; margin-bottom: 8px; color: #1f3b57; }
        .logo h2 { color: #1f3b57; font-size: 24px; font-weight: bold; margin: 0; }
        .logo p { color: #6c757d; font-size: 13px; margin: 6px 0 0; }

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
            font-weight: 600;
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

        .alerta-aviso {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
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
        <i class="bi bi-shield-lock-fill icono"></i>
        <h2>Nueva contrase?a</h2>
        <p>Establece tu nueva contrase?a de acceso</p>
    </div>

    <% if (Boolean.TRUE.equals(obligatorio)) { %>
        <div class="alerta-aviso">
            <i class="bi bi-exclamation-triangle-fill me-1"></i>
            <strong>Cambio de clave requerido:</strong> El administrador o la seguridad del sistema ha solicitado que actualices tu contrase?a antes de continuar.
        </div>
    <% } else { %>
        <div class="pasos">
            <div class="paso completado"></div>
            <div class="paso completado"></div>
            <div class="paso activo"></div>
        </div>
    <% } %>

    <% if (error != null) { %>
        <div class="alerta-error"><i class="bi bi-x-circle-fill me-1"></i> <%= error %></div>
    <% } %>

    <form action="nuevaPassword" method="post" onsubmit="return validar()">

        <label for="nuevaPassword">Nueva contrase?a</label>
        <input
            type="password"
            id="nuevaPassword"
            name="nuevaPassword"
            placeholder="M?nimo 6 caracteres"
            minlength="6"
            required
            oninput="evaluarFortaleza(this.value); verificarCoincidencia()"
        >
        <div class="fortaleza-barra">
            <div class="fortaleza-relleno" id="fortaleza-relleno"></div>
        </div>
        <p class="ayuda" id="fortaleza-texto">Ingresa tu nueva contrase?a.</p>

        <label for="confirmarPassword">Confirmar contrase?a</label>
        <input
            type="password"
            id="confirmarPassword"
            name="confirmarPassword"
            placeholder="Repite la contrase?a"
            required
            oninput="verificarCoincidencia()"
        >
        <div class="coincidencia" id="coincidencia-msg"></div>

        <button type="submit" class="btn-guardar"><i class="bi bi-check-circle-fill me-1"></i> Guardar nueva contrase?a</button>
    </form>
</div>

<script>
    function evaluarFortaleza(valor) {
        const relleno = document.getElementById("fortaleza-relleno");
        const texto   = document.getElementById("fortaleza-texto");

        if (valor.length === 0) {
            relleno.style.width = "0%";
            texto.textContent = "Ingresa tu nueva contrase?a.";
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
            texto.textContent = "Contrase?a d?bil";
            texto.style.color = "#dc2626";
        } else if (puntos <= 3) {
            relleno.style.width = "60%";
            relleno.style.backgroundColor = "#f59e0b";
            texto.textContent = "Contrase?a regular";
            texto.style.color = "#92400e";
        } else {
            relleno.style.width = "100%";
            relleno.style.backgroundColor = "#10b981";
            texto.textContent = "Contrase?a fuerte";
            texto.style.color = "#065f46";
        }
    }

    function verificarCoincidencia() {
        const p1  = document.getElementById("nuevaPassword").value;
        const p2  = document.getElementById("confirmarPassword").value;
        const msg = document.getElementById("coincidencia-msg");

        if (p2.length === 0) { msg.textContent = ""; return; }

        if (p1 === p2) {
            msg.textContent = "? Las contrase?as coinciden";
            msg.className = "coincidencia ok";
        } else {
            msg.textContent = "? Las contrase?as no coinciden";
            msg.className = "coincidencia no";
        }
    }

    function validar() {
        const p1 = document.getElementById("nuevaPassword").value;
        const p2 = document.getElementById("confirmarPassword").value;

        if (p1.length < 6) {
            alert("La contrase?a debe tener al menos 6 caracteres.");
            return false;
        }

        if (p1 !== p2) {
            alert("Las contrase?as no coinciden. Por favor verifica.");
            return false;
        }

        return true;
    }
</script>

</body>
</html>
