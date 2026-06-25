package servlet;

import dao.VehiculoDAO;
import modelo.Vehiculo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/vehiculos")
public class VehiculoServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer idTipoEstado = null;

        String parametroEstado = request.getParameter("idTipoEstado");

        if (parametroEstado != null && !parametroEstado.trim().isEmpty()) {
            try {
                idTipoEstado = Integer.parseInt(parametroEstado);
            } catch (NumberFormatException e) {
                idTipoEstado = null;
            }
        }

        VehiculoDAO dao = new VehiculoDAO();

        List<Vehiculo> vehiculos = dao.listarVehiculos(idTipoEstado);

        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("idTipoEstadoSeleccionado", idTipoEstado);

        request.getRequestDispatcher("/vehiculos.jsp")
                .forward(request, response);
    }
}