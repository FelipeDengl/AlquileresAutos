package dao;

import conexion.ConexionBD;
import modelo.Opcion;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CatalogoDAO {

    public List<Opcion> listarSucursales() {

        List<Opcion> lista = new ArrayList<>();

        String sql =
                "SELECT idSucursal, nombreSucursal " +
                "FROM sucursal " +
                "ORDER BY nombreSucursal";

        try (
            Connection con = ConexionBD.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {

                Opcion opcion = new Opcion();

                opcion.setId(
                        rs.getInt("idSucursal")
                );

                opcion.setNombre(
                        rs.getString("nombreSucursal")
                );

                lista.add(opcion);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    public List<Opcion> listarTiposVehiculo() {

        List<Opcion> lista = new ArrayList<>();

        String sql =
                "SELECT idTipo, nombreTipo " +
                "FROM tipo_vehiculo " +
                "ORDER BY nombreTipo";

        try (
            Connection con = ConexionBD.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {

                Opcion opcion = new Opcion();

                opcion.setId(
                        rs.getInt("idTipo")
                );

                opcion.setNombre(
                        rs.getString("nombreTipo")
                );

                lista.add(opcion);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }
}