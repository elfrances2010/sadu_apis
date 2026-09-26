<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
    String error = (String) request.getAttribute("error");
    String exito = (String) request.getAttribute("exito");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Usuario - SADU</title>
    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome para iconos en inputs y botones -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
        body {
            margin: 0;
            background: linear-gradient(135deg, #dbeafe, #eff6ff);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: Arial, sans-serif;
            padding: 20px;
        }

        .card-container {
            background: #ffffff;
            border-radius: 16px;
            padding: 40px;
            width: 100%;
            max-width: 650px; /* Un poco más ancho para permitir distribución en dos columnas */
            box-shadow: 0 10px 30px rgba(31, 59, 87, 0.12);
            border-top: 5px solid #1f3b57;
        }

        .header-title {
            color: #1f3b57;
            font-weight: 700;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .header-subtitle {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 30px;
        }

        .form-label {
            font-size: 13.5px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
        }

        .form-control, .form-select {
            padding: 11px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14.5px;
            transition: all 0.2s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
            outline: none;
        }

        /* Contenedor del campo contraseña con ojo integrado */
        .password-wrapper {
            position: relative;
        }
        
        .password-wrapper input {
            padding-right: 45px;
        }

        .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #64748b;
            cursor: pointer;
            font-size: 15px;
        }

        .toggle-password:hover {
            color: #2563eb;
        }

        .btn-primary-sadu {
            background-color: #1f3b57;
            color: #ffffff;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            transition: background-color 0.2s ease;
        }

        .btn-primary-sadu:hover {
            background-color: #162d42;
            color: #ffffff;
        }

        .btn-cancelar {
            background-color: #f1f5f9;
            color: #475569;
            border: none;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.2s ease;
        }

        .btn-cancelar:hover {
            background-color: #e2e8f0;
            color: #334155;
        }
    </style>
</head>
<body>

<div class="card-container">
    
    <!-- Encabezado -->
    <div>
        <h2 class="header-title">👥 Registrar Usuario</h2>
        <p class="header-subtitle">Completa la información para dar de alta una nueva cuenta en SADU</p>
    </div>

    <!-- Alertas de Feedback -->
    <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i> <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <% if (exito != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i> <%= exito %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <!-- Formulario optimizado -->
    <form action="usuarios" method="post">
        <!-- Campo oculto para manejar la acción en tu Servlet corporativo -->
        <input type="hidden" name="accion" value="registrar">

        <div class="row g-3">
            <!-- Nombre Completo -->
            <div class="col-12">
                <label for="nombreCompleto" class="form-label">Nombre Completo *</label>
                <input type="text" id="nombreCompleto" name="nombreCompleto" class="form-control" placeholder="Ej: Diana Zamudio" required autofocus>
            </div>

            <!-- Correo Electrónico -->
            <div class="col-md-6">
                <label for="correo" class="form-label">Correo Electrónico *</label>
                <input type="email" id="correo" name="correo" class="form-control" placeholder="usuario@sadu.com" required>
            </div>

            <!-- Contraseña (con botón de visibilidad incorporado) -->
            <div class="col-md-6">
                <label for="password" class="form-label">Contraseña *</label>
                <div class="password-wrapper">
                    <input type="password" id="password" name="password" class="form-control" placeholder="Asigne una contraseña" required>
                    <button type="button" id="btnToggle" class="toggle-password" title="Mostrar/Ocultar">
                        <i id="eyeIcon" class="fa-solid fa-eye-slash"></i>
                    </button>
                </div>
            </div>

            <!-- Estado -->
            <div class="col-md-4">
                <label for="estado" class="form-label">Estado</label>
                <select id="estado" name="estado" class="form-select">
                    <option value="ACTIVO">✅ ACTIVO</option>
                    <option value="INACTIVO">❌ INACTIVO</option>
                </select>
            </div>

            <!-- Rol ID (Convertido a select semántico) -->
            <div class="col-md-4">
                <label for="idRol" class="form-label">Rol del Sistema *</label>
                <select id="idRol" name="idRol" class="form-select" required>
                    <option value="">-- Seleccione --</option>
                    <option value="1">👑 ADMINISTRADOR</option>
                    <option value="2">📂 GESTOR DE ARCHIVO</option>
                    <option value="3">🏢 DEPENDENCIA</option>
                </select>
            </div>

            <!-- Dependencia ID (Convertido a select semántico simulado o dinámico) -->
            <div class="col-md-4">
                <label for="idDependencia" class="form-label">Dependencia *</label>
                <select id="idDependencia" name="idDependencia" class="form-select" required>
                    <option value="">-- Seleccione --</option>
                    <option value="1">Oficina Central</option>
                    <option value="2">Recursos Humanos</option>
                    <option value="3">Gestión Documental</option>
                </select>
            </div>

            <!-- Botones de Acción inferiores -->
            <div class="col-12 d-flex gap-2 justify-content-end mt-4">
                <a href="usuarios?accion=listar" class="btn-cancelar">✕ Cancelar</a>
                <button type="submit" class="btn-primary-sadu">
                    <i class="fa-solid fa-floppy-disk me-2"></i> Guardar usuario
                </button>
            </div>
        </div>
    </form>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Script para la visibilidad de la contraseña -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const passwordInput = document.getElementById("password");
        const btnToggle = document.getElementById("btnToggle");
        const eyeIcon = document.getElementById("eyeIcon");

        btnToggle.addEventListener("click", function () {
            const isPassword = passwordInput.getAttribute("type") === "password";
            passwordInput.setAttribute("type", isPassword ? "text" : "password");

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