package dao;

import conexion.ConexionBD;
import modelo.ClienteSesion;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginClienteDAO {

    public ClienteSesion validarCliente(String usuario, String contrasenia) {

        ClienteSesion cliente = null;

        String sql =
                "SELECT " +
                "u.idUsuario, " +
                "c.DNI, " +
                "c.nombreYapellido, " +
                "c.telefono " +
                "FROM usuario u " +
                "INNER JOIN cliente c ON u.idUsuario = c.idUsuario " +
                "WHERE u.nombreDeUsuario = ? " +
                "AND u.contrasenia = ? " +
                "LIMIT 1";

        try (
            Connection con = ConexionBD.conectar();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, usuario);
            ps.setString(2, contrasenia);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    cliente = new ClienteSesion();

                    cliente.setIdUsuario(rs.getInt("idUsuario"));
                    cliente.setDni(rs.getString("DNI"));
                    cliente.setNombreYapellido(rs.getString("nombreYapellido"));
                    cliente.setTelefono(rs.getString("telefono"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return cliente;
    }
}