package servlet;

import dao.ReservaDAO;
import modelo.VehiculoCatalogo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@WebServlet("/registrarReserva")
public class RegistrarReservaServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("idUsuario") == null) {
            response.sendRedirect("loginCliente");
            return;
        }

        String nroPatente = request.getParameter("nroPatente");
        String fechaInicioParam = request.getParameter("fechaInicio");
        String fechaFinParam = request.getParameter("fechaFin");

        try {

            if (nroPatente == null || nroPatente.trim().isEmpty()
                    || fechaInicioParam == null || fechaInicioParam.trim().isEmpty()
                    || fechaFinParam == null || fechaFinParam.trim().isEmpty()) {

                enviarResultado(
                        request,
                        response,
                        false,
                        "Datos incompletos",
                        "Faltan datos para registrar la reserva.",
                        0,
                        "",
                        fechaInicioParam,
                        fechaFinParam,
                        0,
                        0
                );
                return;
            }

            LocalDate fechaInicioDate = LocalDate.parse(fechaInicioParam);
            LocalDate fechaFinDate = LocalDate.parse(fechaFinParam);

            if (!fechaFinDate.isAfter(fechaInicioDate)) {

                enviarResultado(
                        request,
                        response,
                        false,
                        "Fechas inválidas",
                        "La fecha de devolución debe ser posterior a la fecha de inicio.",
                        0,
                        nroPatente,
                        fechaInicioParam,
                        fechaFinParam,
                        0,
                        0
                );
                return;
            }

            int diasEstimados = (int) ChronoUnit.DAYS.between(
                    fechaInicioDate,
                    fechaFinDate
            );

            Integer idUsuario =
                    (Integer) session.getAttribute("idUsuario");

            Timestamp fechaInicio =
                    Timestamp.valueOf(fechaInicioParam + " 00:00:00");

            Timestamp fechaFin =
                    Timestamp.valueOf(fechaFinParam + " 23:59:59");

            ReservaDAO dao = new ReservaDAO();

            VehiculoCatalogo vehiculo =
                    dao.obtenerVehiculoParaReserva(nroPatente);

            double valorDiario = 0;

            String nombreVehiculo = nroPatente;

            if (vehiculo != null) {
                valorDiario = vehiculo.getValorDiario();
                nombreVehiculo =
                        vehiculo.getNombreMarca() + " " + vehiculo.getNombreModelo();
            }

            double totalEstimado = diasEstimados * valorDiario;

            String resultado =
                    dao.registrarReserva(
                            idUsuario,
                            nroPatente,
                            fechaInicio,
                            fechaFin
                    );

            boolean exito =
                    resultado != null
                    && (
                        resultado.toLowerCase().contains("éxito")
                        || resultado.toLowerCase().contains("exito")
                        || resultado.toLowerCase().contains("correctamente")
                        || resultado.toLowerCase().contains("registrada")
                    );

            int idReserva = 0;

            if (exito) {
                idReserva =
                        dao.obtenerUltimaReserva(
                                idUsuario,
                                nroPatente,
                                fechaInicio,
                                fechaFin
                        );
            }

            enviarResultado(
                    request,
                    response,
                    exito,
                    exito ? "Reserva registrada" : "No se pudo registrar la reserva",
                    resultado,
                    idReserva,
                    nombreVehiculo,
                    fechaInicioParam,
                    fechaFinParam,
                    diasEstimados,
                    totalEstimado
            );

        } catch (Exception e) {

            e.printStackTrace();

            enviarResultado(
                    request,
                    response,
                    false,
                    "Error al registrar la reserva",
                    "Ocurrió un error al procesar la reserva: " + e.getMessage(),
                    0,
                    nroPatente,
                    fechaInicioParam,
                    fechaFinParam,
                    0,
                    0
            );
        }
    }

    private void enviarResultado(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean exito,
            String titulo,
            String mensaje,
            int idReserva,
            String nombreVehiculo,
            String fechaInicio,
            String fechaFin,
            int diasEstimados,
            double totalEstimado)
            throws ServletException, IOException {

        request.setAttribute("exito", exito);
        request.setAttribute("titulo", titulo);
        request.setAttribute("mensaje", mensaje);
        request.setAttribute("idReserva", idReserva);
        request.setAttribute("nombreVehiculo", nombreVehiculo);
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("diasEstimados", diasEstimados);
        request.setAttribute("totalEstimado", totalEstimado);

        request.getRequestDispatcher("/resultadoReserva.jsp")
                .forward(request, response);
    }
}