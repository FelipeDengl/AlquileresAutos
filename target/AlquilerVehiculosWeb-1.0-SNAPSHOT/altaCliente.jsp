<%@page contentType="text/html" pageEncoding="UTF-8"%>

<jsp:include page="header.jsp" />

<%
    String nroPatente = request.getParameter("nroPatente");
    String fechaInicio = request.getParameter("fechaInicio");
    String fechaFin = request.getParameter("fechaFin");

    if (nroPatente == null) {
        nroPatente = "";
    }

    if (fechaInicio == null) {
        fechaInicio = "";
    }

    if (fechaFin == null) {
        fechaFin = "";
    }
%>

<!-- Header Banner -->
<div class="container-fluid bg-breadcrumb">
    <div class="container text-center py-5" style="max-width: 900px;">

        <h4 class="text-white display-4 mb-4 wow fadeInDown" data-wow-delay="0.1s">
            Registro de Cliente
        </h4>

        <p class="text-white">
            Registrá tus datos para poder realizar una reserva.
        </p>

    </div>
</div>


<div class="container-fluid py-5">
    <div class="container py-5">

        <div class="row justify-content-center">
            <div class="col-lg-8">

                <div class="card shadow-sm border-0 rounded">

                    <div class="card-header bg-primary text-white text-center py-3">
                        <h4 class="mb-0 text-white">
                            <i class="fa fa-user-plus me-2"></i>
                            Crear cuenta de cliente
                        </h4>
                    </div>

                    <div class="card-body p-5">

                        <% if (!nroPatente.isEmpty()) { %>

                            <div class="alert alert-info">
                                <strong>Vehículo seleccionado:</strong>
                                <%= nroPatente %>

                                <% if (!fechaInicio.isEmpty() && !fechaFin.isEmpty()) { %>
                                    <br>
                                    <strong>Desde:</strong> <%= fechaInicio %>
                                    <br>
                                    <strong>Hasta:</strong> <%= fechaFin %>
                                <% } %>
                            </div>

                        <% } %>

                        <form action="AltaClienteServlet" method="post">

                            <input 
                                type="hidden"
                                name="nroPatente"
                                value="<%= nroPatente %>">

                            <input 
                                type="hidden"
                                name="fechaInicio"
                                value="<%= fechaInicio %>">

                            <input 
                                type="hidden"
                                name="fechaFin"
                                value="<%= fechaFin %>">

                            <div class="row g-3">

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Usuario:
                                    </label>

                                    <input 
                                        type="text"
                                        class="form-control"
                                        name="usuario"
                                        placeholder="Ingrese el usuario"
                                        required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Contraseña:
                                    </label>

                                    <input 
                                        type="password"
                                        class="form-control"
                                        name="contrasenia"
                                        placeholder="Ingrese la contraseña"
                                        required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        DNI:
                                    </label>

                                    <input 
                                        type="text"
                                        class="form-control"
                                        name="dni"
                                        placeholder="Ingrese DNI"
                                        required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Nombre completo:
                                    </label>

                                    <input 
                                        type="text"
                                        class="form-control"
                                        name="nombre"
                                        placeholder="Ingrese nombre y apellido"
                                        required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Teléfono:
                                    </label>

                                    <input 
                                        type="text"
                                        class="form-control"
                                        name="telefono"
                                        placeholder="Ingrese teléfono"
                                        required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Fecha de nacimiento:
                                    </label>

                                    <input 
                                        type="date"
                                        class="form-control"
                                        name="fechaNacimiento"
                                        required>
                                </div>

                                <div class="col-12 mt-4 text-center">

                                    <button 
                                        type="submit"
                                        class="btn btn-primary rounded-pill py-3 px-5">
                                        <i class="fa fa-save me-2"></i>
                                        Registrarse
                                    </button>

                                    <a 
                                        href="loginCliente?nroPatente=<%= nroPatente %>&fechaInicio=<%= fechaInicio %>&fechaFin=<%= fechaFin %>"
                                        class="btn btn-outline-primary rounded-pill py-3 px-5 ms-2">
                                        Ya tengo cuenta
                                    </a>

                                </div>

                            </div>

                        </form>

                    </div>

                </div>

            </div>
        </div>

    </div>
</div>

<jsp:include page="footer.jsp" />