package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.SedeDeposito;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SedeDepositoDAO {

    public List<SedeDeposito> listarTodas() {
        List<SedeDeposito> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT s.*, m.nombre AS municipio_nom, d.nombre AS depto_nom " +
                         "FROM sedes_depositos s " +
                         "INNER JOIN territorio_municipio m ON s.id_municipio = m.id " +
                         "INNER JOIN territorio_departamento d ON m.departamento_id = d.id " +
                         "ORDER BY s.nombre_sede ASC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                SedeDeposito sd = new SedeDeposito();
                sd.setIdDeposito(rs.getInt("id_deposito"));
                sd.setNombreSede(rs.getString("nombre_sede"));
                sd.setCodigoSede(rs.getString("codigo_sede"));
                sd.setNombreDeposito(rs.getString("nombre_deposito"));
                sd.setIdMunicipio(rs.getInt("id_municipio"));
                sd.setNombreMunicipio(rs.getString("municipio_nom"));
                sd.setNombreDepartamento(rs.getString("depto_nom"));
                sd.setDireccion(rs.getString("direccion"));
                sd.setResponsableCustodia(rs.getString("responsable_custodia"));
                sd.setCondicionesAmbientales(rs.getString("condiciones_ambientales"));
                sd.setCapacidadEstanteria(rs.getInt("capacidad_estanteria"));
                lista.add(sd);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrar(rs, ps, con);
        }
        return lista;
    }

    public boolean registrar(SedeDeposito sd) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "INSERT INTO sedes_depositos " +
                         "(nombre_sede, codigo_sede, nombre_deposito, id_municipio, direccion, " +
                         " responsable_custodia, condiciones_ambientales, capacidad_estanteria) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, sd.getNombreSede());
            ps.setString(2, sd.getCodigoSede());
            ps.setString(3, sd.getNombreDeposito());
            ps.setInt(4, sd.getIdMunicipio());
            ps.setString(5, sd.getDireccion());
            ps.setString(6, sd.getResponsableCustodia());
            ps.setString(7, sd.getCondicionesAmbientales());
            ps.setInt(8, sd.getCapacidadEstanteria());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrar(null, ps, con);
        }
    }

    private void cerrar(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception ignored) {}
        try { if (ps  != null) ps.close();  } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
}

