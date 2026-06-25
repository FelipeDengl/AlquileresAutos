package dao;

import conexion.ConexionBD;
import modelo.VehiculoCatalogo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class VehiculoCatalogoDAO {

    public List<VehiculoCatalogo> listarCatalogo(
            Integer idSucursal,
            Integer idTipo,
            Timestamp fechaInicio,
            Timestamp fechaFin) {

        List<VehiculoCatalogo> vehiculos = new ArrayList<>();

        String sql =
                "SELECT " +
                "v.nroPatente, " +
                "ma.nombreMarca, " +
                "mo.nombreModelo, " +
                "tv.nombreTipo, " +
                "s.nombreSucursal, " +
                "s.ubicacion, " +
                "v.detalleConfort, " +
                "e.nombreTipoEstado, " +
                "COALESCE( " +
                "   (SELECT iv.urlImagen " +
                "    FROM imagen_vehiculo iv " +
                "    WHERE iv.nroPatente = v.nroPatente " +
                "    ORDER BY iv.idImagen " +
                "    LIMIT 1), " +
                "   'img/car-1.png' " +
                ") AS urlImagen, " +
                "COALESCE(t.valorDiario, 0) AS valorDiario, " +
                "COALESCE(t.porcentaje_recargo_hora, 0) AS porcentaje_recargo_hora " +
                "FROM vehiculo v " +
                "INNER JOIN modelo mo ON v.idModelo = mo.idModelo " +
                "INNER JOIN marca ma ON mo.idMarca = ma.idMarca " +
                "INNER JOIN tipo_vehiculo tv ON v.idTipo = tv.idTipo " +
                "INNER JOIN sucursal s ON v.idSucursal = s.idSucursal " +
                "INNER JOIN estado e ON v.idTipoEstado = e.idTipoEstado " +
                "LEFT JOIN tarifa t ON t.idTipo = v.idTipo " +
                "AND t.idSucursal = v.idSucursal " +
                "WHERE UPPER(e.nombreTipoEstado) NOT LIKE '%MANTEN%' ";

        if (idSucursal != null) {
            sql += "AND v.idSucursal = ? ";
        }

        if (idTipo != null) {
            sql += "AND v.idTipo = ? ";
        }

        if (fechaInicio != null && fechaFin != null) {
            sql +=
                "AND NOT EXISTS ( " +
                "   SELECT 1 " +
                "   FROM reserva r " +
                "   WHERE r.nroPatente = v.nroPatente " +
                "   AND r.estadoReserva = 'ACTIVA' " +
                "   AND r.fechaInicio < ? " +
                "   AND r.fechaFin > ? " +
                ") " +
                "AND NOT EXISTS ( " +
                "   SELECT 1 " +
                "   FROM alquiler a " +
                "   WHERE a.nroPatente = v.nroPatente " +
                "   AND a.fechaDevolucionReal IS NULL " +
                "   AND a.fechaInicio < ? " +
                "   AND a.fechaDevolucionPrevista > ? " +
                ") ";
        }

        sql += "ORDER BY ma.nombreMarca, mo.nombreModelo, v.nroPatente";

        try (
            Connection con = ConexionBD.conectar();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            int parametro = 1;

            if (idSucursal != null) {
                ps.setInt(parametro, idSucursal);
                parametro++;
            }

            if (idTipo != null) {
                ps.setInt(parametro, idTipo);
                parametro++;
            }

            if (fechaInicio != null && fechaFin != null) {
                ps.setTimestamp(parametro, fechaFin);
                parametro++;

                ps.setTimestamp(parametro, fechaInicio);
                parametro++;

                ps.setTimestamp(parametro, fechaFin);
                parametro++;

                ps.setTimestamp(parametro, fechaInicio);
            }

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    VehiculoCatalogo v = new VehiculoCatalogo();

                    v.setNroPatente(rs.getString("nroPatente"));
                    v.setNombreMarca(rs.getString("nombreMarca"));
                    v.setNombreModelo(rs.getString("nombreModelo"));
                    v.setNombreTipo(rs.getString("nombreTipo"));
                    v.setNombreSucursal(rs.getString("nombreSucursal"));
                    v.setUbicacion(rs.getString("ubicacion"));
                    v.setDetalleConfort(rs.getString("detalleConfort"));
                    v.setNombreTipoEstado(rs.getString("nombreTipoEstado"));
                    v.setUrlImagen(rs.getString("urlImagen"));
                    v.setValorDiario(rs.getDouble("valorDiario"));
                    v.setPorcentajeRecargoHora(rs.getDouble("porcentaje_recargo_hora"));

                    vehiculos.add(v);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return vehiculos;
    }
}