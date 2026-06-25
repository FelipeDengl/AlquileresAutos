package servlet;

import dao.ReservaDAO;
import modelo.PeriodoOcupacion;
import modelo.VehiculoCatalogo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

@WebServlet("/prepararReserva")
public class PrepararReservaServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String nroPatente = request.getParameter("nroPatente");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("idUsuario") == null) {

            String url = "loginCliente";

            if (nroPatente != null && !nroPatente.trim().isEmpty()) {
                url += "?nroPatente=" + URLEncoder.encode(nroPatente, "UTF-8");
            }

            response.sendRedirect(url);
            return;
        }

        if (nroPatente == null || nroPatente.trim().isEmpty()) {
            response.sendRedirect("catalogoVehiculos");
            return;
        }

        ReservaDAO dao = new ReservaDAO();

        VehiculoCatalogo vehiculo =
                dao.obtenerVehiculoParaReserva(nroPatente);

        List<PeriodoOcupacion> periodosOcupados =
                dao.obtenerPeriodosOcupados(nroPatente);

        if (vehiculo == null) {
            request.setAttribute("titulo", "Vehículo no encontrado");
            request.setAttribute("mensaje", "No se encontró el vehículo seleccionado.");
            request.setAttribute("exito", false);

            request.getRequestDispatcher("/resultadoReserva.jsp")
                    .forward(request, response);
            return;
        }

        request.setAttribute("vehiculo", vehiculo);
        request.setAttribute("periodosOcupados", periodosOcupados);
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);

        request.getRequestDispatcher("/reservaVehiculo.jsp")
                .forward(request, response);
    }
}