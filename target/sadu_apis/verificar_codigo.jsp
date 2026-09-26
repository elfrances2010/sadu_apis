<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
    String error       = (String) request.getAttribute("error");
    String correoOculto = (String) request.getAttribute("correoOculto");
    if (correoOculto == null) correoOculto = "tu correo";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificar Código - SADU</title>
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
            margin-bottom: 20px;
        }

        .logo .icono { font-size: 52px; display: block; margin-bottom: 8px; }
        .logo h2 { color: #1f3b57; font-size: 24px; font-weight: bold; margin: 0; }
        .logo p { color: #9ca3af; font-size: 13px; margin: 6px 0 0; }

        .info-correo {
            background: #f0fdf4;
            border: 1px solid #6ee7b7;
            border-radius: 10px;
            padding: 12px 16px;
            text-align: center;
            font-size: 13px;
            color: #065f46;
            margin-bottom: 24px;
        }

        /* Inputs individuales para cada dígito del código */
        .codigo-inputs {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 24px;
        }

        .codigo-inputs input {
            width: 52px;
            height: 60px;
            text-align: center;
            font-size: 24px;
            font-weight: bold;
            border: 2px solid #d1d5db;
            border-radius: 10px;
            outline: none;
            transition: border-color 0.25s;
            color: #1f3b57;
        }

        .codigo-inputs input:focus {
            border-color: #1f3b57;
            box-shadow: 0 0 8px rgba(31,59,87,0.25);
        }

        /* Input oculto que recibe el código completo */
        #codigoCompleto { display: none; }

        .btn-verificar {
            width: 100%;
            background-color: #1f3b57;
            color: white;
            border: none;
            padding: 13px;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-bottom: 14px;
        }

        .btn-verificar:hover { background-color: #162d42; }

        .enlace-volver {
            display: block;
            text-align: center;
            color: #6b7280;
            font-size: 13px;
            text-decoration: none;
        }

        .enlace-volver:hover { color: #1f3b57; }

        .alerta-error {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fca5a5;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 13px;
            margin-bottom: 18px;
        }

        /* Temporizador de expiración */
        .temporizador {
            text-align: center;
            font-size: 13px;
            color: #ef4444;
            margin-bottom: 16px;
            font-weight: bold;
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
        <span class="icono">📧</span>
        <h2>Verifica tu código</h2>
        <p>Ingresa el código de 6 dígitos enviado a tu correo</p>
    </div>

    <!-- Indicador de pasos: paso 2 de 3 -->
    <div class="pasos">
        <div class="paso completado"></div>
        <div class="paso activo"></div>
        <div class="paso"></div>
    </div>

    <!-- Información del correo al que se envió el código -->
    <div class="info-correo">
        📨 Código enviado a <strong><%= correoOculto %></strong><br>
        <small>Revisa también tu carpeta de spam</small>
    </div>

    <%-- Alerta de error --%>
    <% if (error != null) { %>
        <div class="alerta-error">⚠️ <%= error %></div>
    <% } %>

    <!-- Temporizador de 15 minutos -->
    <div class="temporizador">
        ⏰ El código expira en: <span id="cuenta-regresiva">15:00</span>
    </div>

    <!--
        Formulario paso 2: ingreso del código.
        Los 6 inputs individuales se unen en un campo oculto al enviar.
        Envía por POST al VerificarCodigoServlet.
    -->
    <form action="verificarCodigo" method="post" onsubmit="return unirCodigo()">

        <!-- 6 inputs individuales — uno por cada dígito del código -->
        <div class="codigo-inputs">
            <input type="text" maxlength="1" class="digito" id="d1" inputmode="numeric" pattern="[0-9]">
            <input type="text" maxlength="1" class="digito" id="d2" inputmode="numeric" pattern="[0-9]">
            <input type="text" maxlength="1" class="digito" id="d3" inputmode="numeric" pattern="[0-9]">
            <input type="text" maxlength="1" class="digito" id="d4" inputmode="numeric" pattern="[0-9]">
            <input type="text" maxlength="1" class="digito" id="d5" inputmode="numeric" pattern="[0-9]">
            <input type="text" maxlength="1" class="digito" id="d6" inputmode="numeric" pattern="[0-9]">
        </div>

        <!-- Campo oculto que recibe el código completo antes de enviar -->
        <input type="text" id="codigoCompleto" name="codigo">

        <button type="submit" class="btn-verificar">✅ Verificar código</button>
        <a href="recuperarPassword" class="enlace-volver">← Solicitar nuevo código</a>
    </form>
</div>

<script>
    // Obtener todos los inputs de dígitos
    const digitos = document.querySelectorAll(".digito");

    /**
     * Navegar automáticamente al siguiente input al escribir un dígito,
     * y al anterior al borrar con Backspace.
     */
    digitos.forEach((input, index) => {
        input.addEventListener("input", function () {
            // Solo permitir números
            this.value = this.value.replace(/[^0-9]/g, "");

            // Si se escribió un dígito, pasar al siguiente campo
            if (this.value.length === 1 && index < digitos.length - 1) {
                digitos[index + 1].focus();
            }
        });

        input.addEventListener("keydown", function (e) {
            // Al borrar con Backspace, ir al campo anterior
            if (e.key === "Backspace" && this.value === "" && index > 0) {
                digitos[index - 1].focus();
            }
        });
    });

    // Enfocar el primer input al cargar
    digitos[0].focus();

    /**
     * Antes de enviar el formulario, une los 6 dígitos en el campo oculto.
     * @returns {boolean} false si el código está incompleto
     */
    function unirCodigo() {
        let codigo = "";
        digitos.forEach(d => codigo += d.value);

        if (codigo.length < 6) {
            alert("Por favor ingresa los 6 dígitos del código.");
            return false;
        }

        document.getElementById("codigoCompleto").value = codigo;
        return true;
    }

    /**
     * Temporizador de cuenta regresiva de 15 minutos.
     * Al llegar a cero muestra un mensaje de expiración.
     */
    let segundosTotales = 15 * 60;

    const intervalo = setInterval(function () {
        segundosTotales--;

        const minutos  = Math.floor(segundosTotales / 60);
        const segundos = segundosTotales % 60;

        document.getElementById("cuenta-regresiva").textContent =
            String(minutos).padStart(2, "0") + ":" + String(segundos).padStart(2, "0");

        if (segundosTotales <= 0) {
            clearInterval(intervalo);
            document.getElementById("cuenta-regresiva").textContent = "00:00";
            alert("El código ha expirado. Serás redirigido para solicitar uno nuevo.");
            window.location.href = "recuperarPassword";
        }
    }, 1000);
</script>

</body>
</html>
