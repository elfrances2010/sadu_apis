package com.sadu.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet que consulta los municipios (ciudades) de un departamento
 * específico de Colombia, dado su ID, consumiendo la API pública.
 *
 * Endpoint municipios:    https://api-colombia.com/api/v1/Department/{id}/cities
 * Endpoint departamentos: https://api-colombia.com/api/v1/Department
 *
 * En cada visita (con o sin búsqueda) se carga también la lista completa
 * de departamentos, para poblar un <select> en el JSP y que el usuario
 * elija por NOMBRE en vez de tener que saber el ID de memoria.
 *
 * Métodos soportados:
 *   GET  → recibe el parámetro "idDepartamento" y muestra sus municipios.
 *   POST → delega al GET (permite formularios con method="post").
 */
@WebServlet(name = "MunicipiosApiColombiaServlet", urlPatterns = {"/MunicipiosApiColombiaServlet"})
public class MunicipiosApiColombiaServlet extends HttpServlet {

    /**
     * Método GET: valida sesión, carga el listado de departamentos para el
     * select, y si el usuario envió un ID, consulta sus municipios.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión activa — si no hay sesión, redirigir al login
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Cargar SIEMPRE la lista de departamentos para llenar el <select>.
        //    Si esto falla (por ejemplo la API externa está caída), no se
        //    interrumpe la consulta de municipios; simplemente el select
        //    del JSP va a mostrar la lista vacía.
        List<String[]> listaDepartamentos = obtenerListaDepartamentos();
        request.setAttribute("listaDepartamentos", listaDepartamentos);

        // 3. Leer el ID de departamento enviado desde el formulario
        String idDepartamento = request.getParameter("idDepartamento");
        request.setAttribute("idDepartamento", idDepartamento);

        // Si el usuario aún no ha elegido un departamento, solo mostrar el
        // formulario (con el select ya lleno) sin resultados.
        if (idDepartamento == null || idDepartamento.trim().isEmpty()) {
            request.getRequestDispatcher("/consultaMunicipios.jsp").forward(request, response);
            return;
        }

        List<String[]> municipios = new ArrayList<>();

        try {
            // 4. Validar que el ID sea numérico antes de llamar a la API
            int id = Integer.parseInt(idDepartamento.trim());

            // 5. Construir la URL del endpoint con el ID del departamento
            String urlApi = "https://api-colombia.com/api/v1/Department/"
                    + URLEncoder.encode(String.valueOf(id), "UTF-8") + "/cities";

            URL url = new URL(urlApi);
            HttpURLConnection conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("GET");
            conexion.setRequestProperty("Accept", "application/json");
            conexion.setConnectTimeout(5000);
            conexion.setReadTimeout(5000);

            int codigoRespuesta = conexion.getResponseCode();

            if (codigoRespuesta == 200) {

                // 6. Leer la respuesta como texto JSON
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conexion.getInputStream(), "UTF-8")
                );
                StringBuilder resultado = new StringBuilder();
                String linea;
                while ((linea = reader.readLine()) != null) {
                    resultado.append(linea);
                }
                reader.close();

                // 7. Parsear el JSON como arreglo de municipios (ciudades)
                JSONArray jsonArray = new JSONArray(resultado.toString());

                if (jsonArray.length() == 0) {
                    request.setAttribute("mensajeError",
                            "No se encontraron municipios para el departamento seleccionado.");
                } else {
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject ciudad = jsonArray.getJSONObject(i);

                        String ciudadId       = ciudad.optString("id", "");
                        String nombre         = ciudad.optString("name", "");
                        String descripcion    = ciudad.optString("description", "");
                        boolean esCapitalBool = ciudad.optBoolean("isCapital", false);
                        String esCapital      = esCapitalBool ? "Sí" : "No";
                        int poblacionNum      = ciudad.optInt("population", 0);
                        String poblacion      = String.valueOf(poblacionNum);

                        // La API también trae la superficie en km² (campo "surface").
                        double superficie = ciudad.optDouble("surface", 0.0);
                        String superficieTexto = superficie > 0
                                ? String.format("%,.1f", superficie)
                                : "";

                        // Si la descripción viene vacía o muy corta, armamos
                        // una descripción de respaldo con los datos disponibles.
                        if (descripcion == null || descripcion.trim().length() < 15) {
                            StringBuilder respaldo = new StringBuilder();
                            respaldo.append(esCapitalBool
                                    ? "Municipio capital del departamento"
                                    : "Municipio de Colombia");
                            if (poblacionNum > 0) {
                                respaldo.append(", con una población aproximada de ")
                                        .append(String.format("%,d", poblacionNum))
                                        .append(" habitantes");
                            }
                            if (superficie > 0) {
                                respaldo.append(" y una superficie de ")
                                        .append(superficieTexto)
                                        .append(" km²");
                            }
                            respaldo.append(".");
                            descripcion = respaldo.toString();
                        }

                        // Arreglo con 6 posiciones: se agrega la superficie al final
                        // (posición 5) para poder mostrarla en las tarjetas del JSP.
                        municipios.add(new String[]{
                            ciudadId, nombre, descripcion, esCapital, poblacion, superficieTexto
                        });
                    }
                    request.setAttribute("municipios", municipios);
                }

            } else if (codigoRespuesta == 404) {
                request.setAttribute("mensajeError",
                        "No existe un departamento con el ID " + id + " en la API Colombia.");
            } else {
                request.setAttribute("mensajeError",
                        "Error al consultar la API Colombia. Código HTTP: " + codigoRespuesta);
            }

        } catch (NumberFormatException nfe) {
            request.setAttribute("mensajeError",
                    "El ID de departamento debe ser un número entero válido.");
        } catch (Exception e) {
            request.setAttribute("mensajeError",
                    "Error al consumir API Colombia: " + e.getMessage());
        }

        // 8. Redirigir al JSP con los resultados
        request.getRequestDispatcher("/consultaMunicipios.jsp").forward(request, response);
    }

    /**
     * Consulta la API Colombia para traer SOLO el id y el nombre de cada
     * departamento (no necesitamos más datos para el <select>), y los
     * devuelve ordenados alfabéticamente para que el desplegable sea
     * más fácil de usar.
     *
     * Si la API falla, devuelve una lista vacía en vez de lanzar una
     * excepción, para no romper la carga de la página.
     */
    private List<String[]> obtenerListaDepartamentos() {
        List<String[]> lista = new ArrayList<>();

        try {
            URL url = new URL("https://api-colombia.com/api/v1/Department");
            HttpURLConnection conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("GET");
            conexion.setRequestProperty("Accept", "application/json");
            conexion.setConnectTimeout(5000);
            conexion.setReadTimeout(5000);

            if (conexion.getResponseCode() == 200) {
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conexion.getInputStream(), "UTF-8")
                );
                StringBuilder resultado = new StringBuilder();
                String linea;
                while ((linea = reader.readLine()) != null) {
                    resultado.append(linea);
                }
                reader.close();

                JSONArray jsonArray = new JSONArray(resultado.toString());
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject depto = jsonArray.getJSONObject(i);
                    String id     = depto.optString("id", "");
                    String nombre = depto.optString("name", "");
                    if (!id.isEmpty() && !nombre.isEmpty()) {
                        lista.add(new String[]{id, nombre});
                    }
                }

                // Ordenar alfabéticamente por nombre para que el select sea usable
                lista.sort(Comparator.comparing(d -> d[1]));
            }
        } catch (Exception e) {
            // Silencioso a propósito: si falla, el select queda vacío
            // pero la página sigue funcionando.
        }

        return lista;
    }

    /**
     * Método POST: delega al método GET.
     * Permite que el formulario de búsqueda use method="post".
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para consultar municipios de un departamento desde API Colombia, con select de departamentos";
    }
}
