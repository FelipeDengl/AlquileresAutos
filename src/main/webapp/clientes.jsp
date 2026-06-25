<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Cliente"%>
<%@page import="java.util.List"%>

<jsp:include page="header.jsp" />

<!-- Header Banner -->
<div class="container-fluid bg-breadcrumb">
    <div class="container text-center py-5" style="max-width: 900px;">
        <h4 class="text-white display-4 mb-4 wow fadeInDown" data-wow-delay="0.1s">Listado de Clientes</h4>
    </div>
</div>

<div class="container-fluid py-5">
    <div class="container py-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0">Clientes Registrados</h2>
            <a href="altaCliente.jsp" class="btn btn-primary rounded-pill py-2 px-4">Nuevo Cliente</a>
        </div>

        <div class="table-responsive shadow-sm rounded">
            <table class="table table-striped table-hover mb-0">
                <thead class="table-dark">
                    <tr>
                        <th scope="col">ID</th>
                        <th scope="col">DNI</th>
                        <th scope="col">Nombre</th>
                        <th scope="col">Teléfono</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
                    if (clientes != null && !clientes.isEmpty()) {
                        for(Cliente c : clientes){
                %>
                    <tr>
                        <td><%= c.getIdUsuario() %></td>
                        <td><%= c.getDni() %></td>
                        <td><%= c.getNombreYapellido() %></td>
                        <td><%= c.getTelefono() %></td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="4" class="text-center py-4">No hay clientes registrados o debe realizar la búsqueda primero.</td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />