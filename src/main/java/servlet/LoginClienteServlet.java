package servlet;

import dao.LoginClienteDAO;
import modelo.ClienteSesion;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

@WebServlet("/loginCliente")
public class LoginClienteServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String nroPatente = request.getParameter("nroPatente");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("idUsuario") != null) {

            if (nroPatente != null && !nroPatente.trim().isEmpty()) {
                response.sendRedirect(
                        armarUrlReserva(nroPatente, fechaInicio, fechaFin)
                );
                return;
            }
        }

        request.setAttribute("nroPatente", nroPatente);
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);

        request.getRequestDispatcher("/loginCliente.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String usuario = request.getParameter("usuario");
        String contrasenia = request.getParameter("contrasenia");

        String nroPatente = request.getParameter("nroPatente");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        LoginClienteDAO dao = new LoginClienteDAO();

        ClienteSesion cliente =
                dao.validarCliente(usuario, contrasenia);

        if (cliente != null) {

            HttpSession session = request.getSession();

            session.setAttribute(
                    "idUsuario",
                    cliente.getIdUsuario()
            );

            session.setAttribute(
                    "nombreCliente",
                    cliente.getNombreYapellido()
            );

            session.setAttribute(
                    "dniCliente",
                    cliente.getDni()
            );

            if (nroPatente != null && !nroPatente.trim().isEmpty()) {

                response.sendRedirect(
                        armarUrlReserva(nroPatente, fechaInicio, fechaFin)
                );

            } else {

                response.sendRedirect("catalogoVehiculos");
            }

        } else {

            request.setAttribute(
                    "mensaje",
                    "Usuario o contraseña incorrectos."
            );

            request.setAttribute("nroPatente", nroPatente);
            request.setAttribute("fechaInicio", fechaInicio);
            request.setAttribute("fechaFin", fechaFin);

            request.getRequestDispatcher("/loginCliente.jsp")
                    .forward(request, response);
        }
    }

    private String armarUrlReserva(
            String nroPatente,
            String fechaInicio,
            String fechaFin)
            throws UnsupportedEncodingException {

        String url = "prepararReserva?nroPatente="
                + URLEncoder.encode(nroPatente, "UTF-8");

        if (fechaInicio != null && !fechaInicio.trim().isEmpty()) {
            url += "&fechaInicio="
                    + URLEncoder.encode(fechaInicio, "UTF-8");
        }

        if (fechaFin != null && !fechaFin.trim().isEmpty()) {
            url += "&fechaFin="
                    + URLEncoder.encode(fechaFin, "UTF-8");
        }

        return url;
    }
}