package servlet;

import dao.CatalogoDAO;
import dao.VehiculoCatalogoDAO;
import modelo.VehiculoCatalogo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/catalogoVehiculos")
public class CatalogoVehiculosServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String idSucursalParam = request.getParameter("idSucursal");
        String idTipoParam = request.getParameter("idTipo");
        String fechaInicioParam = request.getParameter("fechaInicio");
        String fechaFinParam = request.getParameter("fechaFin");

        Integer idSucursal = null;
        Integer idTipo = null;

        Timestamp fechaInicio = null;
        Timestamp fechaFin = null;

        String mensajeFiltro = null;

        try {
            if (idSucursalParam != null && !idSucursalParam.trim().isEmpty()) {
                idSucursal = Integer.parseInt(idSucursalParam);
            }

            if (idTipoParam != null && !idTipoParam.trim().isEmpty()) {
                idTipo = Integer.parseInt(idTipoParam);
            }

            if (fechaInicioParam != null && !fechaInicioParam.trim().isEmpty()
                    && fechaFinParam != null && !fechaFinParam.trim().isEmpty()) {

                LocalDate inicio = LocalDate.parse(fechaInicioParam);
                LocalDate fin = LocalDate.parse(fechaFinParam);

                if (!fin.isAfter(inicio)) {
                    mensajeFiltro = "La fecha de devolución debe ser posterior a la fecha de inicio.";
                } else {
                    fechaInicio = Timestamp.valueOf(fechaInicioParam + " 00:00:00");
                    fechaFin = Timestamp.valueOf(fechaFinParam + " 23:59:59");
                }

            } else if (
                    (fechaInicioParam != null && !fechaInicioParam.trim().isEmpty())
                    || (fechaFinParam != null && !fechaFinParam.trim().isEmpty())) {

                mensajeFiltro = "Para buscar por fechas debe ingresar fecha de inicio y fecha de devolución.";
            }

        } catch (Exception e) {
            mensajeFiltro = "Los filtros ingresados no son válidos.";
        }

        VehiculoCatalogoDAO vehiculoDAO = new VehiculoCatalogoDAO();

        List<VehiculoCatalogo> vehiculos =
                vehiculoDAO.listarCatalogo(
                        idSucursal,
                        idTipo,
                        fechaInicio,
                        fechaFin
                );

        CatalogoDAO catalogoDAO = new CatalogoDAO();

        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("sucursales", catalogoDAO.listarSucursales());
        request.setAttribute("tipos", catalogoDAO.listarTiposVehiculo());

        request.setAttribute("idSucursalSeleccionada", idSucursalParam);
        request.setAttribute("idTipoSeleccionado", idTipoParam);
        request.setAttribute("fechaInicio", fechaInicioParam);
        request.setAttribute("fechaFin", fechaFinParam);
        request.setAttribute("mensajeFiltro", mensajeFiltro);

        request.getRequestDispatcher("/catalogoVehiculos.jsp")
                .forward(request, response);
    }
}