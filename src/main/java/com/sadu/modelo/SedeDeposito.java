package com.sadu.modelo;

/**
 * Representa una Sede y Depósito Físico de Custodia de Archivo en SADU.
 * Articula la base territorial (municipio/departamento) con las bodegas
 * donde se resguardan físicamente microfilmes, fotos y expedientes.
 */
public class SedeDeposito {

    private int idDeposito;
    private String nombreSede;
    private String codigoSede;
    private String nombreDeposito;
    private int idMunicipio;
    private String nombreMunicipio;
    private String nombreDepartamento;
    private String direccion;
    private String responsableCustodia;
    private String condicionesAmbientales;
    private int capacidadEstanteria;

    public SedeDeposito() {}

    public int getIdDeposito() { return idDeposito; }
    public void setIdDeposito(int idDeposito) { this.idDeposito = idDeposito; }

    public String getNombreSede() { return nombreSede; }
    public void setNombreSede(String nombreSede) { this.nombreSede = nombreSede; }

    public String getCodigoSede() { return codigoSede; }
    public void setCodigoSede(String codigoSede) { this.codigoSede = codigoSede; }

    public String getNombreDeposito() { return nombreDeposito; }
    public void setNombreDeposito(String nombreDeposito) { this.nombreDeposito = nombreDeposito; }

    public int getIdMunicipio() { return idMunicipio; }
    public void setIdMunicipio(int idMunicipio) { this.idMunicipio = idMunicipio; }

    public String getNombreMunicipio() { return nombreMunicipio; }
    public void setNombreMunicipio(String nombreMunicipio) { this.nombreMunicipio = nombreMunicipio; }

    public String getNombreDepartamento() { return nombreDepartamento; }
    public void setNombreDepartamento(String nombreDepartamento) { this.nombreDepartamento = nombreDepartamento; }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public String getResponsableCustodia() { return responsableCustodia; }
    public void setResponsableCustodia(String responsableCustodia) { this.responsableCustodia = responsableCustodia; }

    public String getCondicionesAmbientales() { return condicionesAmbientales; }
    public void setCondicionesAmbientales(String condicionesAmbientales) { this.condicionesAmbientales = condicionesAmbientales; }

    public int getCapacidadEstanteria() { return capacidadEstanteria; }
    public void setCapacidadEstanteria(int capacidadEstanteria) { this.capacidadEstanteria = capacidadEstanteria; }
}

