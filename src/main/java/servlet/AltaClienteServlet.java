package servlet;

import dao.ClienteDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;

@WebServlet("/AltaClienteServlet")
public class AltaClienteServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String usuario = request.getParameter("usuario");
        String contrasenia = request.getParameter("contrasenia");
        String dni = request.getParameter("dni");
        String nombre = request.getParameter("nombre");
        String telefono = request.getParameter("telefono");

        String nroPatente = request.getParameter("nroPatente");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        Date fechaNacimiento =
                Date.valueOf(
                        request.getParameter("fechaNacimiento")
                );

        ClienteDAO dao = new ClienteDAO();

        String resultado =
                dao.altaCliente(
                        usuario,
                        contrasenia,
                        dni,
                        nombre,
                        telefono,
                        fechaNacimiento
                );

        if (esAltaExitosa(resultado)) {

            String url = "loginCliente?registrado=ok";

            if (nroPatente != null && !nroPatente.trim().isEmpty()) {
                url += "&nroPatente=" + URLEncoder.encode(nroPatente, "UTF-8");
            }

            if (fechaInicio != null && !fechaInicio.trim().isEmpty()) {
                url += "&fechaInicio=" + URLEncoder.encode(fechaInicio, "UTF-8");
            }

            if (fechaFin != null && !fechaFin.trim().isEmpty()) {
                url += "&fechaFin=" + URLEncoder.encode(fechaFin, "UTF-8");
            }

            response.sendRedirect(url);

        } else {

            request.setAttribute("mensaje", resultado);

            request.getRequestDispatcher("/resultado.jsp")
                    .forward(request, response);
        }
    }

    private boolean esAltaExitosa(String resultado) {

        if (resultado == null) {
            return false;
        }

        String texto = resultado.toLowerCase();

        return texto.contains("éxito")
                || texto.contains("exito")
                || texto.contains("correctamente")
                || texto.contains("registrado")
                || texto.contains("guardado");
    }
}