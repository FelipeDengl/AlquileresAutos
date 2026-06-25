<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.net.URLEncoder"%>

<jsp:include page="header.jsp" />

<%
    String nroPatente = (String) request.getAttribute("nroPatente");
    String fechaInicio = (String) request.getAttribute("fechaInicio");
    String fechaFin = (String) request.getAttribute("fechaFin");
    String mensaje = (String) request.getAttribute("mensaje");

    String registrado = request.getParameter("registrado");

    if (nroPatente == null) {
        nroPatente = request.getParameter("nroPatente");
    }

    if (fechaInicio == null) {
        fechaInicio = request.getParameter("fechaInicio");
    }

    if (fechaFin == null) {
        fechaFin = request.getParameter("fechaFin");
    }

    if (nroPatente == null) {
        nroPatente = "";
    }

    if (fechaInicio == null) {
        fechaInicio = "";
    }

    if (fechaFin == null) {
        fechaFin = "";
    }

    String registroUrl = "altaCliente.jsp";

    if (!nroPatente.isEmpty()) {

        registroUrl += "?nroPatente=" + URLEncoder.encode(nroPatente, "UTF-8");

        if (!fechaInicio.isEmpty()) {
            registroUrl += "&fechaInicio=" + URLEncoder.encode(fechaInicio, "UTF-8");
        }

        if (!fechaFin.isEmpty()) {
            registroUrl += "&fechaFin=" + URLEncoder.encode(fechaFin, "UTF-8");
        }
    }
%>

<!-- Header Start -->
<div class="container-fluid bg-breadcrumb">
    <div class="container text-center py-5" style="max-width: 900px;">

        <h4 class="text-white display-4 mb-4">
            Iniciar sesión
        </h4>

        <p class="text-white">
            Iniciá sesión para continuar con la reserva del vehículo.
        </p>

    </div>
</div>
<!-- Header End -->


<!-- Login Start -->
<div class="container-fluid py-5">
    <div class="container py-5">

        <div class="row justify-content-center">
            <div class="col-lg-6 col-md-8">

                <div class="card shadow-sm border-0 rounded">

                    <div class="card-header bg-primary text-white text-center py-3">
                        <h4 class="mb-0 text-white">
                            Acceso de Cliente
                        </h4>
                    </div>

                    <div class="card-body p-5">

                        <% if ("ok".equals(registrado)) { %>

                            <div class="alert alert-success text-center">
                                Registro realizado correctamente. Ahora iniciá sesión para continuar con la reserva.
                            </div>

                        <% } %>

                        <% if (mensaje != null) { %>

                            <div class="alert alert-danger text-center">
                                <%= mensaje %>
                            </div>

                        <% } %>

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

                        <form action="loginCliente" method="post">

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

                            <div class="mb-3">
                                <label class="form-label text-dark fw-bold">
                                    Usuario
                                </label>

                                <input 
                                    type="text"
                                    name="usuario"
                                    class="form-control"
                                    placeholder="Ingrese su usuario"
                                    required>
                            </div>

                            <div class="mb-4">
                                <label class="form-label text-dark fw-bold">
                                    Contraseña
                                </label>

                                <input 
                                    type="password"
                                    name="contrasenia"
                                    class="form-control"
                                    placeholder="Ingrese su contraseña"
                                    required>
                            </div>

                            <div class="d-grid">
                                <button 
                                    type="submit"
                                    class="btn btn-primary rounded-pill py-3">
                                    Iniciar sesión
                                </button>
                            </div>

                        </form>

                        <hr class="my-4">

                        <div class="text-center">

                            <p class="mb-2">
                                ¿Todavía no tenés cuenta?
                            </p>

                            <a 
                                href="<%= registroUrl %>"
                                class="btn btn-outline-primary rounded-pill py-2 px-4">
                                Registrarse
                            </a>

                            <div class="mt-3">
                                <a href="catalogoVehiculos" class="text-muted">
                                    Volver al catálogo
                                </a>
                            </div>

                        </div>

                    </div>

                </div>

            </div>
        </div>

    </div>
</div>
<!-- Login End -->


<jsp:include page="footer.jsp" />