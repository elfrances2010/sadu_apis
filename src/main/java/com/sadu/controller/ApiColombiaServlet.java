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
 * Servlet que consulta TODOS los departamentos de Colombia consumiendo
 * la API pública API Colombia.
 *
 * Endpoint: https://api-colombia.com/api/v1/Department
 *
 * A diferencia del servlet de Municipios, este NO recibe ningún ID por
 * parámetro: siempre trae el listado completo de los 33 departamentos.
 *
 * Métodos soportados:
 *   GET  → consulta la API y muestra los departamentos.
 *   POST → delega al GET (por si el botón alguna vez se cambia a un form).
 */
@WebServlet(name = "ApiColombiaServlet", urlPatterns = {"/ApiColombiaServlet"})
public class ApiColombiaServlet extends HttpServlet {

    /**
     * Método GET: valida sesión, consulta la API Colombia y envía
     * la lista de departamentos al JSP consultaApiColombia.jsp
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

        List<String[]> departamentos = new ArrayList<>();

        try {
            // 2. Llamar al endpoint de departamentos (sin ID, trae todos)
            String urlApi = "https://api-colombia.com/api/v1/Department";

            URL url = new URL(urlApi);
            HttpURLConnection conexion = (HttpURLConnection) url.openConnection();
            conexion.setRequestMethod("GET");
            conexion.setRequestProperty("Accept", "application/json");
            conexion.setConnectTimeout(5000);
            conexion.setReadTimeout(5000);

            int codigoRespuesta = conexion.getResponseCode();

            if (codigoRespuesta == 200) {

                // 3. Leer la respuesta como texto JSON
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conexion.getInputStream(), "UTF-8")
                );
                StringBuilder resultado = new StringBuilder();
                String linea;
                while ((linea = reader.readLine()) != null) {
                    resultado.append(linea);
                }
                reader.close();

                // 4. Parsear el JSON como arreglo de departamentos
                JSONArray jsonArray = new JSONArray(resultado.toString());

                if (jsonArray.length() == 0) {
                    request.setAttribute("mensajeError",
                            "La API Colombia no devolvió departamentos en este momento.");
                } else {
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject depto = jsonArray.getJSONObject(i);

                        String deptoId    = depto.optString("id", "");
                        String nombre     = depto.optString("name", "");
                        String descripcion = depto.optString("description", "");
                        String poblacion  = String.valueOf(depto.optInt("population", 0));

                        // El nombre de la capital viene como un objeto anidado
                        // "cityCapital": { "id": ..., "name": "Leticia", ... }
                        // Si el objeto no viene o no tiene "name", mostramos un guion.
                        String capital = "—";
                        JSONObject cityCapital = depto.optJSONObject("cityCapital");
                        if (cityCapital != null) {
                            String nombreCapital = cityCapital.optString("name", "");
                            if (!nombreCapital.trim().isEmpty()) {
                                capital = nombreCapital;
                            }
                        }

                        // Si la descripción viene vacía o muy corta, generamos
                        // una descripción de respaldo con los datos disponibles.
                        if (descripcion == null || descripcion.trim().length() < 15) {
                            StringBuilder respaldo = new StringBuilder();
                            respaldo.append("Departamento de Colombia");
                            if (!capital.equals("—")) {
                                respaldo.append(" cuya capital es ").append(capital);
                            }
                            if (depto.optInt("population", 0) > 0) {
                                respaldo.append(", con una población aproximada de ")
                                        .append(String.format("%,d", depto.optInt("population", 0)))
                                        .append(" habitantes");
                            }
                            respaldo.append(".");
                            descripcion = respaldo.toString();
                        }

                        departamentos.add(new String[]{deptoId, nombre, descripcion, capital, poblacion});
                    }
                    request.setAttribute("departamentos", departamentos);
                }

            } else {
                request.setAttribute("mensajeError",
                        "Error al consultar la API Colombia. Código HTTP: " + codigoRespuesta);
            }

        } catch (Exception e) {
            request.setAttribute("mensajeError",
                    "Error al consumir API Colombia: " + e.getMessage());
        }

        // 5. Redirigir al JSP con los resultados
        request.getRequestDispatcher("/consultaApiColombia.jsp").forward(request, response);
    }

    /**
     * Método POST: delega al método GET.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para consultar el listado completo de departamentos desde API Colombia";
    }
}