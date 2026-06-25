package dao;

import conexion.ConexionBD;
import modelo.Cliente;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ClienteDAO {

    public List<Cliente> listarClientes() {

        List<Cliente> clientes = new ArrayList<>();

        try (
            Connection con = ConexionBD.conectar()
        ) {

            CallableStatement cs =
                con.prepareCall(
                    "{CALL sp_listar_clientes()}"
                );

            ResultSet rs = cs.executeQuery();

            while (rs.next()) {

                Cliente cliente = new Cliente();

                cliente.setIdUsuario(
                    rs.getInt("idUsuario")
                );

                cliente.setDni(
                    rs.getString("DNI")
                );

                cliente.setNombreYapellido(
                    rs.getString("nombreYapellido")
                );

                cliente.setTelefono(
                    rs.getString("telefono")
                );

                clientes.add(cliente);
            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return clientes;
    }
    public String altaCliente(
        String usuario,
        String contrasenia,
        String dni,
        String nombre,
        String telefono,
        java.sql.Date fechaNacimiento)
    {
        try (
            Connection con =
                ConexionBD.conectar()
        ) {

            CallableStatement cs =
                con.prepareCall(
                    "{CALL sp_alta_cliente(?,?,?,?,?,?,?)}"
                );

            cs.setString(1, usuario);
            cs.setString(2, contrasenia);
            cs.setString(3, dni);
            cs.setString(4, nombre);
            cs.setString(5, telefono);
            cs.setDate(6, fechaNacimiento);

            cs.registerOutParameter(
                7,
                java.sql.Types.VARCHAR
            );

            cs.execute();

            return cs.getString(7);

        } catch (Exception e) {

            e.printStackTrace();

            return e.getMessage();
        }
    }
}