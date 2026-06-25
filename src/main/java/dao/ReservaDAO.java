package dao;

import conexion.ConexionBD;
import modelo.VehiculoCatalogo;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.Types;

public class ReservaDAO {

    public VehiculoCatalogo obtenerVehiculoParaReserva(String nroPatente) {

        VehiculoCatalogo vehiculo = null;

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
                "WHERE v.nroPatente = ? " +
                "LIMIT 1";

        try (
            Connection con = ConexionBD.conectar();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, nroPatente);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    vehiculo = new VehiculoCatalogo();

                    vehiculo.setNroPatente(rs.getString("nroPatente"));
                    vehiculo.setNombreMarca(rs.getString("nombreMarca"));
                    vehiculo.setNombreModelo(rs.getString("nombreModelo"));
                    vehiculo.setNombreTipo(rs.getString("nombreTipo"));
                    vehiculo.setNombreSucursal(rs.getString("nombreSucursal"));
                    vehiculo.setUbicacion(rs.getString("ubicacion"));
                    vehiculo.setDetalleConfort(rs.getString("detalleConfort"));
                    vehiculo.setNombreTipoEstado(rs.getString("nombreTipoEstado"));
                    vehiculo.setUrlImagen(rs.getString("urlImagen"));
                    vehiculo.setValorDiario(rs.getDouble("valorDiario"));
                    vehiculo.setPorcentajeRecargoHora(rs.getDouble("porcentaje_recargo_hora"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return vehiculo;
    }

    public String registrarReserva(
            int idUsuario,
            String nroPatente,
            Timestamp fechaInicio,
            Timestamp fechaFin) {

        String resultado = "";

        try (
            Connection con = ConexionBD.conectar();
            CallableStatement cs = con.prepareCall("{CALL sp_registrar_reserva(?,?,?,?,?)}")
        ) {

            cs.setInt(1, idUsuario);
            cs.setString(2, nroPatente);
            cs.setTimestamp(3, fechaInicio);
            cs.setTimestamp(4, fechaFin);

            cs.registerOutParameter(5, Types.VARCHAR);

            cs.execute();

            resultado = cs.getString(5);

        } catch (Exception e) {
            e.printStackTrace();
            resultado = "Error al registrar la reserva: " + e.getMessage();
        }

        return resultado;
    }

    public int obtenerUltimaReserva(
            int idUsuario,
            String nroPatente,
            Timestamp fechaInicio,
            Timestamp fechaFin) {

        int idReserva = 0;

        String sql =
                "SELECT idReserva " +
                "FROM reserva " +
                "WHERE idUsuario = ? " +
                "AND nroPatente = ? " +
                "AND fechaInicio = ? " +
                "AND fechaFin = ? " +
                "ORDER BY idReserva DESC " +
                "LIMIT 1";

        try (
            Connection con = ConexionBD.conectar();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, idUsuario);
            ps.setString(2, nroPatente);
            ps.setTimestamp(3, fechaInicio);
            ps.setTimestamp(4, fechaFin);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    idReserva = rs.getInt("idReserva");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return idReserva;
    }
    
    public java.util.List<modelo.PeriodoOcupacion> obtenerPeriodosOcupados(String nroPatente) {

    java.util.List<modelo.PeriodoOcupacion> periodos = new java.util.ArrayList<>();

    String sql =
            "SELECT " +
            "DATE(fechaInicio) AS fechaInicio, " +
            "DATE(fechaFin) AS fechaFin, " +
            "'RESERVA' AS tipo " +
            "FROM reserva " +
            "WHERE nroPatente = ? " +
            "AND estadoReserva = 'ACTIVA' " +
            "AND fechaFin >= CURDATE() " +

            "UNION ALL " +

            "SELECT " +
            "DATE(fechaInicio) AS fechaInicio, " +
            "DATE(fechaDevolucionPrevista) AS fechaFin, " +
            "'ALQUILER' AS tipo " +
            "FROM alquiler " +
            "WHERE nroPatente = ? " +
            "AND fechaDevolucionReal IS NULL " +
            "AND fechaDevolucionPrevista >= CURDATE() " +

            "ORDER BY fechaInicio";

    try (
        Connection con = ConexionBD.conectar();
        PreparedStatement ps = con.prepareStatement(sql)
    ) {

        ps.setString(1, nroPatente);
        ps.setString(2, nroPatente);

        try (ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                modelo.PeriodoOcupacion p = new modelo.PeriodoOcupacion();

                p.setFechaInicio(rs.getString("fechaInicio"));
                p.setFechaFin(rs.getString("fechaFin"));
                p.setTipo(rs.getString("tipo"));

                periodos.add(p);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return periodos;
}
}