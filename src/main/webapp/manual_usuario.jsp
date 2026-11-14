<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    HttpSession sesion = request.getSession(false);

    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    String correoUsuario = (String) sesion.getAttribute("correoUsuario");
    String rolUsuarioStr = String.valueOf(sesion.getAttribute("rolUsuario"));
    
    int rolNum = 0;
    try {
        rolNum = Integer.parseInt(rolUsuarioStr);
    } catch (Exception e) {
        if ("ADMINISTRADOR".equalsIgnoreCase(rolUsuarioStr)) rolNum = 1;
        else if ("GESTOR".equalsIgnoreCase(rolUsuarioStr)) rolNum = 2;
        else rolNum = 3;
    }
    
    String nombreRol = "Usuario de Consulta y Dependencia (Rol 3)";
    String badgeRolColor = "bg-info text-dark";
    if (rolNum == 1) {
        nombreRol = "Administrador del Sistema (Rol 1)";
        badgeRolColor = "bg-danger";
    } else if (rolNum == 2) {
        nombreRol = "Gestor de Archivo y Radicacion (Rol 2)";
        badgeRolColor = "bg-primary";
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Centro de Ayuda y Manual de Usuario - SADU</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        :root {
            --sadu-primary: #1f3b57;
            --sadu-secondary: #2f5579;
            --sadu-accent: #3b82f6;
            --sadu-green: #10b981;
            --sadu-light: #f8fafc;
            --sadu-card-border: #e2e8f0;
        }

        body {
            margin: 0;
            background-color: #f1f5f9;
            font-family: 'Segoe UI', system-ui, -apple-system, Roboto, sans-serif;
            color: #1e293b;
        }

        .content {
            margin-left: 230px;
            padding: 25px 35px;
            min-height: 100vh;
        }

        /* Topbar */
        .topbar {
            background-color: white;
            padding: 16px 24px;
            border-radius: 14px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            border: 1px solid var(--sadu-card-border);
        }

        /* Tarjeta general */
        .card-panel {
            border: 1px solid var(--sadu-card-border);
            border-radius: 14px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.05);
            background: white;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        /* Banner de descarga */
        .banner-manual {
            background: linear-gradient(135deg, #162a3f 0%, #1f3b57 50%, #2b5278 100%);
            border-radius: 14px;
            padding: 24px 28px;
            color: white;
            box-shadow: 0 6px 20px rgba(31,59,87,0.25);
            margin-bottom: 24px;
            position: relative;
            overflow: hidden;
        }
        .banner-manual::after {
            content: "";
            position: absolute;
            right: -20px;
            top: -30px;
            width: 180px;
            height: 180px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            pointer-events: none;
        }

        /* Navegacion de capitulos */
        .manual-nav .list-group-item {
            border: 1px solid #edf2f7;
            margin-bottom: 5px;
            border-radius: 8px !important;
            font-size: 13.5px;
            font-weight: 500;
            color: #334155;
            padding: 11px 14px;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.2s ease;
        }
        .manual-nav .list-group-item:hover {
            background-color: #f1f5f9;
            color: var(--sadu-primary);
            transform: translateX(3px);
        }
        .manual-nav .list-group-item.active {
            background-color: var(--sadu-primary) !important;
            border-color: var(--sadu-primary) !important;
            color: white !important;
            font-weight: 600;
            box-shadow: 0 3px 8px rgba(31,59,87,0.3);
        }

        /* Pasos numerados */
        .step-badge {
            background: linear-gradient(135deg, #1f3b57, #3b82f6);
            color: white;
            border-radius: 50%;
            width: 26px;
            height: 26px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: bold;
            margin-right: 10px;
            flex-shrink: 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.15);
        }

        /* Callouts / Alertas informativas */
        .callout {
            padding: 16px 18px;
            border-radius: 10px;
            margin: 18px 0;
            font-size: 14px;
            line-height: 1.5;
            border-left: 5px solid;
        }
        .callout-info {
            background-color: #eff6ff;
            border-left-color: #3b82f6;
            color: #1e3a8a;
        }
        .callout-success {
            background-color: #f0fdf4;
            border-left-color: #10b981;
            color: #064e3b;
        }
        .callout-warning {
            background-color: #fffbeb;
            border-left-color: #f59e0b;
            color: #78350f;
        }
        .callout-danger {
            background-color: #fef2f2;
            border-left-color: #ef4444;
            color: #7f1d1d;
        }
        .callout-sena {
            background-color: #f3fdf8;
            border-left-color: #008f39;
            color: #0d4a22;
        }

        /* Tarjetas de roles especificos */
        .role-box {
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            background: #ffffff;
            transition: all 0.2s ease;
        }
        .role-box:hover {
            box-shadow: 0 6px 18px rgba(0,0,0,0.07);
        }
        .role-box.role-1 { border-left: 6px solid #ef4444; }
        .role-box.role-2 { border-left: 6px solid #3b82f6; }
        .role-box.role-3 { border-left: 6px solid #10b981; }

        /* Matriz de Permisos */
        .perm-table {
            font-size: 13.5px;
            border-radius: 8px;
            overflow: hidden;
        }
        .perm-table th {
            background-color: #1f3b57;
            color: white;
            font-weight: 600;
            text-align: center;
            vertical-align: middle;
            padding: 10px 12px;
        }
        .perm-table td {
            vertical-align: middle;
            padding: 10px 12px;
        }
        .perm-ok {
            color: #10b981;
            font-weight: bold;
        }
        .perm-no {
            color: #94a3b8;
        }

        /* Cajas de simulacion de interfaz */
        .mock-box {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            padding: 15px;
            margin: 14px 0;
            font-size: 13px;
        }

        /* Titulos de capitulos */
        .chapter-title {
            color: #1f3b57;
            font-weight: 700;
            font-size: 20px;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 12px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .role-badge-pill {
            font-size: 11.5px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 20px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .filter-btn-group .btn {
            font-size: 12.5px;
            padding: 6px 14px;
            border-radius: 20px;
            font-weight: 600;
        }
    </style>
</head>
<body>

    <!-- SIDEBAR SADU UNIFICADO -->
    <%@ include file="sidebar.jsp" %>

    <div class="content">

        <!-- Barra Superior -->
        <div class="topbar d-flex justify-content-between align-items-center">
            <div>
                <h4 class="mb-0 fw-bold" style="color: #1f3b57;">
                    <i class="bi bi-book-half text-primary me-2"></i>Centro de Ayuda y Manual de Usuario
                </h4>
                <small class="text-muted">
                    Gu&iacute;a operativa, reglamentaria y t&eacute;cnica integral del Sistema SADU (ADSO SENA Ficha 3186583)
                </small>
            </div>
            <div class="text-end">
                <span class="d-block fw-bold text-dark"><%= nombreUsuario %></span>
                <span class="badge <%= badgeRolColor %>"><%= nombreRol %></span>
            </div>
        </div>

        <!-- Banner de Descarga de Documento Oficial -->
        <div class="banner-manual">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <span class="badge bg-light text-dark fw-bold" style="font-size: 11px;">EVIDENCIA SENA DNP</span>
                        <span class="badge bg-success fw-bold" style="font-size: 11px;">VERSI&Oacute;N UNIFICADA 2026</span>
                    </div>
                    <h4 class="mb-1 fw-bold text-white">
                        <i class="bi bi-file-earmark-word-fill text-warning me-2"></i>Manual de Usuario Oficial SADU (.docx Editable)
                    </h4>
                    <p class="mb-0 text-white-50" style="font-size: 13.5px;">
                        Documento t&eacute;cnico y pedag&oacute;gico completo de 4.4 MB elaborado seg&uacute;n est&aacute;ndares del Departamento Nacional de Planeaci&oacute;n (DNP), Archivo General de la Naci&oacute;n (Ley 594) y gu&iacute;as del SENA.
                    </p>
                </div>
                <div class="d-flex flex-wrap gap-2 flex-shrink-0">
                    <a href="docs/Manual_de_Usuario_Unificado_SADU_SENA.docx" download="Manual_de_Usuario_Unificado_SADU_SENA.docx" class="btn btn-warning btn-lg fw-bold text-dark shadow-sm d-flex align-items-center gap-2">
                        <i class="bi bi-download fs-5"></i> Descargar .docx (4.4 MB)
                    </a>
                </div>
            </div>
        </div>

        <!-- Barra de Filtros R&aacute;pidos por Rol -->
        <div class="card card-panel p-3 mb-4">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-funnel-fill text-primary"></i>
                    <strong style="font-size: 13px; color: #334155;">Seleccionar Vista de Usuario:</strong>
                </div>
                <div class="btn-group filter-btn-group" role="group">
                    <button type="button" class="btn btn-outline-primary active" onclick="filtrarVistaRol('todos')">
                        <i class="bi bi-grid-fill me-1"></i> Todos los Cap&iacute;tulos
                    </button>
                    <button type="button" class="btn btn-outline-danger" onclick="filtrarVistaRol('rol1')">
                        <i class="bi bi-shield-lock-fill me-1"></i> Rol 1: Administrador
                    </button>
                    <button type="button" class="btn btn-outline-primary" onclick="filtrarVistaRol('rol2')">
                        <i class="bi bi-archive-fill me-1"></i> Rol 2: Gestor Archivo
                    </button>
                    <button type="button" class="btn btn-outline-success" onclick="filtrarVistaRol('rol3')">
                        <i class="bi bi-building me-1"></i> Rol 3: Dependencia
                    </button>
                </div>
            </div>
        </div>

        <!-- Layout Principal: Menu Izquierdo de Capitulos + Contenido Derecho -->
        <div class="row">
            
            <!-- COLUMNA IZQUIERDA: INDICE DE CAPITULOS -->
            <div class="col-lg-3 col-md-4 mb-4">
                <div class="card card-panel p-3 sticky-top" style="top: 20px; z-index: 10;">
                    <div class="mb-2 d-flex justify-content-between align-items-center">
                        <span class="text-uppercase fw-bold text-muted" style="font-size: 11px; letter-spacing: 1px;">&Iacute;ndice del Manual</span>
                        <span class="badge bg-secondary" style="font-size: 10px;">12 Cap&iacute;tulos</span>
                    </div>

                    <!-- Buscador en tiempo real de capitulos -->
                    <div class="mb-3">
                        <input type="text" id="filtroCapituloInput" class="form-control form-control-sm" placeholder="🔍 Buscar tema o m&oacute;dulo..." oninput="filtrarCapitulosLista()">
                    </div>

                    <div class="list-group manual-nav" id="manualListTab" role="tablist">
                        <a class="list-group-item list-group-item-action active" id="tab-1-link" data-bs-toggle="list" href="#cap-1" role="tab">
                            <i class="bi bi-house-door-fill text-primary"></i> 1. Bienvenida y SADU
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-2-link" data-bs-toggle="list" href="#cap-2" role="tab">
                            <i class="bi bi-key-fill text-warning"></i> 2. Acceso y Seguridad
                        </a>
                        <a class="list-group-item list-group-item-action fw-bold text-primary" id="tab-3-link" data-bs-toggle="list" href="#cap-3" role="tab" style="background: #f0f7ff;">
                            <i class="bi bi-people-fill text-danger"></i> 3. Gu&iacute;a por Roles
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-4-link" data-bs-toggle="list" href="#cap-4" role="tab">
                            <i class="bi bi-speedometer2 text-info"></i> 4. Dashboard de Control
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-5-link" data-bs-toggle="list" href="#cap-5" role="tab">
                            <i class="bi bi-chat-dots-fill text-success"></i> 5. Chat ICQ Empresarial
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-6-link" data-bs-toggle="list" href="#cap-6" role="tab">
                            <i class="bi bi-envelope-paper-fill text-primary"></i> 6. Comunicaciones
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-7-link" data-bs-toggle="list" href="#cap-7" role="tab">
                            <i class="bi bi-folder-check text-warning"></i> 7. Documentos y Radicaci&oacute;n
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-8-link" data-bs-toggle="list" href="#cap-8" role="tab">
                            <i class="bi bi-globe-americas text-primary"></i> 8. Sincronizaci&oacute;n API Col.
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-9-link" data-bs-toggle="list" href="#cap-9" role="tab">
                            <i class="bi bi-info-circle-fill text-secondary"></i> 9. Qui&eacute;nes Somos
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-10-link" data-bs-toggle="list" href="#cap-10" role="tab">
                            <i class="bi bi-shield-lock-fill text-danger"></i> 10. Admin y Auditor&iacute;a
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-11-link" data-bs-toggle="list" href="#cap-11" role="tab">
                            <i class="bi bi-bar-chart-line-fill text-info"></i> 11. Reportes y M&eacute;tricas
                        </a>
                        <a class="list-group-item list-group-item-action" id="tab-12-link" data-bs-toggle="list" href="#cap-12" role="tab">
                            <i class="bi bi-question-circle-fill text-warning"></i> 12. FAQ y Mesa de Ayuda
                        </a>
                    </div>

                    <div class="mt-3 p-2 bg-light rounded text-center" style="font-size: 11.5px; color: #64748b;">
                        <i class="bi bi-info-circle me-1"></i> Presiona <kbd>Ctrl+F</kbd> para b&uacute;squeda r&aacute;pida dentro del texto.
                    </div>
                </div>
            </div>

            <!-- COLUMNA DERECHA: CONTENIDO DETALLADO DE CADA CAPITULO -->
            <div class="col-lg-9 col-md-8">
                <div class="card card-panel p-4">
                    <div class="tab-content" id="manualTabContent">

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 1: BIENVENIDA Y ARQUITECTURA -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade show active" id="cap-1" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-house-door-fill text-primary"></i> 1. Bienvenida y Arquitectura del Sistema SADU
                            </div>

                            <p class="lead" style="font-size: 15px; color: #334155;">
                                El <strong>Sistema de Administraci&oacute;n Documental Unificado (SADU)</strong> es una soluci&oacute;n web institucional desarrollada bajo los lineamientos metodol&oacute;gicos del <strong>Departamento Nacional de Planeaci&oacute;n (DNP)</strong> y las normas archiv&iacute;sticas colombianas de la <strong>Ley 594 de 2000 (Ley General de Archivos)</strong> del Archivo General de la Naci&oacute;n (AGN).
                            </p>

                            <div class="callout callout-sena">
                                <h6 class="fw-bold mb-1"><i class="bi bi-award-fill text-success me-2"></i>Marco Acad&eacute;mico y Formativo SENA</h6>
                                <p class="mb-0">
                                    Proyecto desarrollado en el marco del programa <strong>Tecnolog&iacute;a en An&aacute;lisis y Desarrollo de Software (ADSO)</strong>, Ficha <strong>3186583</strong>, correspondiente a la evidencia de evaluaci&oacute;n <code>GA10-220501097-AA10-EV01 / AA11-EV01</code>: <em>"Elabora el manual de usuario, de acuerdo con las funcionalidades del software"</em>.
                                </p>
                            </div>

                            <h5 class="fw-bold mt-4 mb-3 text-primary"><i class="bi bi-check2-circle me-2"></i>Objetivos Estrat&eacute;gicos del Sistema</h5>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <div class="p-3 border rounded bg-light h-100">
                                        <h6 class="fw-bold text-dark"><i class="bi bi-diagram-3-fill text-primary me-2"></i>Centralizaci&oacute;n y Cero Papel</h6>
                                        <p class="mb-0 small text-muted">Elimina la dispersi&oacute;n de documentos f&iacute;sicos, digitalizando expedientes en formato PDF con control de folios, fechas y anexos.</p>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="p-3 border rounded bg-light h-100">
                                        <h6 class="fw-bold text-dark"><i class="bi bi-qr-code text-primary me-2"></i>C&oacute;digo &Uacute;nico de Radicado y QR</h6>
                                        <p class="mb-0 small text-muted">Garantiza el no repudio y la verificabilidad inmediata de cada documento y comunicaci&oacute;n mediante trazabilidad autom&aacute;tica.</p>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="p-3 border rounded bg-light h-100">
                                        <h6 class="fw-bold text-dark"><i class="bi bi-chat-heart-fill text-success me-2"></i>Comunicaci&oacute;n S&iacute;ncrona ICQ</h6>
                                        <p class="mb-0 small text-muted">Canal instant&aacute;neo corporativo con audio, im&aacute;genes y presencia en vivo para coordinar trámites entre dependencias y ventanilla.</p>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="p-3 border rounded bg-light h-100">
                                        <h6 class="fw-bold text-dark"><i class="bi bi-shield-check text-danger me-2"></i>Auditor&iacute;a Inmutable de Eventos</h6>
                                        <p class="mb-0 small text-muted">Registro forense de cada transacci&oacute;n cr&iacute;tica (login, creaci&oacute;n, modificaci&oacute;n, borrado, IP de origen) para control interno.</p>
                                    </div>
                                </div>
                            </div>

                            <h5 class="fw-bold mt-4 mb-2 text-primary"><i class="bi bi-layout-wtf me-2"></i>Estructura Visual de la Interfaz</h5>
                            <ul class="list-unstyled">
                                <li class="mb-2">
                                    <span class="step-badge">1</span> <strong>Barra Lateral (Sidebar):</strong> Ubicada a la izquierda, siempre fija y con acceso a los 11 m&oacute;dulos estructurados en dos bloques: <em>Navegaci&oacute;n</em> y <em>Administraci&oacute;n</em>.
                                </li>
                                <li class="mb-2">
                                    <span class="step-badge">2</span> <strong>Barra Superior (Topbar):</strong> Muestra el m&oacute;dulo activo, el nombre del usuario autenticado y su rol con distintivo visual.
                                </li>
                                <li class="mb-2">
                                    <span class="step-badge">3</span> <strong>Bot&oacute;n Flotante de Chat (#chat-fab):</strong> Esfera animada en la esquina inferior derecha con contador de mensajes no le&iacute;dos.
                                </li>
                            </ul>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 2: ACCESO, SEGURIDAD Y RECUPERACION -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-2" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-key-fill text-warning"></i> 2. Acceso al Sistema, Seguridad y Recuperaci&oacute;n de Contrase&ntilde;as
                            </div>

                            <p class="text-muted">
                                El acceso a SADU requiere autenticaci&oacute;n formal con credenciales individuales otorgadas por el Administrador. Siga las instrucciones seg&uacute;n la acci&oacute;n requerida:
                            </p>

                            <div class="card p-3 mb-4 bg-light border">
                                <h6 class="fw-bold text-primary mb-3"><i class="bi bi-box-arrow-in-right me-2"></i>Procedimiento de Inicio de Sesi&oacute;n (Login)</h6>
                                <div class="d-flex align-items-start mb-3">
                                    <span class="step-badge">1</span>
                                    <div>
                                        <strong>Acceder a la URL Institucional:</strong> Abra su navegador (Chrome, Edge o Firefox) e ingrese a: <code>http://localhost:8080/sadu_apis/login.jsp</code>.
                                    </div>
                                </div>
                                <div class="d-flex align-items-start mb-3">
                                    <span class="step-badge">2</span>
                                    <div>
                                        <strong>Diligenciar Credenciales:</strong> Ingrese su correo electr&oacute;nico corporativo registrado y su contrase&ntilde;a asignada en los campos correspondientes.
                                    </div>
                                </div>
                                <div class="d-flex align-items-start mb-2">
                                    <span class="step-badge">3</span>
                                    <div>
                                        <strong>Presionar "Iniciar Sesi&oacute;n":</strong> El sistema verificar&aacute; su cuenta en MySQL, crear&aacute; su sesi&oacute;n HTTP protegida y lo redirigir&aacute; al <strong>Dashboard</strong>.
                                    </div>
                                </div>
                            </div>

                            <div class="card p-3 mb-4 border border-warning bg-white">
                                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-shield-lock text-warning me-2"></i>Flujo de Recuperaci&oacute;n de Contrase&ntilde;a Olvidada</h6>
                                <p class="small text-muted mb-3">Si olvid&oacute; su clave de acceso, el sistema dispone de un mecanismo automatizado con env&iacute;o de c&oacute;digo de seguridad de 6 d&iacute;gitos a su correo electr&oacute;nico:</p>
                                
                                <div class="row g-2 text-center mb-3">
                                    <div class="col-md-4">
                                        <div class="p-2 border rounded bg-light">
                                            <div class="fw-bold text-primary">Paso 1: Solicitud</div>
                                            <small class="text-muted">Clic en "¿Olvidaste tu contraseña?" en el Login y digitar su correo corporativo.</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="p-2 border rounded bg-light">
                                            <div class="fw-bold text-primary">Paso 2: C&oacute;digo</div>
                                            <small class="text-muted">Revisar bandeja de entrada e ingresar el c&oacute;digo num&eacute;rico temporal de 6 d&iacute;gitos.</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="p-2 border rounded bg-light">
                                            <div class="fw-bold text-primary">Paso 3: Nueva Clave</div>
                                            <small class="text-muted">Asignar una nueva clave segura con m&iacute;nimo 6 caracteres y confirmarla.</small>
                                        </div>
                                    </div>
                                </div>

                                <div class="callout callout-info mb-0">
                                    <strong><i class="bi bi-info-circle-fill me-1"></i>Nota de seguridad:</strong> El c&oacute;digo de verificaci&oacute;n tiene una vigencia limitada de 15 minutos para prevenir intentos no autorizados.
                                </div>
                            </div>

                            <div class="card p-3 border-danger bg-light">
                                <h6 class="fw-bold text-danger mb-2"><i class="bi bi-box-arrow-right me-2"></i>Salida Segura del Sistema (Cerrar Sesi&oacute;n)</h6>
                                <p class="small mb-0 text-muted">
                                    Al terminar su jornada, haga clic en <strong>Cerrar Sesi&oacute;n</strong> (resaltado en rojo al final de la barra lateral). Esto destruye inmediatamente la sesi&oacute;n de usuario, borra las cookies de autenticaci&oacute;n y registra el evento formal de LOGOUT en la tabla de auditor&iacute;a para evitar accesos no autorizados en terminales compartidas.
                                </p>
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 3: GUIA DETALLADA POR ROLES (DE CADA USUARIO) -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-3" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-people-fill text-danger"></i> 3. Gu&iacute;a Operativa Detallada de Cada Rol de Usuario
                            </div>

                            <p class="lead" style="font-size: 14.5px;">
                                En SADU la seguridad est&aacute; basada en roles (RBAC). A continuaci&oacute;n se describe de manera exhaustiva el prop&oacute;sito, las funciones, las pantallas autorizadas, el paso a paso operativo y las restricciones para <strong>cada tipo de usuario</strong> del sistema:
                            </p>

                            <!-- =================== ROL 1: ADMINISTRADOR =================== -->
                            <div class="role-box role-1" id="guia-rol-1">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <h5 class="fw-bold text-danger mb-0">
                                        <i class="bi bi-shield-fill-check me-2"></i>Rol 1: Administrador del Sistema
                                    </h5>
                                    <span class="badge bg-danger">Superusuario</span>
                                </div>
                                <p class="small text-muted mb-3">
                                    <strong>Perfil T&eacute;cnico / Operativo:</strong> Oficial de seguridad de la informaci&oacute;n, l&iacute;der de tecnolog&iacute;a o jefe de gesti&oacute;n documental con privilegios totales sobre la plataforma, la base de datos y la configuraci&oacute;n institucional.
                                </p>

                                <h6 class="fw-bold text-dark"><i class="bi bi-star-fill text-warning me-1"></i>Funciones y Facultades Exclusivas:</h6>
                                <ul class="small text-muted mb-3">
                                    <li><strong>Gesti&oacute;n de Usuarios (<code>/usuarios</code>):</strong> Crear nuevas cuentas, asignar roles institucionales (1, 2 ó 3), activar/inactivar usuarios por retiro o traslado y restablecer credenciales.</li>
                                    <li><strong>Auditor&iacute;a Forense (<code>/auditoria</code>):</strong> Supervisar la bit&aacute;cora inmutable de transacciones, filtrando por fecha, direcci&oacute;n IP, usuario o acci&oacute;n cr&iacute;tica (LOGIN, CREATE, UPDATE, DELETE).</li>
                                    <li><strong>Control de Sincronizaci&oacute;n Territorial:</strong> Actualizar y forzar la sincronizaci&oacute;n de municipios y departamentos con la API Colombia oficial.</li>
                                    <li><strong>Reportes Gerenciales Completos:</strong> An&aacute;lisis de volumen de radicaci&oacute;n por dependencias, estados y trazabilidad anual.</li>
                                </ul>

                                <div class="card p-3 bg-light border mb-3">
                                    <strong class="text-danger small mb-2 d-block"><i class="bi bi-clipboard-check me-1"></i>Paso a Paso: Crear un Nuevo Usuario en el Sistema</strong>
                                    <ol class="small mb-0 ps-3">
                                        <li class="mb-1">Haga clic en el men&uacute; <strong>G. Usuarios</strong> en la secci&oacute;n <em>Administraci&oacute;n</em> de la barra lateral.</li>
                                        <li class="mb-1">En el formulario de registro diligencie: <strong>Nombre Completo</strong>, <strong>Correo Electr&oacute;nico</strong> institucional, <strong>Nombre de Usuario</strong> (de acceso &uacute;nico), <strong>Contrase&ntilde;a</strong> y <strong>Rol Asignado</strong> (1: Admin, 2: Gestor, 3: Consulta).</li>
                                        <li class="mb-1">Seleccione el estado inicial (<em>Activo</em>) y presione el bot&oacute;n <strong>Guardar Usuario</strong>. El funcionario podr&aacute; ingresar de inmediato.</li>
                                    </ol>
                                </div>

                                <div class="d-flex gap-2">
                                    <a href="usuarios" class="btn btn-sm btn-outline-danger"><i class="bi bi-arrow-right-circle me-1"></i>Ir a G. Usuarios</a>
                                    <a href="auditoria" class="btn btn-sm btn-outline-secondary"><i class="bi bi-shield-check me-1"></i>Ir a Auditor&iacute;a</a>
                                </div>
                            </div>

                            <!-- =================== ROL 2: GESTOR DE ARCHIVO =================== -->
                            <div class="role-box role-2" id="guia-rol-2">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <h5 class="fw-bold text-primary mb-0">
                                        <i class="bi bi-archive-fill me-2"></i>Rol 2: Gestor de Archivo y Radicaci&oacute;n (Ventanilla &Uacute;nica)
                                    </h5>
                                    <span class="badge bg-primary">Gesti&oacute;n Documental</span>
                                </div>
                                <p class="small text-muted mb-3">
                                    <strong>Perfil Operativo:</strong> Funcionarios responsables de la recepci&oacute;n, radicaci&oacute;n oficial, clasificaci&oacute;n archiv&iacute;stica seg&uacute;n TRD, foliaci&oacute;n, digitalizaci&oacute;n y despacho de correspondencia y expedientes.
                                </p>

                                <h6 class="fw-bold text-dark"><i class="bi bi-star-fill text-warning me-1"></i>Funciones y Facultades Autorizadas:</h6>
                                <ul class="small text-muted mb-3">
                                    <li><strong>Radicaci&oacute;n de Documentos (<code>/documentos</code>):</strong> Asignaci&oacute;n de c&oacute;digo consecutivo institucional (ej. <code>DOC-2025-014</code>), metadatos, tipo documental y carga de archivos PDF.</li>
                                    <li><strong>Comunicaciones Oficiales (<code>/comunicaciones</code>):</strong> Radicar correspondencia interna, externa recibida y despachada, control de anexos y dependencias remitentes.</li>
                                    <li><strong>Consulta Maestra de Expedientes (<code>/documentosRegistrados</code>):</strong> B&uacute;squeda r&aacute;pida, apertura y descarga de archivos digitales anexos.</li>
                                    <li><strong>Chat Empresarial ICQ:</strong> Coordinaci&oacute;n permanente con funcionarios de dependencias y atenci&oacute;n de solicitudes de expedientes.</li>
                                </ul>

                                <div class="card p-3 bg-light border mb-3">
                                    <strong class="text-primary small mb-2 d-block"><i class="bi bi-clipboard-check me-1"></i>Paso a Paso: Radicar un Documento Oficial en Ventanilla</strong>
                                    <ol class="small mb-0 ps-3">
                                        <li class="mb-1">Haga clic en <strong>Documentos</strong> en la barra lateral.</li>
                                        <li class="mb-1">Verifique el <strong>C&oacute;digo Sugerido</strong> por el sistema (se genera autom&aacute;ticamente para evitar duplicados).</li>
                                        <li class="mb-1">Seleccione el <strong>Tipo de Documento</strong> seg&uacute;n la Tabla de Retenci&oacute;n (Oficio, Memorando, Circular, Acta, Resoluci&oacute;n, Contrato, Informe).</li>
                                        <li class="mb-1">Seleccione la <strong>Dependencia</strong> responsable, escriba el <strong>T&iacute;tulo</strong> y el <strong>Asunto</strong> resumido.</li>
                                        <li class="mb-1">Adjunte el archivo escaneado en formato PDF y presione <strong>Registrar Documento</strong>. El sistema generar&aacute; el sello y c&oacute;digo QR.</li>
                                    </ol>
                                </div>

                                <div class="callout callout-warning py-2 mb-3">
                                    <small><strong>Restricciones de seguridad:</strong> El Gestor de Archivo NO tiene acceso a crear o eliminar usuarios del sistema ni a alterar la tabla de auditor&iacute;a forense.</small>
                                </div>

                                <div class="d-flex gap-2">
                                    <a href="documentos" class="btn btn-sm btn-outline-primary"><i class="bi bi-folder-plus me-1"></i>Ir a Documentos</a>
                                    <a href="comunicaciones" class="btn btn-sm btn-outline-info"><i class="bi bi-envelope me-1"></i>Ir a Comunicaciones</a>
                                </div>
                            </div>

                            <!-- =================== ROL 3: DEPENDENCIA MUNICIPAL =================== -->
                            <div class="role-box role-3" id="guia-rol-3">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <h5 class="fw-bold text-success mb-0">
                                        <i class="bi bi-building me-2"></i>Rol 3: Dependencia Municipal / Usuario de Consulta
                                    </h5>
                                    <span class="badge bg-success">Consulta y Tr&aacute;mite</span>
                                </div>
                                <p class="small text-muted mb-3">
                                    <strong>Perfil Operativo:</strong> Funcionarios de dependencias externas, despachos de secretar&iacute;as o usuarios de consulta que deben revisar expedientes asignados a su &aacute;rea sin alterar el fondo documental central.
                                </p>

                                <h6 class="fw-bold text-dark"><i class="bi bi-star-fill text-warning me-1"></i>Funciones y Facultades Autorizadas:</h6>
                                <ul class="small text-muted mb-3">
                                    <li><strong>Consulta de Radicados (<code>/documentosRegistrados</code>):</strong> Localizaci&oacute;n de expedientes por n&uacute;mero de radicado, fecha o asunto, con visualizaci&oacute;n y descarga de PDFs.</li>
                                    <li><strong>Dashboard General:</strong> Monitoreo de indicadores generales y actividad documental.</li>
                                    <li><strong>Sincronizaci&oacute;n Territorial:</strong> Consulta geogr&aacute;fica de municipios y departamentos de Colombia (DANE / Divipola).</li>
                                    <li><strong>Chat Empresarial ICQ:</strong> Canal directo para solicitar radicados, copias o enviar notas de voz e im&aacute;genes a la ventanilla de archivo.</li>
                                </ul>

                                <div class="card p-3 bg-light border mb-3">
                                    <strong class="text-success small mb-2 d-block"><i class="bi bi-clipboard-check me-1"></i>Paso a Paso: Consultar y Descargar un Expediente Asignado</strong>
                                    <ol class="small mb-0 ps-3">
                                        <li class="mb-1">Haga clic en <strong>Doc. Registrados</strong> en la barra lateral.</li>
                                        <li class="mb-1">En la barra de b&uacute;squeda, ingrese el n&uacute;mero de radicado o palabra clave del asunto y presione <strong>Buscar</strong>.</li>
                                        <li class="mb-1">Ubique el registro en la tabla y haga clic en el &iacute;cono <strong>Ver / Descargar PDF</strong> para visualizar el archivo en una pesta&ntilde;a nueva.</li>
                                    </ol>
                                </div>

                                <div class="callout callout-danger py-2 mb-3">
                                    <small><strong>Protecci&oacute;n contra intrusi&oacute;n:</strong> Si un usuario Rol 3 intenta ingresar directamente por URL a <code>/usuarios</code> o <code>/auditoria</code>, el m&oacute;dulo <code>VerificadorRol.java</code> interceptar&aacute; la petici&oacute;n y lo redirigir&aacute; a <code>acceso_denegado.jsp</code>.</small>
                                </div>

                                <a href="documentosRegistrados" class="btn btn-sm btn-outline-success"><i class="bi bi-file-earmark-check me-1"></i>Ir a Doc. Registrados</a>
                            </div>

                            <!-- =================== MATRIZ DE PERMISOS =================== -->
                            <h5 class="fw-bold mt-4 mb-3 text-dark"><i class="bi bi-table me-2"></i>Matriz Comparativa de Permisos por M&oacute;dulo y Rol</h5>
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover perm-table shadow-sm">
                                    <thead>
                                        <tr>
                                            <th style="width: 35%;">M&oacute;dulo del Sistema (Sidebar)</th>
                                            <th style="width: 21%;">Rol 1: Administrador</th>
                                            <th style="width: 22%;">Rol 2: Gestor Archivo</th>
                                            <th style="width: 22%;">Rol 3: Dependencia</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><strong><i class="bi bi-speedometer2 me-1"></i> Dashboard</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-chat-dots me-1"></i> Chat Empresarial ICQ</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-envelope me-1"></i> Comunicaciones</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Radicar y Buscar</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Radicar y Buscar</td>
                                            <td class="text-center perm-no"><i class="bi bi-x-circle-fill text-muted"></i> Restringido</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-folder me-1"></i> Documentos (Radicaci&oacute;n)</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-no"><i class="bi bi-x-circle-fill text-muted"></i> Restringido</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-file-earmark-check me-1"></i> Doc. Registrados</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Consulta y PDF</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-arrow-repeat me-1"></i> Sincronizaci&oacute;n Territorial</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Sincronizar y Ver</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Consulta</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Consulta</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-info-circle me-1"></i> Qui&eacute;nes Somos</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Acceso</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Acceso</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Acceso</td>
                                        </tr>
                                        <tr class="table-danger">
                                            <td><strong><i class="bi bi-people me-1"></i> G. Usuarios</strong></td>
                                            <td class="text-center perm-ok text-danger fw-bold"><i class="bi bi-check-circle-fill"></i> Exclusivo Admin</td>
                                            <td class="text-center perm-no"><i class="bi bi-x-circle-fill text-danger"></i> Bloqueado</td>
                                            <td class="text-center perm-no"><i class="bi bi-x-circle-fill text-danger"></i> Bloqueado</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-bar-chart me-1"></i> Reportes</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Operativo</td>
                                            <td class="text-center perm-no"><i class="bi bi-x-circle-fill text-muted"></i> Restringido</td>
                                        </tr>
                                        <tr class="table-danger">
                                            <td><strong><i class="bi bi-shield-check me-1"></i> Auditor&iacute;a</strong></td>
                                            <td class="text-center perm-ok text-danger fw-bold"><i class="bi bi-check-circle-fill"></i> Exclusivo Admin</td>
                                            <td class="text-center perm-no"><i class="bi bi-x-circle-fill text-danger"></i> Bloqueado</td>
                                            <td class="text-center perm-no"><i class="bi bi-x-circle-fill text-danger"></i> Bloqueado</td>
                                        </tr>
                                        <tr>
                                            <td><strong><i class="bi bi-book me-1"></i> Ayuda y Manual</strong></td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                            <td class="text-center perm-ok"><i class="bi bi-check-circle-fill"></i> Total</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 4: DASHBOARD -->
                        <!-- ========================================================================= -->
                        <div class="cap-pane tab-pane fade" id="cap-4" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-speedometer2 text-info"></i> 4. Dashboard Principal y Métricas de Control
                            </div>

                            <p class="text-muted">
                                El <strong>Dashboard</strong> (<code>dashboard.jsp</code>) es el panel ejecutivo de inicio de SADU. Consolida en una sola pantalla los indicadores clave del estado documental de la instituci&oacute;n.
                            </p>

                            <h6 class="fw-bold text-primary mb-3">Tarjetas de Indicadores Principales:</h6>
                            <div class="row g-3 mb-4">
                                <div class="col-md-3">
                                    <div class="p-3 border rounded text-center bg-white shadow-sm">
                                        <i class="bi bi-file-earmark-text text-primary fs-3"></i>
                                        <h6 class="fw-bold mt-2 mb-0">Total Radicados</h6>
                                        <small class="text-muted">Acumulado hist&oacute;rico de documentos</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded text-center bg-white shadow-sm">
                                        <i class="bi bi-envelope-open text-warning fs-3"></i>
                                        <h6 class="fw-bold mt-2 mb-0">Comunicaciones</h6>
                                        <small class="text-muted">Correspondencias en tr&aacute;mite</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded text-center bg-white shadow-sm">
                                        <i class="bi bi-calendar-check text-success fs-3"></i>
                                        <h6 class="fw-bold mt-2 mb-0">Mes Actual</h6>
                                        <small class="text-muted">Ingresos del per&iacute;odo vigente</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded text-center bg-white shadow-sm">
                                        <i class="bi bi-people text-info fs-3"></i>
                                        <h6 class="fw-bold mt-2 mb-0">Usuarios Activos</h6>
                                        <small class="text-muted">Cuentas con permiso de acceso</small>
                                    </div>
                                </div>
                            </div>

                            <div class="mock-box">
                                <strong class="text-dark"><i class="bi bi-lightning-charge-fill text-warning me-1"></i>Accesos Directos del Dashboard:</strong>
                                <p class="mb-0 mt-1 small text-muted">
                                    El panel ofrece botones r&aacute;pidos para registrar radicados, abrir el chat corporativo, sincronizar datos territoriales o descargar informes gerenciales con un solo clic.
                                </p>
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 5: CHAT ICQ EMPRESARIAL -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-5" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-chat-dots-fill text-success"></i> 5. Chat ICQ Empresarial (Mensajer&iacute;a S&iacute;ncrona en Tiempo Real)
                            </div>

                            <p class="text-muted">
                                El sistema incorpora un m&oacute;dulo de chat corporativo s&iacute;ncrono con est&eacute;tica retro <strong>ICQ</strong>, optimizado para la coordinaci&oacute;n instant&aacute;nea entre la ventanilla de radicaci&oacute;n y las diferentes secretar&iacute;as o dependencias.
                            </p>

                            <h6 class="fw-bold text-dark mt-3 mb-2"><i class="bi bi-app-indicator text-success me-2"></i>Componentes de la Interfaz del Chat:</h6>
                            <ul class="small text-muted mb-3">
                                <li class="mb-2"><strong>Bot&oacute;n Flotante (<code>#chat-fab</code>):</strong> &Iacute;cono circular ubicado en la esquina inferior derecha, visible permanentemente en todas las pantallas del sistema. Muestra un badge rojo parpadeante con el n&uacute;mero de mensajes nuevos no le&iacute;dos.</li>
                                <li class="mb-2"><strong>Control de Audio y Sonido Retro ICQ:</strong> Incluye el ic&oacute;nico sonido <em>"Uh-Oh!"</em>. Puede ser activado o silenciado haciendo clic en el bot&oacute;n de altavoz <code>#btn-icq-sound-toggle</code> del encabezado.</li>
                                <li class="mb-2"><strong>Directorio de Contactos con Presencia en Vivo:</strong> Permite visualizar los funcionarios registrados e indica su estado:
                                    <span class="badge bg-success ms-1">🟢 En L&iacute;nea</span>
                                    <span class="badge bg-primary ms-1">🔵 Escribiendo...</span>
                                    <span class="badge bg-secondary ms-1">⚪ Desconectado</span>
                                </li>
                                <li class="mb-2"><strong>Notas de Voz:</strong> Permite grabar mensajes de audio utilizando el micr&oacute;fono del equipo mediante la API web <code>MediaRecorder</code>.</li>
                                <li class="mb-2"><strong>Im&aacute;genes y Modal a Pantalla Completa:</strong> Permite enviar capturas de pantalla o evidencias fotogr&aacute;ficas. Al hacer clic sobre una imagen en el chat, se abre el visor modal <code>#chat-img-modal</code> para visualizaci&oacute;n ampliada.</li>
                                <li class="mb-2"><strong>Edici&oacute;n y Eliminaci&oacute;n de Mensajes:</strong> Al pasar el cursor sobre un mensaje propio, aparecen los botones de edici&oacute;n (l&aacute;piz) y eliminaci&oacute;n (papelera).</li>
                            </ul>

                            <div class="callout callout-info">
                                <strong><i class="bi bi-lightbulb-fill text-warning me-1"></i>Uso institucional recomendado:</strong> Utilice el campo <strong>Asunto</strong> en el chat para clasificar la consulta (ej. <em>"Consulta Radicado DOC-2025-004"</em>) y facilitar el seguimiento por parte del gestor documental.
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 6: COMUNICACIONES OFICIALES -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-6" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-envelope-paper-fill text-primary"></i> 6. Radicaci&oacute;n y Gesti&oacute;n de Comunicaciones Oficiales
                            </div>

                            <p class="text-muted">
                                Las <strong>Comunicaciones Oficiales</strong> (<code>/comunicaciones</code>) gestionan el tr&aacute;nsito de correspondencia entre dependencias internas y hacia ciudadanos o entidades externas:
                            </p>

                            <h6 class="fw-bold text-dark mt-3 mb-2">Clasificaci&oacute;n de Comunicaciones seg&uacute;n el Flujo:</h6>
                            <div class="row g-2 mb-3">
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light text-center">
                                        <strong class="text-primary d-block">Interna</strong>
                                        <small class="text-muted">Entre secretar&iacute;as, oficinas o despachos de la entidad.</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light text-center">
                                        <strong class="text-success d-block">Externa Recibida</strong>
                                        <small class="text-muted">Originada por la ciudadan&iacute;a o entes externos hacia la entidad.</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light text-center">
                                        <strong class="text-warning d-block">Externa Despachada</strong>
                                        <small class="text-muted">Oficios de salida emitidos por la entidad hacia destinatarios externos.</small>
                                    </div>
                                </div>
                            </div>

                            <div class="card p-3 bg-light border mb-3">
                                <h6 class="fw-bold text-primary mb-2"><i class="bi bi-pencil-square me-1"></i>Campos del Formulario de Radicaci&oacute;n:</h6>
                                <table class="table table-sm table-bordered bg-white small mb-0">
                                    <thead>
                                        <tr class="table-light"><th>Campo</th><th>Descripci&oacute;n y Formato</th><th>Obligatorio</th></tr>
                                    </thead>
                                    <tbody>
                                        <tr><td><strong>N&uacute;mero de Radicado</strong></td><td>Sugerido autom&aacute;ticamente por el sistema seg&uacute;n el a&ntilde;o y consecutivo.</td><td>S&iacute;</td></tr>
                                        <tr><td><strong>Tipo Comunicaci&oacute;n</strong></td><td>Selecci&oacute;n entre Interna, Externa Recibida o Externa Despachada.</td><td>S&iacute;</td></tr>
                                        <tr><td><strong>Asunto</strong></td><td>Descripci&oacute;n clara y resumida del tr&aacute;mite o petici&oacute;n.</td><td>S&iacute;</td></tr>
                                        <tr><td><strong>Remitente</strong></td><td>Persona natural, jur&iacute;dica o dependencia que env&iacute;a.</td><td>S&iacute;</td></tr>
                                        <tr><td><strong>Destinatario</strong></td><td>Funcionario o dependencia responsable de la atenci&oacute;n.</td><td>S&iacute;</td></tr>
                                        <tr><td><strong>Anexos / Digital</strong></td><td>Documento de respaldo digitalizado.</td><td>Opcional</td></tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 7: DOCUMENTOS Y RADICACION -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-7" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-folder-check text-warning"></i> 7. M&oacute;dulo de Documentos y Doc. Registrados
                            </div>

                            <p class="text-muted">
                                El m&oacute;dulo de <strong>Documentos</strong> (<code>/documentos</code>) constituye el n&uacute;cleo de la administraci&oacute;n del fondo acumulado y las series documentales institucionales:
                            </p>

                            <h6 class="fw-bold text-primary mt-3 mb-2"><i class="bi bi-file-earmark-ruled me-1"></i>Tipos Documentales seg&uacute;n TRD (Tablas de Retenci&oacute;n):</h6>
                            <p class="small text-muted mb-2">
                                El sistema admite la clasificaci&oacute;n formal estandarizada: <em>Oficio, Circular, Resoluci&oacute;n, Acta, Contrato, Informe, Memorando, Decreto, Certificado</em> y <em>Otro</em>.
                            </p>

                            <h6 class="fw-bold text-dark mt-3 mb-2"><i class="bi bi-arrow-repeat text-info me-1"></i>Ciclo de Vida y Estados del Documento:</h6>
                            <div class="row g-2 mb-3">
                                <div class="col-md-3">
                                    <div class="p-2 border rounded bg-light text-center">
                                        <span class="badge bg-warning text-dark mb-1">En Proceso</span>
                                        <p class="mb-0 small text-muted">Borrador o revisi&oacute;n jur&iacute;dica previa a la firma.</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-3 border rounded bg-light text-center">
                                        <span class="badge bg-success mb-1">Registrado</span>
                                        <p class="mb-0 small text-muted">Aprobado e incorporado oficialmente al expediente.</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-2 border rounded bg-light text-center">
                                        <span class="badge bg-secondary mb-1">Archivado</span>
                                        <p class="mb-0 small text-muted">Tr&aacute;mite concluido, en custodia del archivo central.</p>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="p-2 border rounded bg-light text-center">
                                        <span class="badge bg-danger mb-1">Anulado</span>
                                        <p class="mb-0 small text-muted">Invalidado formalmente con justificaci&oacute;n en auditor&iacute;a.</p>
                                    </div>
                                </div>
                            </div>

                            <div class="callout callout-success">
                                <strong><i class="bi bi-qr-code me-1"></i>Trazabilidad con C&oacute;digo QR:</strong> Cada documento registrado genera un identificador QR que vincula el radicado con la base de datos de SADU, permitiendo a cualquier dependencia escanear el papel f&iacute;sico y visualizar su hom&oacute;logo digital al instante.
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 8: SINCRONIZACION TERRITORIAL (API COLOMBIA) -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-8" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-globe-americas text-primary"></i> 8. Sincronizaci&oacute;n Territorial y API Colombia
                            </div>

                            <p class="text-muted">
                                En cumplimiento de los est&aacute;ndares de interoperabilidad del Estado colombiano, SADU se integra mediante servicios web REST con la <strong>API Colombia Abierta (api-colombia.com)</strong>:
                            </p>

                            <h6 class="fw-bold text-dark mt-3 mb-2"><i class="bi bi-check-circle-fill text-success me-1"></i>Beneficios Operativos de la Integraci&oacute;n:</h6>
                            <ul class="small text-muted mb-3">
                                <li class="mb-2"><strong>Normalizaci&oacute;n Geogr&aacute;fica DANE (Divipola):</strong> Homologaci&oacute;n oficial de los 32 departamentos y m&aacute;s de 1.100 municipios de Colombia para evitar errores tipogr&aacute;ficos en remitentes y procedencias.</li>
                                <li class="mb-2"><strong>Selects Territoriales Din&aacute;micos en Cascada:</strong> Al seleccionar un departamento en cualquier formulario (Documentos o Usuarios), el select de municipios se actualiza autom&aacute;ticamente v&iacute;a AJAX sin recargar la p&aacute;gina.</li>
                                <li class="mb-2"><strong>Arquitectura de Cach&eacute; Local MySQL:</strong> Los datos sincronizados se preservan en la base de datos local para que la radicaci&oacute;n nunca se detenga aun si la conexi&oacute;n a internet externa experimenta lentitud.</li>
                            </ul>

                            <div class="mock-box">
                                <strong class="text-primary"><i class="bi bi-arrow-repeat me-1"></i>M&oacute;dulo de Sincronizaci&oacute;n (<code>/sincronizacion_territorial.jsp</code>):</strong>
                                <p class="mb-0 mt-1 small text-muted">
                                    Los Administradores pueden pulsar el bot&oacute;n "Forzar Sincronizaci&oacute;n" para descargar los &uacute;ltimos c&oacute;digos DANE y actualizar las tablas territoriales locales.
                                </p>
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 9: QUIENES SOMOS -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-9" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-info-circle-fill text-secondary"></i> 9. Qui&eacute;nes Somos y Marco Institucional
                            </div>

                            <p class="text-muted">
                                El m&oacute;dulo <strong>Qui&eacute;nes Somos</strong> (<code>quienes_somos.jsp</code>) presenta la identidad corporativa, objetivos de calidad y ficha t&eacute;cnica de desarrollo de SADU:
                            </p>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <div class="p-3 border rounded bg-light">
                                        <h6 class="fw-bold text-primary mb-1">Misi&oacute;n Institucional</h6>
                                        <p class="small text-muted mb-0">Centralizar, agilizar y transparentar la administraci&oacute;n documental p&uacute;blica, erradicando barreras burocr&aacute;ticas mediante el uso eficiente de las tecnolog&iacute;as de la informaci&oacute;n.</p>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="p-3 border rounded bg-light">
                                        <h6 class="fw-bold text-primary mb-1">Visi&oacute;n Prospectiva</h6>
                                        <p class="small text-muted mb-0">Consolidar a SADU como la plataforma de gesti&oacute;n documental l&iacute;der en el sector gubernamental, referente de interoperabilidad, auditor&iacute;a y cero papel.</p>
                                    </div>
                                </div>
                            </div>

                            <div class="p-3 border rounded bg-white">
                                <h6 class="fw-bold text-dark mb-1">Ficha T&eacute;cnica del Proyecto Formativo</h6>
                                <p class="small text-muted mb-0">
                                    <strong>Instituci&oacute;n:</strong> Servicio Nacional de Aprendizaje (SENA) &bull; 
                                    <strong>Programa:</strong> ADSO (An&aacute;lisis y Desarrollo de Software) &bull; 
                                    <strong>Ficha:</strong> 3186583 &bull; 
                                    <strong>Autor:</strong> Samuel Enrique Burbano Castro &bull; 
                                    <strong>Instructor Evaluador:</strong> Luis Alfonso Becerra Renter&iacute;a.
                                </p>
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 10: ADMINISTRACION Y AUDITORIA -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-10" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-shield-lock-fill text-danger"></i> 10. Administraci&oacute;n de Usuarios y Auditor&iacute;a Forense
                            </div>

                            <div class="callout callout-danger">
                                <strong><i class="bi bi-exclamation-triangle-fill me-1"></i>M&oacute;dulos de Acceso Exclusivo para el Rol 1 (Administrador):</strong> Las opciones descritas a continuaci&oacute;n est&aacute;n blindadas por el sistema mediante <code>VerificadorRol.verificar(request, response, 1)</code>.
                            </div>

                            <h5 class="fw-bold text-dark mt-4 mb-2"><i class="bi bi-person-gear text-primary me-2"></i>10.1 Gesti&oacute;n de Usuarios (<code>/usuarios</code>)</h5>
                            <p class="small text-muted mb-2">Permite la gobernanza integral de las cuentas de acceso al sistema con campos 100% en castellano:</p>
                            <ul class="small text-muted mb-3">
                                <li><strong>Nombre Completo:</strong> Identificaci&oacute;n del funcionario.</li>
                                <li><strong>Correo Electr&oacute;nico:</strong> Cuenta institucional receptora de c&oacute;digos de seguridad y notificaciones.</li>
                                <li><strong>Nombre de Usuario:</strong> Credencial de acceso &uacute;nica en el sistema.</li>
                                <li><strong>Rol / Nivel de Privilegios:</strong> Asignaci&oacute;n de perfil: 1 (Administrador), 2 (Gestor de Archivo) o 3 (Dependencia Municipal).</li>
                                <li><strong>Estado de la Cuenta:</strong> Conmutaci&oacute;n entre <em>Activo</em> e <em>Inactivo</em> (desactivaci&oacute;n inmediata por retiro o incapacidad).</li>
                            </ul>

                            <h5 class="fw-bold text-dark mt-4 mb-2"><i class="bi bi-journal-text text-danger me-2"></i>10.2 Bit&aacute;cora de Auditor&iacute;a Inmutable (<code>/auditoria</code>)</h5>
                            <p class="small text-muted mb-2">
                                De acuerdo con los principios probatorios de la <strong>Ley 527 de 1999</strong> y la <strong>Ley 594 de 2000</strong>, SADU registra de forma cronol&oacute;gica e inalterable cada transacci&oacute;n a trav&eacute;s de <code>LogAuditoriaDAO</code>:
                            </p>
                            <table class="table table-sm table-bordered bg-white small mb-3">
                                <thead class="table-dark">
                                    <tr><th>Dato Registrado</th><th>Descripci&oacute;n T&eacute;cnica</th><th>Finalidad Legal</th></tr>
                                </thead>
                                <tbody>
                                    <tr><td><strong>Timestamp</strong></td><td>Fecha, hora, minuto y segundo exacto del servidor.</td><td>L&iacute;nea temporal del hecho.</td></tr>
                                    <tr><td><strong>Usuario Responsable</strong></td><td>ID y nombre del funcionario que ejecut&oacute; la acci&oacute;n.</td><td>Atribuci&oacute;n y autor&iacute;a.</td></tr>
                                    <tr><td><strong>Direcci&oacute;n IP</strong></td><td>IP de la m&aacute;quina cliente que envi&oacute; la petici&oacute;n HTTP.</td><td>Ubicaci&oacute;n del puesto de trabajo.</td></tr>
                                    <tr><td><strong>Acci&oacute;n Cr&iacute;tica</strong></td><td>LOGIN, LOGOUT, CREATE, UPDATE, DELETE, etc.</td><td>Tipo de evento ejecutado.</td></tr>
                                    <tr><td><strong>Detalle / Registro</strong></td><td>Descripci&oacute;n espec&iacute;fica del radicado o usuario afectado.</td><td>Evidencia del cambio realizado.</td></tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 11: REPORTES Y ESTADISTICAS -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-11" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-bar-chart-line-fill text-info"></i> 11. M&oacute;dulo de Reportes Estad&iacute;sticos y Gr&aacute;ficos
                            </div>

                            <p class="text-muted">
                                El m&oacute;dulo de <strong>Reportes</strong> (<code>/reportes</code>) ofrece tableros visuales interactivos impulsados por <strong>Chart.js</strong> para el an&aacute;lisis de gesti&oacute;n documental:
                            </p>

                            <h6 class="fw-bold text-dark mt-3 mb-2">Gr&aacute;ficos e Informes Disponibles:</h6>
                            <div class="row g-2 mb-3">
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light">
                                        <strong class="text-primary small d-block">1. Documentos por Estado</strong>
                                        <span class="text-muted" style="font-size: 11.5px;">Distribuci&oacute;n porcentual: En Proceso, Registrados y Archivados.</span>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light">
                                        <strong class="text-primary small d-block">2. Documentos por Tipo</strong>
                                        <span class="text-muted" style="font-size: 11.5px;">Volumen comparativo: Oficios, Circulares, Actas, Resoluciones.</span>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light">
                                        <strong class="text-primary small d-block">3. Radicaci&oacute;n Mensual</strong>
                                        <span class="text-muted" style="font-size: 11.5px;">Curva de evoluci&oacute;n y carga documental mes a mes.</span>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light">
                                        <strong class="text-primary small d-block">4. Volumen por Dependencia</strong>
                                        <span class="text-muted" style="font-size: 11.5px;">Carga de trabajo por secretar&iacute;a o despacho municipal.</span>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light">
                                        <strong class="text-primary small d-block">5. Comunicaciones Oficiales</strong>
                                        <span class="text-muted" style="font-size: 11.5px;">Proporci&oacute;n de correspondencias internas vs externas.</span>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="p-2 border rounded bg-light">
                                        <strong class="text-primary small d-block">6. Eventos de Auditor&iacute;a</strong>
                                        <span class="text-muted" style="font-size: 11.5px;">M&eacute;tricas de seguridad y operaciones m&aacute;s frecuentes.</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- ========================================================================= -->
                        <!-- CAPITULO 12: PREGUNTAS FRECUENTES Y SOPORTE -->
                        <!-- ========================================================================= -->
                        <div class="tab-pane fade" id="cap-12" role="tabpanel">
                            <div class="chapter-title">
                                <i class="bi bi-question-circle-fill text-warning"></i> 12. Preguntas Frecuentes, Glosario y Mesa de Ayuda
                            </div>

                            <div class="accordion mb-4" id="faqAccordion">
                                
                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="faq-h1">
                                        <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq-c1">
                                            <strong>1. &iquest;C&oacute;mo descargo el Manual Oficial en Word (.docx) para evaluaci&oacute;n del SENA?</strong>
                                        </button>
                                    </h2>
                                    <div id="faq-c1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body small text-muted">
                                            Haga clic en el bot&oacute;n dorado <strong>"Descargar .docx (4.4 MB)"</strong> ubicado en el banner superior de esta pantalla. El archivo <code>Manual_de_Usuario_Unificado_SADU_SENA.docx</code> se descargar&aacute; autom&aacute;ticamente en su computador, listo para editar y presentar.
                                        </div>
                                    </div>
                                </div>

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="faq-h2">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq-c2">
                                            <strong>2. &iquest;Por qu&eacute; no aparecen los men&uacute;s de "G. Usuarios" o "Auditor&iacute;a" en mi barra lateral?</strong>
                                        </button>
                                    </h2>
                                    <div id="faq-c2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body small text-muted">
                                            Por pol&iacute;tica de seguridad (RBAC), los m&oacute;dulos administrativos est&aacute;n reservados exclusivamente para el <strong>Rol 1: Administrador</strong>. Si su cuenta tiene Rol 2 (Gestor de Archivo) o Rol 3 (Dependencia Municipal), el men&uacute; oculta autom&aacute;ticamente esas opciones.
                                        </div>
                                    </div>
                                </div>

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="faq-h3">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq-c3">
                                            <strong>3. &iquest;Qu&eacute; hago si olvid&eacute; mi contrase&ntilde;a?</strong>
                                        </button>
                                    </h2>
                                    <div id="faq-c3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body small text-muted">
                                            En la pantalla de inicio de sesi&oacute;n, presione <em>"&iquest;Olvidaste tu contrase&ntilde;a?"</em>, digite su correo corporativo y siga el asistente de recuperaci&oacute;n. Recibir&aacute; un c&oacute;digo de seguridad temporal de 6 d&iacute;gitos para establecer una nueva clave.
                                        </div>
                                    </div>
                                </div>

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="faq-h4">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq-c4">
                                            <strong>4. &iquest;Qu&eacute; formato de archivos est&aacute; permitido para los adjuntos de radicados?</strong>
                                        </button>
                                    </h2>
                                    <div id="faq-c4" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body small text-muted">
                                            El est&aacute;ndar documental oficial exige formato <strong>PDF</strong> para preservar la integridad visual y firma del documento. Para anexos en el Chat ICQ se admiten im&aacute;genes (JPG, PNG, WebP) y notas de voz en audio (WebM).
                                        </div>
                                    </div>
                                </div>

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="faq-h5">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq-c5">
                                            <strong>5. &iquest;C&oacute;mo activo o silencio el sonido del Chat ICQ?</strong>
                                        </button>
                                    </h2>
                                    <div id="faq-c5" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body small text-muted">
                                            Abra el panel de chat haciendo clic en el bot&oacute;n flotante <code>#chat-fab</code> y en la cabecera presione el bot&oacute;n de altavoz <code>#btn-icq-sound-toggle</code>. El &iacute;cono cambiar&aacute; a rojo cuando est&eacute; silenciado.
                                        </div>
                                    </div>
                                </div>

                            </div>

                            <div class="card p-3 bg-light border">
                                <h6 class="fw-bold text-primary mb-2"><i class="bi bi-headset me-2"></i>Mesa de Ayuda y Soporte T&eacute;cnico Institucional</h6>
                                <p class="small text-muted mb-1">Si requiere asistencia t&eacute;cnica adicional o reporte de incidencias:</p>
                                <ul class="small text-muted mb-0">
                                    <li><strong>Correo Electr&oacute;nico de Soporte:</strong> <code>soporte.sadu@institucion.gov.co</code></li>
                                    <li><strong>L&iacute;nea de Atenci&oacute;n Interna:</strong> Extensi&oacute;n 104 - &Aacute;rea de Tecnolog&iacute;a e Inform&aacute;tica</li>
                                    <li><strong>Horario de Atenci&oacute;n:</strong> Lunes a Viernes de 8:00 AM a 5:00 PM</li>
                                </ul>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </div>

    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Script de Filtros Interactivos -->
    <script>
        function filtrarVistaRol(rol) {
            // Activar botón de filtro seleccionado
            document.querySelectorAll('.filter-btn-group .btn').forEach(b => b.classList.remove('active'));
            event.currentTarget.classList.add('active');

            // Abrir automáticamente el Capítulo 3 si se selecciona un rol específico
            if (rol !== 'todos') {
                const triggerEl = document.querySelector('#tab-3-link');
                const tab = bootstrap.Tab.getOrCreateInstance(triggerEl);
                tab.show();

                // Desplazar suavemente a la caja del rol correspondiente
                setTimeout(() => {
                    let targetBox = null;
                    if (rol === 'rol1') targetBox = document.getElementById('guia-rol-1');
                    else if (rol === 'rol2') targetBox = document.getElementById('guia-rol-2');
                    else if (rol === 'rol3') targetBox = document.getElementById('guia-rol-3');

                    if (targetBox) {
                        targetBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        targetBox.style.boxShadow = '0 0 20px rgba(59, 130, 246, 0.4)';
                        setTimeout(() => { targetBox.style.boxShadow = ''; }, 2000);
                    }
                }, 150);
            }
        }

        function filtrarCapitulosLista() {
            const query = document.getElementById('filtroCapituloInput').value.toLowerCase();
            const items = document.querySelectorAll('#manualListTab .list-group-item');
            
            items.forEach(item => {
                const text = item.innerText.toLowerCase();
                if (text.includes(query)) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
