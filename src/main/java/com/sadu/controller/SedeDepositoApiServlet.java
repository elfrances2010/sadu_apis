package com.sadu.controller;

import com.google.gson.Gson;
import com.sadu.dao.SedeDepositoDAO;
import com.sadu.modelo.SedeDeposito;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "SedeDepositoApiServlet", urlPatterns = {"/api/sedes-depositos"})
public class SedeDepositoApiServlet extends HttpServlet {

    private final SedeDepositoDAO dao = new SedeDepositoDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        PrintWriter out = response.getWriter();

        try {
            List<SedeDeposito> lista = dao.listarTodas();
            out.print(gson.toJson(lista));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Error al consultar sedes y depósitos: " + e.getMessage() + "\"}");
        }
    }
}

