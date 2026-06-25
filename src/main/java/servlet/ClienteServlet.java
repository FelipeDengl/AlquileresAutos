package servlet;

import dao.ClienteDAO;
import modelo.Cliente;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/clientes")
public class ClienteServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        ClienteDAO dao = new ClienteDAO();

        List<Cliente> clientes =
                dao.listarClientes();

        request.setAttribute(
                "clientes",
                clientes
        );

        request.getRequestDispatcher(
                "/clientes.jsp"
        ).forward(
                request,
                response
        );
    }
}