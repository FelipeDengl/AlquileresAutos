package modelo;

public class ClienteSesion {

    private int idUsuario;
    private String dni;
    private String nombreYapellido;
    private String telefono;

    public ClienteSesion() {
    }

    public ClienteSesion(int idUsuario, String dni, String nombreYapellido, String telefono) {
        this.idUsuario = idUsuario;
        this.dni = dni;
        this.nombreYapellido = nombreYapellido;
        this.telefono = telefono;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getNombreYapellido() {
        return nombreYapellido;
    }

    public void setNombreYapellido(String nombreYapellido) {
        this.nombreYapellido = nombreYapellido;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
}