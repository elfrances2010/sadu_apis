<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    /*
        Validar sesión activa.
        Si no hay sesión, redirigir al login.
    */
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiénes Somos - SADU</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    

    <style>
/* =============================================
           LAYOUT GENERAL
        ============================================= */
        body {
            margin: 0;
            background-color: #f4f6f9;
            font-family: Arial, sans-serif;
        }

        /* =============================================
           CONTENIDO PRINCIPAL
        ============================================= */
        .content {
            margin-left: 230px;
            padding: 30px;
            min-height: 100vh;
        }

        /* Barra superior */
        .topbar {
            background-color: white;
            padding: 14px 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }

        /* =============================================
           HERO — banner principal de la sección
        ============================================= */
        .hero {
            background: linear-gradient(135deg, #1f3b57 0%, #2f5579 60%, #1b4332 100%);
            border-radius: 16px;
            padding: 50px 40px;
            color: white;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }

        /* Círculos decorativos de fondo */
        .hero::before {
            content: "";
            position: absolute;
            width: 300px;
            height: 300px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            top: -80px;
            right: -80px;
        }

        .hero::after {
            content: "";
            position: absolute;
            width: 200px;
            height: 200px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            bottom: -60px;
            left: 40px;
        }

        .hero h1 {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 12px;
        }

        .hero p {
            font-size: 16px;
            opacity: 0.85;
            max-width: 600px;
            line-height: 1.6;
        }

        .hero .badge-sena {
            display: inline-block;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            border-radius: 20px;
            padding: 5px 16px;
            font-size: 13px;
            margin-bottom: 16px;
        }

        /* =============================================
           TARJETAS DE ESPECIALIDADES
        ============================================= */
        .especialidad-card {
            background: white;
            border-radius: 14px;
            padding: 24px 20px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.07);
            transition: transform 0.25s, box-shadow 0.25s;
            height: 100%;
            border-top: 4px solid #1f3b57;
        }

        .especialidad-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
        }

        .especialidad-card .icono {
            font-size: 36px;
            margin-bottom: 14px;
            display: block;
        }

        .especialidad-card h5 {
            font-size: 15px;
            font-weight: bold;
            color: #1f3b57;
            margin-bottom: 8px;
        }

        .especialidad-card p {
            font-size: 13px;
            color: #6b7280;
            line-height: 1.5;
            margin: 0;
        }

        /* Colores de borde por especialidad */
        .card-azul  { border-top-color: #1f3b57; }
        .card-verde { border-top-color: #2d6a4f; }
        .card-morado{ border-top-color: #6d28d9; }
        .card-naranja{ border-top-color: #ea580c; }
        .card-rojo  { border-top-color: #dc2626; }

        /* =============================================
           SECCIÓN OBJETIVOS
        ============================================= */
        .objetivos-box {
            background: white;
            border-radius: 14px;
            padding: 30px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.07);
            margin-bottom: 25px;
        }

        .objetivos-box h4 {
            color: #1f3b57;
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e2e8f0;
        }

        /* Cada objetivo como fila con número */
        .objetivo-item {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 16px;
        }

        .objetivo-num {
            min-width: 36px;
            height: 36px;
            background-color: #1f3b57;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 14px;
            flex-shrink: 0;
        }

        .objetivo-texto {
            font-size: 14px;
            color: #374151;
            line-height: 1.6;
            padding-top: 6px;
        }

        /* =============================================
           DESCRIPCIÓN DEL SISTEMA SADU
        ============================================= */
        .sadu-box {
            background: linear-gradient(135deg, #f0fdf4, #dbeafe);
            border-radius: 14px;
            padding: 30px;
            margin-bottom: 25px;
            border-left: 5px solid #2d6a4f;
        }

        .sadu-box h4 {
            color: #1b4332;
            font-weight: bold;
            margin-bottom: 12px;
        }

        .sadu-box p {
            color: #374151;
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 10px;
        }

        /* =============================================
           PIE DE PÁGINA
        ============================================= */
        .footer-sadu {
            text-align: center;
            padding: 20px;
            color: #9ca3af;
            font-size: 13px;
            margin-top: 10px;
            border-top: 1px solid #e2e8f0;
        }

        .footer-sadu span {
            color: #1f3b57;
            font-weight: bold;
        }
    </style>
</head>
<body>

    <!-- =============================================
         SIDEBAR
    ============================================= -->

    <!-- =============================================
         CONTENIDO PRINCIPAL
    ============================================= -->
    <%@ include file="sidebar.jsp" %>

<div class="content">

        <!-- Barra superior -->
        <div class="topbar d-flex justify-content-between align-items-center">
            <div>
                <h4 class="mb-0">Quiénes somos</h4>
                <small class="text-muted">Conoce al equipo detrás del sistema SADU</small>
            </div>
            <div class="text-end">
                <strong><%= nombreUsuario %></strong><br>
                <small class="text-muted">Sesión activa</small>
            </div>
        </div>

        <!-- Hero principal -->
        <div class="hero">
            <span class="badge-sena">🎓 SENA — Ficha 3186583</span>
            <h1>Nuestro Equipo</h1>
            <p>
                Somos un equipo de desarrolladores web en formación en el SENA,
                especializados en soluciones digitales para la administración pública
                y privada. Creamos sistemas web robustos con Java, MySQL, HTML/CSS/JS
                y UML para optimizar procesos como gestión documental, contabilidad,
                hotelería, educación interactiva y monitoreo ambiental.
            </p>
        </div>

        <!-- Descripción del sistema SADU -->
        <div class="sadu-box">
            <h4>📂 ¿Qué es el Sistema SADU?</h4>
            <p>
                <strong>SADU</strong> (Sistema de Administración Documental Unificado)
                es una aplicación web desarrollada para modernizar y optimizar la gestión
                de documentos y archivos del Archivo Municipal. El sistema centraliza el
                registro, digitalización, clasificación y control de documentos
                institucionales, garantizando trazabilidad, seguridad y cumplimiento normativo.
            </p>
            <p>
                Desarrollado con tecnología <strong>Java (Servlets + JSP)</strong>,
                base de datos <strong>MySQL</strong>, desplegado en <strong>Apache Tomcat</strong>
                e integrado con APIs externas como <strong>API Colombia</strong>
                para consulta de información geográfica del territorio nacional.
            </p>
        </div>

        <!-- Tarjetas de especialidades -->
        <h5 style="color:#1f3b57; font-weight:bold; margin-bottom:18px;">💡 Nuestras Especialidades</h5>
        <div class="row g-4 mb-4">

            <div class="col-md-4">
                <div class="especialidad-card card-azul">
                    <span class="icono">💻</span>
                    <h5>Desarrollo Web Full-Stack</h5>
                    <p>Construcción de aplicaciones web completas con Java, JSP, Servlets, HTML, CSS, JavaScript y MySQL como gestor de base de datos.</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="especialidad-card card-verde">
                    <span class="icono">📊</span>
                    <h5>Gestión Documental & ERP</h5>
                    <p>Diseño e implementación de sistemas CRUD para gestión documental, módulos de auditoría, reportes y control de acceso por roles (SADU).</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="especialidad-card card-morado">
                    <span class="icono">🏨</span>
                    <h5>Software Hotelería & Contabilidad</h5>
                    <p>Sistemas de reservas, facturación y módulos contables responsivos adaptados a las necesidades del sector empresarial.</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="especialidad-card card-naranja">
                    <span class="icono">🎓</span>
                    <h5>Apps Educativas Interactivas</h5>
                    <p>Aplicaciones multimedia para enseñanza de física y química con simulaciones, quizzes interactivos y recursos visuales dinámicos.</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="especialidad-card card-rojo">
                    <span class="icono">🌦️</span>
                    <h5>Estación Meteorológica IoT</h5>
                    <p>Monitoreo ambiental con sensores DHT/BMP, dashboard PHP/MySQL en tiempo real y sistema de alertas web para apoyo a la agricultura.</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="especialidad-card card-azul">
                    <span class="icono">🔒</span>
                    <h5>UML, Prototipos & Análisis</h5>
                    <p>Modelado de sistemas con diagramas UML, prototipos en Axure RP y análisis de requerimientos con historias de usuario y casos de uso.</p>
                </div>
            </div>

        </div>

        <!-- Objetivos del equipo -->
        <div class="objetivos-box">
            <h4>🎯 Nuestros Objetivos</h4>

            <div class="objetivo-item">
                <div class="objetivo-num">1</div>
                <div class="objetivo-texto">
                    <strong>Automatizar la gestión documental (SADU)</strong> con módulos CRUD completos,
                    reportes detallados y control de acceso seguro por roles de usuario.
                </div>
            </div>

            <div class="objetivo-item">
                <div class="objetivo-num">2</div>
                <div class="objetivo-texto">
                    <strong>Desarrollar software de contabilidad y hotelería</strong> responsivo,
                    adaptado a pequeñas y medianas empresas del sector privado colombiano.
                </div>
            </div>

            <div class="objetivo-item">
                <div class="objetivo-num">3</div>
                <div class="objetivo-texto">
                    <strong>Crear aplicaciones multimedia interactivas</strong> para la enseñanza
                    de física y química, mejorando la experiencia educativa de los estudiantes.
                </div>
            </div>

            <div class="objetivo-item">
                <div class="objetivo-num">4</div>
                <div class="objetivo-texto">
                    <strong>Implementar una estación meteorológica IoT</strong> con sensores DHT/BMP,
                    dashboard PHP/MySQL y sistema de alertas web para apoyo a la agricultura de precisión.
                </div>
            </div>

            <div class="objetivo-item">
                <div class="objetivo-num">5</div>
                <div class="objetivo-texto">
                    <strong>Integrar dashboards de asistencia y ERP</strong> con datos en tiempo real,
                    facilitando la toma de decisiones en entidades educativas y empresariales.
                </div>
            </div>
        </div>

        <!-- Pie de página -->
        <div class="footer-sadu">
            © 2026 <span>SADU</span> — Sistema de Administración Documental Unificado |
            <span>SENA</span> — Tecnólogo en Análisis y Desarrollo de Software |
            Desarrollado con fines educativos
        </div>

    </div>

</body>
</html>
