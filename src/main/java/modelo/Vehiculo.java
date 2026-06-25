
package modelo;

public class Vehiculo {

    private String nroPatente;
    private String nombreMarca;
    private String nombreModelo;
    private String nombreTipo;
    private String nombreTipoEstado;
    private String detalleConfort;
    private String nombreSucursal;

    public Vehiculo() {
    }

    public Vehiculo(String nroPatente, String nombreMarca, String nombreModelo,
                    String nombreTipo, String nombreTipoEstado,
                    String detalleConfort, String nombreSucursal) {
        this.nroPatente = nroPatente;
        this.nombreMarca = nombreMarca;
        this.nombreModelo = nombreModelo;
        this.nombreTipo = nombreTipo;
        this.nombreTipoEstado = nombreTipoEstado;
        this.detalleConfort = detalleConfort;
        this.nombreSucursal = nombreSucursal;
    }

    public String getNroPatente() {
        return nroPatente;
    }

    public void setNroPatente(String nroPatente) {
        this.nroPatente = nroPatente;
    }

    public String getNombreMarca() {
        return nombreMarca;
    }

    public void setNombreMarca(String nombreMarca) {
        this.nombreMarca = nombreMarca;
    }

    public String getNombreModelo() {
        return nombreModelo;
    }

    public void setNombreModelo(String nombreModelo) {
        this.nombreModelo = nombreModelo;
    }

    public String getNombreTipo() {
        return nombreTipo;
    }

    public void setNombreTipo(String nombreTipo) {
        this.nombreTipo = nombreTipo;
    }

    public String getNombreTipoEstado() {
        return nombreTipoEstado;
    }

    public void setNombreTipoEstado(String nombreTipoEstado) {
        this.nombreTipoEstado = nombreTipoEstado;
    }

    public String getDetalleConfort() {
        return detalleConfort;
    }

    public void setDetalleConfort(String detalleConfort) {
        this.detalleConfort = detalleConfort;
    }

    public String getNombreSucursal() {
        return nombreSucursal;
    }

    public void setNombreSucursal(String nombreSucursal) {
        this.nombreSucursal = nombreSucursal;
    }
}
