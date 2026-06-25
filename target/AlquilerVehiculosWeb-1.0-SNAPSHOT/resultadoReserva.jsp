<%@page contentType="text/html" pageEncoding="UTF-8"%>

<jsp:include page="header.jsp" />

<%
    Boolean exito = (Boolean) request.getAttribute("exito");
    String titulo = (String) request.getAttribute("titulo");
    String mensaje = (String) request.getAttribute("mensaje");
    Integer idReserva = (Integer) request.getAttribute("idReserva");
    String nombreVehiculo = (String) request.getAttribute("nombreVehiculo");
    String fechaInicio = (String) request.getAttribute("fechaInicio");
    String fechaFin = (String) request.getAttribute("fechaFin");
    Integer diasEstimados = (Integer) request.getAttribute("diasEstimados");
    Double totalEstimado = (Double) request.getAttribute("totalEstimado");

    if (exito == null) {
        exito = false;
    }

    if (titulo == null) {
        titulo = "Resultado de la operación";
    }

    if (mensaje == null) {
        mensaje = "Operación finalizada.";
    }

    if (idReserva == null) {
        idReserva = 0;
    }

    if (nombreVehiculo == null) {
        nombreVehiculo = "";
    }

    if (fechaInicio == null) {
        fechaInicio = "";
    }

    if (fechaFin == null) {
        fechaFin = "";
    }

    if (diasEstimados == null) {
        diasEstimados = 0;
    }

    if (totalEstimado == null) {
        totalEstimado = 0.0;
    }
%>

<div class="container-fluid py-5 bg-light">
    <div class="container py-5">

        <div class="row justify-content-center">
            <div class="col-lg-7">

                <div class="card shadow-sm border-0 rounded">
                    <div class="card-body p-5">

                        <% if (exito) { %>

                            <h5 class="text-primary text-uppercase fw-bold mb-3">
                                Reserva registrada
                            </h5>

                            <h1 class="mb-4">
                                Tu solicitud fue guardada correctamente
                            </h1>

                            <p class="fs-5 text-muted mb-4">
                                Creamos la reserva
                                <% if (idReserva > 0) { %>
                                    #<%= idReserva %>
                                <% } %>
                                <% if (!nombreVehiculo.isEmpty()) { %>
                                    para <%= nombreVehiculo %>.
                                <% } %>
                            </p>

                            <div class="bg-light rounded p-4 mb-4">

                                <p class="mb-2">
                                    <strong>Fechas:</strong>
                                    <%= fechaInicio %> al <%= fechaFin %>
                                </p>

                                <p class="mb-2">
                                    <strong>Duración estimada:</strong>
                                    <%= diasEstimados %>
                                    <%= diasEstimados == 1 ? "día" : "días" %>
                                </p>

                                <p class="mb-0">
                                    <strong>Total estimado:</strong>
                                    $<%= String.format("%,.2f", totalEstimado) %>
                                </p>

                            </div>

                            <div class="row g-3">

                                <div class="col-md-6">
                                    <a href="catalogoVehiculos"
                                       class="btn btn-primary rounded py-3 w-100">
                                        Seguir viendo
                                    </a>
                                </div>

                                <div class="col-md-6">
                                    <a href="index.jsp"
                                       class="btn btn-outline-primary rounded py-3 w-100">
                                        Ir al inicio
                                    </a>
                                </div>

                            </div>

                        <% } else { %>

                            <h5 class="text-danger text-uppercase fw-bold mb-3">
                                Reserva no registrada
                            </h5>

                            <h1 class="mb-4">
                                No se pudo completar la reserva
                            </h1>

                            <div class="alert alert-warning fs-5">
                                <%= mensaje %>
                            </div>

                            <div class="row g-3 mt-4">

                                <div class="col-md-6">
                                    <a href="catalogoVehiculos"
                                       class="btn btn-primary rounded py-3 w-100">
                                        Volver al catálogo
                                    </a>
                                </div>

                                <div class="col-md-6">
                                    <a href="index.jsp"
                                       class="btn btn-outline-primary rounded py-3 w-100">
                                        Ir al inicio
                                    </a>
                                </div>

                            </div>

                        <% } %>

                    </div>
                </div>

            </div>
        </div>

    </div>
</div>

<jsp:include page="footer.jsp" />