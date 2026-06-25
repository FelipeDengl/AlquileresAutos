package dao;

import conexion.ConexionBD;
import modelo.Vehiculo;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class VehiculoDAO {

    public List<Vehiculo> listarVehiculos(Integer idTipoEstado) {

        List<Vehiculo> vehiculos = new ArrayList<>();

        try (
            Connection con = ConexionBD.conectar();
            CallableStatement cs = con.prepareCall("{CALL sp_listar_vehiculos(?)}")
        ) {

            if (idTipoEstado == null) {
                cs.setNull(1, Types.INTEGER);
            } else {
                cs.setInt(1, idTipoEstado);
            }

            try (ResultSet rs = cs.executeQuery()) {

                while (rs.next()) {

                    Vehiculo vehiculo = new Vehiculo();

                    vehiculo.setNroPatente(rs.getString("nroPatente"));
                    vehiculo.setNombreMarca(rs.getString("nombreMarca"));
                    vehiculo.setNombreModelo(rs.getString("nombreModelo"));
                    vehiculo.setNombreTipo(rs.getString("nombreTipo"));
                    vehiculo.setNombreTipoEstado(rs.getString("nombreTipoEstado"));
                    vehiculo.setDetalleConfort(rs.getString("detalleConfort"));
                    vehiculo.setNombreSucursal(rs.getString("nombreSucursal"));

                    vehiculos.add(vehiculo);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return vehiculos;
    }
}