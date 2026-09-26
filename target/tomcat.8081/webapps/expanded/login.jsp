<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");
    String exito = request.getParameter("exito"); // Para capturar si viene de recuperar contraseña
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SADU</title>
    <!-- Iconos para el botón de mostrar/ocultar contraseña -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background: linear-gradient(135deg, #dbeafe, #eff6ff);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-container {
            width: 100%;
            max-width: 420px;
            background-color: #ffffff;
            padding: 35px;
            border-radius: 14px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
        }

        .login-container h1 {
            text-align: center;
            margin-bottom: 10px;
            color: #1e3a8a;
        }

        .login-container p {
            text-align: center;
            margin-bottom: 25px;
            color: #555;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: bold;
            color: #333;
        }

        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            font-size: 15px;
        }

        .form-group input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 5px rgba(37, 99, 235, 0.3);
        }

        /* Contenedor especial para el input group de la contraseña */
        .password-container {
            position: relative;
            display: flex;
            align-items: center;
        }

        .password-container input {
            padding-right: 45px; /* Espacio para que el texto no se monte en el ojo */
        }

        .toggle-password {
            position: absolute;
            right: 12px;
            background: none;
            border: none;
            color: #64748b;
            cursor: pointer;
            font-size: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            padding: 0 5px;
        }

        .toggle-password:hover {
            color: #2563eb;
        }

        /* Enlace de recuperación */
        .forgot-password-wrapper {
            text-align: right;
            margin-top: -10px;
            margin-bottom: 20px;
        }

        .forgot-password-link {
            font-size: 13px;
            color: #2563eb;
            text-decoration: none;
            font-weight: 500;
        }

        .forgot-password-link:hover {
            text-decoration: underline;
        }

        .btn-login {
            width: 100%;
            background-color: #2563eb;
            color: white;
            border: none;
            padding: 12px;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            font-weight: bold;
        }

        .btn-login:hover {
            background-color: #1d4ed8;
        }

        .error-message {
            background-color: #fee2e2;
            color: #b91c1c;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 18px;
            text-align: center;
            font-size: 14px;
            border: 1px solid #fca5a5;
        }

        .success-message {
            background-color: #d1fae5;
            color: #065f46;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 18px;
            text-align: center;
            font-size: 14px;
            border: 1px solid #6ee7b7;
        }

        .footer-text {
            text-align: center;
            margin-top: 18px;
            font-size: 13px;
            color: #666;
        }
    </style>
</head>
<body>

    <div class="login-container">
        <h1>SADU</h1>
        <p>Iniciar sesión en el sistema</p>

        <% if (error != null) { %>
            <div class="error-message">
                <%= error %>
            </div>
        <% } %>

        <% if ("sent".equals(exito)) { %>
            <div class="success-message">
                📩 Correo de recuperación enviado si la cuenta existe.
            </div>
        <% } %>

        <form action="login" method="post">
            <div class="form-group">
                <label for="username">Correo</label>
                <input type="email" id="username" name="username" placeholder="Ingrese su correo" required>
            </div>

            <div class="form-group">
                <label for="password">Contraseña</label>
                <div class="password-container">
                    <input type="password" id="password" name="password" placeholder="Ingrese su contraseña" required>
                    <button type="button" id="btnToggle" class="toggle-password" title="Mostrar/Ocultar contraseña">
                        <i id="eyeIcon" class="fa-solid fa-eye-slash"></i>
                    </button>
                </div>
            </div>

            <!-- Botón / Enlace para recuperar contraseña -->
            <div class="forgot-password-wrapper">
                <a href="recuperar_password.jsp" class="forgot-password-link">¿Olvidaste tu contraseña?</a>
            </div>

            <button type="submit" class="btn-login">Ingresar</button>
        </form>

        <div class="footer-text">
            Sistema de Administración Documental - SADU
        </div>
    </div>

    <!-- Lógica en JavaScript Puro para alternar la visibilidad de la clave -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const passwordInput = document.getElementById("password");
            const btnToggle = document.getElementById("btnToggle");
            const eyeIcon = document.getElementById("eyeIcon");

            btnToggle.addEventListener("click", function () {
                // Alternar el tipo de atributo entre password y text
                const isPassword = passwordInput.getAttribute("type") === "password";
                passwordInput.setAttribute("type", isPassword ? "text" : "password");

                // Intercambiar las clases del icono de FontAwesome
                if (isPassword) {
                    eyeIcon.classList.remove("fa-eye-slash");
                    eyeIcon.classList.add("fa-eye");
                } else {
                    eyeIcon.classList.remove("fa-eye");
                    eyeIcon.classList.add("fa-eye-slash");
                }
            });
        });
    </script>
</body>
</html>
