<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    /* Validar sesión activa */
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    String rolUsuarioStr = sesion.getAttribute("rolUsuario") != null ? String.valueOf(sesion.getAttribute("rolUsuario")) : "0";
    boolean puedeEditar = "1".equals(rolUsuarioStr) || "2".equals(rolUsuarioStr) || "ADMINISTRADOR".equalsIgnoreCase(rolUsuarioStr) || "GESTOR".equalsIgnoreCase(rolUsuarioStr);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Microfilmes y Fotograf&iacute;as - SADU</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        body { margin: 0; background-color: #f4f6f9; font-family: Arial, sans-serif; }
        .content { margin-left: 230px; padding: 25px 30px; min-height: 100vh; }
        
        .topbar {
            background: white; padding: 14px 22px; border-radius: 10px;
            margin-bottom: 22px; box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            display: flex; justify-content: space-between; align-items: center;
        }
        .topbar h4 { margin: 0; font-size: 19px; font-weight: bold; color: #1f3b57; }
        
        /* Banner de Tipos de Microfilminas */
        .tipos-microfilm-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 14px; margin-bottom: 22px;
        }
        .tipo-card {
            background: white; border-radius: 10px; padding: 15px; border-top: 4px solid #1f3b57;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05); cursor: pointer; transition: all 0.2s;
        }
        .tipo-card:hover { transform: translateY(-3px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .tipo-card h6 { font-size: 13.5px; font-weight: bold; margin-bottom: 4px; display: flex; align-items: center; gap: 6px; }
        .tipo-card p { font-size: 11.5px; color: #64748b; margin: 0; line-height: 1.35; }

        /* Panel Principal */
        .card-panel {
            background: white; border-radius: 14px; padding: 22px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.07); margin-bottom: 22px;
        }
        
        /* Buscador OCR */
        .search-ocr-container {
            background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;
            padding: 16px; margin-bottom: 20px;
        }
        .search-ocr-input {
            border-radius: 8px; border: 2px solid #cbd5e1; font-size: 14px; padding: 10px 14px;
        }
        .search-ocr-input:focus {
            border-color: #1f3b57; box-shadow: 0 0 0 3px rgba(31,59,87,0.15);
        }

        /* Tabla y Badges Específicos */
        .table-custom th {
            background-color: #1f3b57; color: white; font-size: 13px; font-weight: 600;
            padding: 12px 10px; text-transform: uppercase; letter-spacing: 0.5px;
        }
        .table-custom td {
            font-size: 13px; vertical-align: middle; padding: 10px;
        }
        .badge-soporte {
            font-size: 11px; padding: 5px 9px; border-radius: 6px; font-weight: 600; text-transform: uppercase;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .badge-16mm { background-color: #e0e7ff; color: #3730a3; border: 1px solid #c7d2fe; }
        .badge-35mm { background-color: #fce7f3; color: #9d174d; border: 1px solid #fbcfe8; }
        .badge-microficha { background-color: #e0f2fe; color: #075985; border: 1px solid #bae6fd; }
        .badge-jacket { background-color: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .badge-apertura { background-color: #f3e8ff; color: #6b21a8; border: 1px solid #e9d5ff; }
        .badge-foto { background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .badge-negativo { background-color: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }

        .thumbnail-box {
            width: 50px; height: 50px; border-radius: 6px;
            background: #e2e8f0; border: 1px solid #cbd5e1; display: inline-flex;
            align-items: center; justify-content: center; color: #1f3b57; font-size: 20px;
            cursor: pointer; transition: transform 0.2s;
        }
        .thumbnail-box:hover { transform: scale(1.1); box-shadow: 0 4px 10px rgba(0,0,0,0.15); background:#dbeafe; }
        
        .ocr-preview {
            max-width: 290px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            font-size: 12px; color: #475569; font-style: italic; background: #f1f5f9;
            padding: 3px 8px; border-radius: 4px; display: block; border-left: 3px solid #f59e0b;
        }

        .btn-sadu {
            background-color: #1f3b57; color: white; border: none; font-size: 13.5px;
            padding: 9px 16px; border-radius: 7px; font-weight: 600; transition: background 0.2s;
        }
        .btn-sadu:hover { background-color: #162d42; color: white; }
    </style>
</head>
<body>

    <!-- Menú Lateral Unificado SADU -->
    <%@ include file="sidebar.jsp" %>

    <div class="content">

        <!-- Topbar -->
        <div class="topbar">
            <div>
                <h4><i class="bi bi-film me-2"></i> Microfilmes, Fotograf&iacute;as y Reconocimiento OCR</h4>
                <small class="text-muted">Gesti&oacute;n integral de soportes anal&oacute;gicos, preservaci&oacute;n y b&uacute;squeda de texto indexado</small>
            </div>
            <div>
                <span class="badge bg-secondary me-2"><i class="bi bi-person-circle"></i> <%= nombreUsuario %></span>
                <% if (puedeEditar) { %>
                    <button class="btn btn-sadu" data-bs-toggle="modal" data-bs-target="#modalNuevoSoporte">
                        <i class="bi bi-plus-circle me-1"></i> Nuevo Registro
                    </button>
                <% } %>
            </div>
        </div>

        <!-- Banner de Tipos de Microfilminas -->
        <div class="tipos-microfilm-grid">
            <div class="tipo-card" onclick="filtrarPorTipoDirecto('MICROFILM_16MM')" style="border-top-color: #4f46e5;">
                <h6 class="text-indigo" style="color:#4f46e5;"><i class="bi bi-film"></i> Rollo 16 mm</h6>
                <p><strong>Uso:</strong> Correspondencia, actas, oficios y resoluciones tamaño carta/oficio. Hasta 2.500 páginas por rollo.</p>
            </div>
            <div class="tipo-card" onclick="filtrarPorTipoDirecto('MICROFILM_35MM')" style="border-top-color: #db2777;">
                <h6 class="text-pink" style="color:#db2777;"><i class="bi bi-newspaper"></i> Rollo 35 mm</h6>
                <p><strong>Uso:</strong> Prensa histórica, gacetas universitarias, libros antiguos y actas encuadernadas de gran formato.</p>
            </div>
            <div class="tipo-card" onclick="filtrarPorTipoDirecto('MICROFICHA')" style="border-top-color: #0284c7;">
                <h6 class="text-sky" style="color:#0284c7;"><i class="bi bi-grid-3x3"></i> Microficha</h6>
                <p><strong>Uso:</strong> Matriz plana de 105x148 mm para expedientes académicos, tesis de grado y catálogos bibliográficos.</p>
            </div>
            <div class="tipo-card" onclick="filtrarPorTipoDirecto('JACKET_MICROFILM')" style="border-top-color: #d97706;">
                <h6 class="text-amber" style="color:#d97706;"><i class="bi bi-folder2-open"></i> Jacket (Funda)</h6>
                <p><strong>Uso:</strong> Fundas de poliéster con canales para tiras de 16mm. Ideal para expedientes de personal actualizables.</p>
            </div>
            <div class="tipo-card" onclick="filtrarPorTipoDirecto('TARJETA_APERTURA')" style="border-top-color: #9333ea;">
                <h6 class="text-purple" style="color:#9333ea;"><i class="bi bi-card-heading"></i> Tarjeta Apertura</h6>
                <p><strong>Uso:</strong> Tarjeta perforada con ventana para fotograma de 35mm. Diseñada para planos arquitectónicos e ingeniería.</p>
            </div>
        </div>

        <!-- Panel de Filtro y Búsqueda OCR -->
        <div class="card-panel">
            <div class="search-ocr-container">
                <div class="row g-2 align-items-center">
                    <div class="col-md-7">
                        <label class="form-label fw-bold mb-1" style="font-size:13px;">
                            <i class="bi bi-search me-1 text-primary"></i> B&uacute;squeda Full-Text en Texto Extra&iacute;do por OCR:
                        </label>
                        <div class="input-group">
                            <input type="text" id="inputBuscarOCR" class="form-control search-ocr-input" 
                                   placeholder="Palabras clave (ej: presupuesto, gaceta, rectoría, tesis, plano, escalafón)...">
                            <button class="btn btn-sadu px-4" type="button" onclick="buscarPorOCR()">
                                <i class="bi bi-search"></i> Buscar OCR
                            </button>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold mb-1" style="font-size:13px;">Filtrar por Formato:</label>
                        <select id="selectFiltroTipo" class="form-select" onchange="cambiarFiltroTipo()">
                            <option value="TODOS" selected>Todos los soportes</option>
                            <option value="MICROFILM_16MM">Rollo 16 mm (Actas/Correspondencia)</option>
                            <option value="MICROFILM_35MM">Rollo 35 mm (Gacetas/Prensa)</option>
                            <option value="MICROFICHA">Microficha Plana (Tesis/Expedientes)</option>
                            <option value="JACKET_MICROFILM">Jacket / Funda (Historias Laborales)</option>
                            <option value="TARJETA_APERTURA">Tarjeta de Apertura (Planos)</option>
                            <option value="FOTOGRAFIA">Fotograf&iacute;a Hist&oacute;rica</option>
                            <option value="NEGATIVO">Negativo Fotogr&aacute;fico</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-end pt-4">
                        <button class="btn btn-outline-secondary w-100" type="button" onclick="cargarTodos()">
                            <i class="bi bi-arrow-clockwise"></i> Restablecer
                        </button>
                    </div>
                </div>
            </div>

            <!-- Tabla de Soportes Especiales -->
            <div class="table-responsive">
                <table class="table table-hover table-custom table-bordered align-middle mb-0">
                    <thead>
                        <tr>
                            <th style="width: 70px;">Visual</th>
                            <th>Documento Asociado</th>
                            <th>Tipo de Soporte</th>
                            <th>Ubicaci&oacute;n F&iacute;sica (Rollo / Frame)</th>
                            <th>Texto OCR Indexado</th>
                            <th>Par&aacute;metros T&eacute;cnicos</th>
                            <th style="width: 90px;">Detalle</th>
                        </tr>
                    </thead>
                    <tbody id="tablaSoportesBody">
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">
                                <div class="spinner-border spinner-border-sm text-primary me-2"></div>
                                Consultando microfilmes y fotografías en SADU...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- MODAL NUEVO SOPORTE ESPECIAL -->
    <div class="modal fade" id="modalNuevoSoporte" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white" style="background:#1f3b57 !important;">
                    <h5 class="modal-title font-weight-bold">
                        <i class="bi bi-plus-circle me-1"></i> Registrar Microfilmina / Fotograf&iacute;a
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form id="formNuevoSoporte" onsubmit="guardarNuevoSoporte(event)">
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">ID Documento SADU <span class="text-danger">*</span></label>
                                <input type="number" id="regIdDoc" class="form-control" placeholder="Ej: 1" required>
                                <small class="text-muted">ID del documento registrado en el sistema</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Tipo de Microfilmina / Soporte <span class="text-danger">*</span></label>
                                <select id="regTipoSoporte" class="form-select" required>
                                    <option value="MICROFILM_16MM">MICROFILM_16MM - Rollo 16 mm (Actas/Correspondencia)</option>
                                    <option value="MICROFILM_35MM">MICROFILM_35MM - Rollo 35 mm (Gacetas/Prensa Histórica)</option>
                                    <option value="MICROFICHA">MICROFICHA - Ficha Plana (Expedientes/Tesis)</option>
                                    <option value="JACKET_MICROFILM">JACKET_MICROFILM - Funda de Canales (Historias Laborales)</option>
                                    <option value="TARJETA_APERTURA">TARJETA_APERTURA - Tarjeta con ventana (Planos)</option>
                                    <option value="FOTOGRAFIA">FOTOGRAFIA - Copia fotográfica en papel</option>
                                    <option value="NEGATIVO">NEGATIVO - Película negativa original</option>
                                    <option value="DIAPOSITIVA">DIAPOSITIVA - Soporte positivo transparente</option>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Caja / Rollo / Fichero F&iacute;sico</label>
                                <input type="text" id="regRollo" class="form-control" placeholder="Ej: ROLLO-16MM-ACTAS-1985">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">N&uacute;mero de Fotograma / Cuadr&iacute;cula / Frame</label>
                                <input type="text" id="regFrame" class="form-control" placeholder="Ej: FRAME-0142 o COL-3-FILA-4">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Ruta M&aacute;ster de Preservaci&oacute;n (TIFF)</label>
                                <input type="text" id="regRutaTiff" class="form-control" placeholder="storage/masters/16mm_actas_1985.tiff">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Ruta Acceso Web (WebP/JPEG) <span class="text-danger">*</span></label>
                                <input type="text" id="regRutaWeb" class="form-control" placeholder="storage/web/16mm_actas_1985.webp" required>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-bold">Resoluci&oacute;n (DPI)</label>
                                <input type="number" id="regDpi" class="form-control" value="400">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Profundidad Crom&aacute;tica</label>
                                <input type="text" id="regColor" class="form-control" value="Escala de grises (8-bit)">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Checksum SHA-256 (PREMIS)</label>
                                <input type="text" id="regHash" class="form-control" placeholder="Firma de integridad">
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Texto Extra&iacute;do por OCR (para b&uacute;squeda textual indexada)</label>
                                <textarea id="regOcr" class="form-control" rows="3" placeholder="Pegue el texto transcrito o reconocido por OCR del fotograma..."></textarea>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Diagn&oacute;stico de Conservaci&oacute;n Anal&oacute;gica</label>
                                <input type="text" id="regObservaciones" class="form-control" placeholder="Ej: Película en sales de plata sobre poliéster, sin olor a vinagre.">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-sadu">Guardar en Base de Datos</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL DETALLE / VISOR PROFESIONAL DE MICROFILMES Y MEDIOS -->
    <div class="modal fade" id="modalVisor" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white" style="background:#1f3b57 !important;">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-film text-warning" style="font-size:20px;"></i>
                        <div>
                            <h5 class="modal-title font-weight-bold mb-0" id="visorTitulo" style="font-size:16px;">Lector de Microfilm y Medios</h5>
                            <small class="text-white-50" style="font-size:11px;">Inspección visual de preservación digital, emulsión y texto OCR</small>
                        </div>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-4">
                        <!-- Columna Izquierda: Visor Interactivo con Controles -->
                        <div class="col-lg-7">
                            <!-- Barra de Herramientas de Lector de Microfilmes -->
                            <div class="d-flex justify-content-between align-items-center p-2 mb-2 bg-dark rounded text-white" style="background:#1e293b !important;">
                                <div class="d-flex gap-1">
                                    <button class="btn btn-sm btn-outline-light" onclick="zoomVisor(0.2)" title="Acercar (Zoom In)"><i class="bi bi-zoom-in"></i></button>
                                    <button class="btn btn-sm btn-outline-light" onclick="zoomVisor(-0.2)" title="Alejar (Zoom Out)"><i class="bi bi-zoom-out"></i></button>
                                    <button class="btn btn-sm btn-outline-light" onclick="rotarVisor()" title="Girar 90°"><i class="bi bi-arrow-clockwise"></i></button>
                                    <button class="btn btn-sm btn-outline-warning" id="btnPolaridad" onclick="togglePolaridad()" title="Invertir Polaridad (Negativo / Positivo)"><i class="bi bi-circle-half"></i> Negativo/Positivo</button>
                                </div>
                                <div>
                                    <button class="btn btn-sm btn-outline-secondary text-white" onclick="resetVisor()" title="Restablecer Vista"><i class="bi bi-arrow-counterclockwise"></i> Reset</button>
                                </div>
                            </div>

                            <!-- Lienzo del Fotograma -->
                            <div id="visorLienzoContenedor" style="height:380px; background:#0f172a; border-radius:10px; overflow:hidden; position:relative; display:flex; align-items:center; justify-content:center; box-shadow:inset 0 0 20px rgba(0,0,0,0.8);">
                                <div id="visorElementoTransform" style="transition:transform 0.2s ease-out, filter 0.2s ease-out; transform-origin:center center; width:85%; max-height:85%;">
                                    <!-- Fotograma Estilizado con Perforaciones de Microfilm -->
                                    <div id="visorMicrofilmFrame" style="background:#111827; border:3px solid #374151; border-radius:8px; padding:18px; color:#e2e8f0; font-family:'Courier New', monospace; box-shadow:0 8px 25px rgba(0,0,0,0.6); position:relative;">
                                        <!-- Perforaciones laterales de película (Sprocket holes) -->
                                        <div style="position:absolute; top:4px; left:0; right:0; display:flex; justify-content:space-around; opacity:0.35;">
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                        </div>
                                        
                                        <div class="text-center pt-2 pb-1 border-bottom border-secondary mb-2">
                                            <small style="letter-spacing:1px; color:#94a3b8; font-size:10px;" id="visorFrameHeader">ARCHIVO CENTRAL UNIVERSITARIO • FOTOGRAMA MÁSTER</small>
                                        </div>
                                        <p id="visorFrameTexto" style="font-size:12px; line-height:1.5; color:#cbd5e1; margin-bottom:0; min-height:140px;"></p>
                                        
                                        <div style="position:absolute; bottom:4px; left:0; right:0; display:flex; justify-content:space-around; opacity:0.35;">
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                            <span style="width:7px; height:7px; background:#000; border-radius:2px;"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <small class="text-muted d-block text-center mt-2" style="font-size:11px;" id="visorRutaText">Ruta: storage/masters/...</small>
                        </div>

                        <!-- Columna Derecha: Metadatos y Texto OCR Completo -->
                        <div class="col-lg-5 text-start">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <h6 class="fw-bold text-primary mb-0"><i class="bi bi-file-text me-1"></i> Texto Indexado por OCR:</h6>
                                <button class="btn btn-sm btn-outline-secondary" onclick="copiarTextoOcr()" id="btnCopiarOcr" title="Copiar al portapapeles" style="font-size:11px;">
                                    <i class="bi bi-clipboard"></i> Copiar
                                </button>
                            </div>
                            <div id="visorTextoOcr" class="p-3 bg-light border rounded text-secondary mb-3" style="font-size:12.5px; height:150px; overflow-y:auto; line-height:1.5;"></div>

                            <h6 class="fw-bold text-success mb-2"><i class="bi bi-shield-check me-1"></i> Metadatos de Preservación Digital:</h6>
                            <div class="p-2 bg-light border rounded" style="max-height:170px; overflow-y:auto;">
                                <ul class="list-unstyled mb-0" style="font-size:12px; line-height:1.6;" id="visorMetadatos"></ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        let soportesMemoria = [];

        document.addEventListener("DOMContentLoaded", function() {
            cargarTodos();
        });

        function filtrarPorTipoDirecto(tipo) {
            document.getElementById("selectFiltroTipo").value = tipo;
            cambiarFiltroTipo();
        }

        function cambiarFiltroTipo() {
            const tipo = document.getElementById("selectFiltroTipo").value;
            if (tipo === "TODOS") {
                cargarTodos();
            } else {
                cargarSoportesPorTipo(tipo);
            }
        }

        function cargarSoportesPorTipo(tipo) {
            mostrarCargando();
            fetch("api/soporte-especial?tipo=" + encodeURIComponent(tipo))
                .then(r => r.json())
                .then(data => {
                    soportesMemoria = data;
                    renderizarTabla(data);
                })
                .catch(err => {
                    console.error("Error al cargar:", err);
                    mostrarError("No se pudieron cargar los registros. Verifique que la tabla en BD esté creada.");
                });
        }

        function cargarTodos() {
            document.getElementById("inputBuscarOCR").value = "";
            mostrarCargando();
            // Solicitamos a la API
            fetch("api/soporte-especial?tipo=TODOS")
                .then(r => r.json())
                .then(data => {
                    soportesMemoria = data;
                    renderizarTabla(data);
                })
                .catch(err => {
                    mostrarError("Error al conectar con la API de SADU.");
                });
        }

        function buscarPorOCR() {
            const query = document.getElementById("inputBuscarOCR").value.trim();
            if (!query) {
                alert("Por favor ingrese un término de búsqueda para consultar en el OCR.");
                return;
            }
            mostrarCargando();
            fetch("api/soporte-especial?ocr=" + encodeURIComponent(query))
                .then(r => r.json())
                .then(data => {
                    soportesMemoria = data;
                    renderizarTabla(data);
                })
                .catch(err => {
                    mostrarError("Error al consultar el OCR en la base de datos.");
                });
        }

        function renderizarTabla(lista) {
            const tbody = document.getElementById("tablaSoportesBody");
            if (!lista || lista.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4 text-muted"><i class="bi bi-info-circle me-1"></i> No se encontraron registros con los criterios seleccionados.</td></tr>';
                return;
            }

            let html = "";
            lista.forEach((s, idx) => {
                let badgeClass = "badge-16mm";
                let icono = "bi-film";
                let labelTipo = s.tipoSoporte;

                if (s.tipoSoporte === "MICROFILM_16MM" || s.tipoSoporte === "MICROFILMINA") {
                    badgeClass = "badge-16mm";
                    icono = "bi-film";
                    labelTipo = "Rollo 16mm";
                } else if (s.tipoSoporte === "MICROFILM_35MM") {
                    badgeClass = "badge-35mm";
                    icono = "bi-newspaper";
                    labelTipo = "Rollo 35mm";
                } else if (s.tipoSoporte === "MICROFICHA") {
                    badgeClass = "badge-microficha";
                    icono = "bi-grid-3x3";
                    labelTipo = "Microficha";
                } else if (s.tipoSoporte === "JACKET_MICROFILM") {
                    badgeClass = "badge-jacket";
                    icono = "bi-folder2-open";
                    labelTipo = "Jacket";
                } else if (s.tipoSoporte === "TARJETA_APERTURA") {
                    badgeClass = "badge-apertura";
                    icono = "bi-card-heading";
                    labelTipo = "Tarjeta Apertura";
                } else if (s.tipoSoporte === "FOTOGRAFIA") {
                    badgeClass = "badge-foto";
                    icono = "bi-camera";
                    labelTipo = "Fotografía";
                } else if (s.tipoSoporte === "NEGATIVO") {
                    badgeClass = "badge-negativo";
                    icono = "bi-file-earmark-slides";
                    labelTipo = "Negativo";
                }

                html += '<tr>' +
                    '<td class="text-center">' +
                        '<div class="thumbnail-box" onclick="abrirVisor(' + idx + ')" title="Ver objeto visual">' +
                            '<i class="bi ' + icono + '"></i>' +
                        '</div>' +
                    '</td>' +
                    '<td>' +
                        '<strong class="text-dark">' + escapeHtml(s.codigoDocumento || ('DOC-' + s.idDocumento)) + '</strong><br>' +
                        '<small class="text-muted">' + escapeHtml(s.nombreDocumento || ('Documento SADU #' + s.idDocumento)) + '</small>' +
                    '</td>' +
                    '<td>' +
                        '<span class="badge-soporte ' + badgeClass + '"><i class="bi ' + icono + '"></i> ' + labelTipo + '</span>' +
                    '</td>' +
                    '<td>' +
                        '<strong>' + escapeHtml(s.rolloCaja || 'N/A') + '</strong><br>' +
                        '<small class="text-secondary"><i class="bi bi-geo-alt"></i> ' + escapeHtml(s.numeroFotograma || 'N/A') + '</small>' +
                    '</td>' +
                    '<td>' +
                        '<span class="ocr-preview" title="' + escapeHtml(s.textoOcr || '') + '">' +
                            escapeHtml(s.textoOcr || 'Sin texto indexado') +
                        '</span>' +
                    '</td>' +
                    '<td>' +
                        '<span class="badge bg-light text-dark border">' + (s.resolucionDpi || 300) + ' DPI</span> ' +
                        '<span class="badge bg-light text-secondary border">' + escapeHtml(s.profundidadColor || 'Grises') + '</span>' +
                    '</td>' +
                    '<td class="text-center">' +
                        '<button class="btn btn-sm btn-outline-primary" onclick="abrirVisor(' + idx + ')" title="Ver detalle completo">' +
                            '<i class="bi bi-eye"></i> Ver' +
                        '</button>' +
                    '</td>' +
                '</tr>';
            });
            tbody.innerHTML = html;
        }

        // Variables de estado del lector de microfilmes
        let visorZoom = 1.0;
        let visorRotacion = 0;
        let visorInvertido = false;

        function abrirVisor(index) {
            const s = soportesMemoria[index];
            if (!s) return;

            resetVisor();

            document.getElementById("visorTitulo").innerText = s.tipoSoporte + " - " + (s.codigoDocumento || ("DOC #" + s.idDocumento));
            document.getElementById("visorRutaText").innerText = "Ruta Máster TIFF: " + (s.rutaMasterTiff || "N/A") + " | Acceso Web: " + (s.rutaAccesoWeb || "N/A");
            document.getElementById("visorTextoOcr").innerText = s.textoOcr || "No se ha procesado texto OCR para este fotograma.";
            
            // Inyectar texto y encabezado en el fotograma simulado
            document.getElementById("visorFrameHeader").innerText = (s.tipoSoporte || "MICROFILM") + " • " + (s.rolloCaja || "ROLLO") + " • " + (s.numeroFotograma || "FRAME");
            document.getElementById("visorFrameTexto").innerText = s.textoOcr || "Documento analógico microfilmado en archivo de custodia.";

            let metaHtml = 
                '<li><strong>Rollo / Fichero de Custodia:</strong> ' + escapeHtml(s.rolloCaja || 'N/A') + '</li>' +
                '<li><strong>Posición / Fotograma (Frame):</strong> ' + escapeHtml(s.numeroFotograma || 'N/A') + '</li>' +
                '<li><strong>Ruta Máster TIFF (Preservación):</strong> <code>' + escapeHtml(s.rutaMasterTiff || 'No asignada') + '</code></li>' +
                '<li><strong>Resolución de Captura:</strong> ' + (s.resolucionDpi || 300) + ' DPI</li>' +
                '<li><strong>Profundidad de Color:</strong> ' + escapeHtml(s.profundidadColor || 'Escala de grises') + '</li>' +
                '<li><strong>Integridad SHA-256 (PREMIS):</strong> <code style="font-size:11px;">' + escapeHtml(s.hashSha256 || 'Sin hash') + '</code></li>' +
                '<li><strong>Diagnóstico de Conservación:</strong> ' + escapeHtml(s.observacionesConservacion || 'Sin observaciones registradas') + '</li>' +
                '<li><strong>Fecha Digitalización:</strong> ' + escapeHtml(s.fechaDigitalizacion || 'N/A') + '</li>';
            document.getElementById("visorMetadatos").innerHTML = metaHtml;

            const modal = new bootstrap.Modal(document.getElementById("modalVisor"));
            modal.show();
        }

        function zoomVisor(delta) {
            visorZoom = Math.max(0.5, Math.min(3.0, visorZoom + delta));
            aplicarTransformacionesVisor();
        }

        function rotarVisor() {
            visorRotacion = (visorRotacion + 90) % 360;
            aplicarTransformacionesVisor();
        }

        function togglePolaridad() {
            visorInvertido = !visorInvertido;
            aplicarTransformacionesVisor();
        }

        function resetVisor() {
            visorZoom = 1.0;
            visorRotacion = 0;
            visorInvertido = false;
            aplicarTransformacionesVisor();
        }

        function aplicarTransformacionesVisor() {
            const elem = document.getElementById("visorElementoTransform");
            if (!elem) return;
            const filterStr = visorInvertido ? "invert(1) hue-rotate(180deg)" : "none";
            elem.style.transform = "scale(" + visorZoom + ") rotate(" + visorRotacion + "deg)";
            elem.style.filter = filterStr;
            const btnPol = document.getElementById("btnPolaridad");
            if (btnPol) {
                btnPol.className = visorInvertido ? "btn btn-sm btn-warning" : "btn btn-sm btn-outline-warning";
            }
        }

        function copiarTextoOcr() {
            const txt = document.getElementById("visorTextoOcr").innerText;
            navigator.clipboard.writeText(txt).then(() => {
                const btn = document.getElementById("btnCopiarOcr");
                btn.innerHTML = '<i class="bi bi-check2"></i> ¡Copiado!';
                setTimeout(() => { btn.innerHTML = '<i class="bi bi-clipboard"></i> Copiar'; }, 2000);
            });
        }

        function guardarNuevoSoporte(event) {
            event.preventDefault();
            const payload = {
                idDocumento: parseInt(document.getElementById("regIdDoc").value),
                tipoSoporte: document.getElementById("regTipoSoporte").value,
                rolloCaja: document.getElementById("regRollo").value,
                numeroFotograma: document.getElementById("regFrame").value,
                rutaMasterTiff: document.getElementById("regRutaTiff").value,
                rutaAccesoWeb: document.getElementById("regRutaWeb").value,
                resolucionDpi: parseInt(document.getElementById("regDpi").value) || 300,
                profundidadColor: document.getElementById("regColor").value,
                hashSha256: document.getElementById("regHash").value,
                textoOcr: document.getElementById("regOcr").value,
                observacionesConservacion: document.getElementById("regObservaciones").value
            };

            fetch("api/soporte-especial", {
                method: "POST",
                headers: { "Content-Type": "application/json;charset=UTF-8" },
                body: JSON.stringify(payload)
            })
            .then(r => r.json())
            .then(res => {
                if (res.mensaje) {
                    alert("¡Soporte registrado con éxito en SADU!");
                    const modalEl = document.getElementById("modalNuevoSoporte");
                    const modal = bootstrap.Modal.getInstance(modalEl);
                    if (modal) modal.hide();
                    document.getElementById("formNuevoSoporte").reset();
                    cargarTodos();
                } else {
                    alert("Error: " + (res.error || "No se pudo guardar el registro"));
                }
            })
            .catch(err => alert("Error de comunicación con el servidor SADU"));
        }

        function mostrarCargando() {
            document.getElementById("tablaSoportesBody").innerHTML = 
                '<tr><td colspan="7" class="text-center py-4 text-muted"><div class="spinner-border spinner-border-sm text-primary me-2"></div> Consultando API SADU...</td></tr>';
        }

        function mostrarError(msg) {
            document.getElementById("tablaSoportesBody").innerHTML = 
                `<tr><td colspan="7" class="text-center py-4 text-danger"><i class="bi bi-exclamation-triangle me-1"></i> ${msg}</td></tr>`;
        }

        function escapeHtml(text) {
            if (!text) return "";
            return String(text).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
        }
    </script>
</body>
</html>
