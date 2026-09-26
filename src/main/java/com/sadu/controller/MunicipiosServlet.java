package com.sadu.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
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
 * Servlet que consulta los municipios de un departamento usando la API Colombia.
 *
 * Endpoint: GET https://api-colombia.com/api/v1/Department/{id}/cities
 *
 * Métodos soportados:
 *   GET  → recibe el ID del departamento y consulta sus municipios
 *   POST → delega al GET (formularios pueden usar method="post")
 */
@WebServlet(name = "MunicipiosServlet", urlPatterns = {"/MunicipiosServlet"})
public class MunicipiosServlet extends HttpServlet {

    /**
     * Método GET: recibe el ID del departamento, consulta la API y envía
     * la lista de municipios al JSP consultaMunicipios.jsp
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión activa
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Leer el parámetro idDepartamento enviado desde el formulario
        String idDepartamento = request.getParameter("idDepartamento");

        List<String[]> municipios = new ArrayList<>();

        // Solo consultar si el usuario envió un ID válido
        if (idDepartamento != null && !idDepartamento.trim().isEmpty()) {

            try {
                // 3. Construir la URL con el ID del departamento
                String urlStr = "https://api-colombia.com/api/v1/Department/"
                        + idDepartamento.trim() + "/cities";

                URL url = new URL(urlStr);
                HttpURLConnection conexion = (HttpURLConnection) url.openConnection();
                conexion.setRequestMethod("GET");
                conexion.setRequestProperty("Accept", "application/json");
                conexion.setConnectTimeout(5000);
                conexion.setReadTimeout(5000);

                int codigoRespuesta = conexion.getResponseCode();

                if (codigoRespuesta == 200) {

                    // 4. Leer la respuesta JSON
                    BufferedReader reader = new BufferedReader(
                            new InputStreamReader(conexion.getInputStream(), "UTF-8")
                    );
                    StringBuilder resultado = new StringBuilder();
                    String linea;
                    while ((linea = reader.readLine()) != null) {
                        resultado.append(linea);
                    }
                    reader.close();

                    // 5. Parsear el JSON — cada objeto es un municipio
                    JSONArray jsonArray = new JSONArray(resultado.toString());

                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject municipio = jsonArray.getJSONObject(i);

                        String id          = municipio.optString("id", "");
                        String nombre      = municipio.optString("name", "");
                        String descripcion = municipio.optString("description", "");

                        // surface es decimal (km²)
                        String superficie = String.valueOf(municipio.optDouble("surface", 0.0));

                        // population es entero
                        String poblacion = String.valueOf(municipio.optInt("population", 0));

                        municipios.add(new String[]{id, nombre, descripcion, superficie, poblacion});
                    }

                    request.setAttribute("municipios", municipios);
                    request.setAttribute("idConsultado", idDepartamento);

                } else if (codigoRespuesta == 404) {
                    request.setAttribute("mensajeError",
                            "No se encontró el departamento con ID: " + idDepartamento);
                } else {
                    request.setAttribute("mensajeError",
                            "Error al consultar la API. Código HTTP: " + codigoRespuesta);
                }

            } catch (Exception e) {
                request.setAttribute("mensajeError",
                        "Error al consumir la API Colombia: " + e.getMessage());
            }
        }

        // 6. Redirigir al JSP de municipios
        request.getRequestDispatcher("/consultaMunicipios.jsp").forward(request, response);
    }

    /**
     * Método POST: delega al método GET.
     * Permite que el formulario de búsqueda funcione con method="post" también.
     * Cumple el requisito de soportar ambos métodos HTTP.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para consultar municipios de un departamento desde API Colombia";
    }
}