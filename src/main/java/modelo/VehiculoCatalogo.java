package modelo;

public class VehiculoCatalogo {

    private String nroPatente;
    private String nombreMarca;
    private String nombreModelo;
    private String nombreTipo;
    private String nombreSucursal;
    private String ubicacion;
    private String detalleConfort;
    private String nombreTipoEstado;
    private String urlImagen;
    private double valorDiario;
    private double porcentajeRecargoHora;

    public VehiculoCatalogo() {
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

    public String getNombreSucursal() {
        return nombreSucursal;
    }

    public void setNombreSucursal(String nombreSucursal) {
        this.nombreSucursal = nombreSucursal;
    }

    public String getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
    }

    public String getDetalleConfort() {
        return detalleConfort;
    }

    public void setDetalleConfort(String detalleConfort) {
        this.detalleConfort = detalleConfort;
    }

    public String getNombreTipoEstado() {
        return nombreTipoEstado;
    }

    public void setNombreTipoEstado(String nombreTipoEstado) {
        this.nombreTipoEstado = nombreTipoEstado;
    }

    public String getUrlImagen() {
        return urlImagen;
    }

    public void setUrlImagen(String urlImagen) {
        this.urlImagen = urlImagen;
    }

    public double getValorDiario() {
        return valorDiario;
    }

    public void setValorDiario(double valorDiario) {
        this.valorDiario = valorDiario;
    }

    public double getPorcentajeRecargoHora() {
        return porcentajeRecargoHora;
    }

    public void setPorcentajeRecargoHora(double porcentajeRecargoHora) {
        this.porcentajeRecargoHora = porcentajeRecargoHora;
    }
}