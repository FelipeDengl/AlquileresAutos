<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.VehiculoCatalogo"%>
<%@page import="modelo.Opcion"%>
<%@page import="java.util.List"%>
<%@page import="java.net.URLEncoder"%>

<jsp:include page="header.jsp" />

<%
    String idSucursalSeleccionada = (String) request.getAttribute("idSucursalSeleccionada");
    String idTipoSeleccionado = (String) request.getAttribute("idTipoSeleccionado");
    String fechaInicio = (String) request.getAttribute("fechaInicio");
    String fechaFin = (String) request.getAttribute("fechaFin");
    String mensajeFiltro = (String) request.getAttribute("mensajeFiltro");

    if (idSucursalSeleccionada == null) {
        idSucursalSeleccionada = "";
    }

    if (idTipoSeleccionado == null) {
        idTipoSeleccionado = "";
    }

    if (fechaInicio == null) {
        fechaInicio = "";
    }

    if (fechaFin == null) {
        fechaFin = "";
    }

    List<Opcion> sucursales =
            (List<Opcion>) request.getAttribute("sucursales");

    List<Opcion> tipos =
            (List<Opcion>) request.getAttribute("tipos");
%>

<!-- Header Start -->
<div class="container-fluid bg-breadcrumb">
    <div class="container text-center py-5" style="max-width: 900px;">

        <h4 class="text-white display-4 mb-4">
            Catálogo de Vehículos
        </h4>

        <p class="text-white">
            Consultá la flota de vehículos y buscá disponibilidad por sucursal, tipo y fechas.
        </p>

    </div>
</div>
<!-- Header End -->


<!-- Buscador Start -->
<div class="container-fluid py-5 bg-light">
    <div class="container">

        <div class="row justify-content-center">
            <div class="col-lg-9">

                <div class="card shadow-sm border-0 rounded">
                    <div class="card-body p-4">

                        <h3 class="mb-4">
                            Buscar vehículos
                        </h3>

                        <% if (mensajeFiltro != null) { %>
                            <div class="alert alert-warning">
                                <%= mensajeFiltro %>
                            </div>
                        <% } %>

                        <form action="catalogoVehiculos" method="get">

                            <div class="row g-4">

                                <!-- Sucursal -->
                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Sucursal
                                    </label>

                                    <select name="idSucursal" class="form-select">
                                        <option value="">Todas</option>

                                        <%
                                            if (sucursales != null) {
                                                for (Opcion s : sucursales) {

                                                    String selected = "";

                                                    if (String.valueOf(s.getId()).equals(idSucursalSeleccionada)) {
                                                        selected = "selected";
                                                    }
                                        %>

                                            <option value="<%= s.getId() %>" <%= selected %>>
                                                <%= s.getNombre() %>
                                            </option>

                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </div>

                                <!-- Tipo -->
                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Tipo de vehículo
                                    </label>

                                    <select name="idTipo" class="form-select">
                                        <option value="">Todos</option>

                                        <%
                                            if (tipos != null) {
                                                for (Opcion t : tipos) {

                                                    String selected = "";

                                                    if (String.valueOf(t.getId()).equals(idTipoSeleccionado)) {
                                                        selected = "selected";
                                                    }
                                        %>

                                            <option value="<%= t.getId() %>" <%= selected %>>
                                                <%= t.getNombre() %>
                                            </option>

                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </div>

                                <!-- Fecha inicio -->
                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Fecha de inicio
                                    </label>

                                    <input 
                                        type="date"
                                        name="fechaInicio"
                                        class="form-control"
                                        value="<%= fechaInicio %>">
                                </div>

                                <!-- Fecha fin -->
                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Fecha de devolución
                                    </label>

                                    <input 
                                        type="date"
                                        name="fechaFin"
                                        class="form-control"
                                        value="<%= fechaFin %>">
                                </div>

                                <!-- Botón buscar -->
                                <div class="col-12">
                                    <button 
                                        type="submit"
                                        class="btn btn-primary w-100 rounded py-3">
                                        Buscar vehículos
                                    </button>
                                </div>

                            </div>

                        </form>

                    </div>
                </div>

            </div>
        </div>

    </div>
</div>
<!-- Buscador End -->


<!-- Catalogo Start -->
<div class="container-fluid py-5">
    <div class="container py-5">

        <div class="text-center mx-auto mb-5" style="max-width: 750px;">

            <h1 class="display-5 text-capitalize mb-3">
                Flota de <span class="text-primary">Vehículos</span>
            </h1>

            <% if (!fechaInicio.isEmpty() && !fechaFin.isEmpty()) { %>

                <p class="mb-0">
                    Vehículos disponibles desde 
                    <strong><%= fechaInicio %></strong>
                    hasta 
                    <strong><%= fechaFin %></strong>.
                </p>

            <% } else { %>

                <p class="mb-0">
                    Seleccioná un vehículo para consultar sus días disponibles y solicitar una reserva.
                </p>

            <% } %>

        </div>

        <div class="row g-4">

            <%
                List<VehiculoCatalogo> vehiculos =
                        (List<VehiculoCatalogo>) request.getAttribute("vehiculos");

                if (vehiculos != null && !vehiculos.isEmpty()) {

                    for (VehiculoCatalogo v : vehiculos) {

                        String imagen = v.getUrlImagen();

                        if (imagen == null || imagen.trim().isEmpty()) {
                            imagen = "img/car-1.png";
                        }

                        /*
                            Si la imagen viene como ruta local, por ejemplo:
                            img/vehiculos/corolla.jpg

                            Se convierte en:
                            /NombreDelProyecto/img/vehiculos/corolla.jpg

                            Esto evita errores de rutas relativas.
                        */
                        String srcImagen = imagen;

                        if (!imagen.startsWith("http")) {
                            srcImagen = request.getContextPath() + "/" + imagen;
                        }

                        String imagenFallback =
                                request.getContextPath() + "/img/car-1.png";

                        String patenteUrl = URLEncoder.encode(
                                v.getNroPatente(),
                                "UTF-8"
                        );

                        String reservaUrl = "loginCliente?nroPatente=" + patenteUrl;

                        if (!fechaInicio.isEmpty() && !fechaFin.isEmpty()) {
                            reservaUrl += "&fechaInicio="
                                    + URLEncoder.encode(fechaInicio, "UTF-8")
                                    + "&fechaFin="
                                    + URLEncoder.encode(fechaFin, "UTF-8");
                        }
            %>

            <div class="col-lg-4 col-md-6">
                <div class="categories-item h-100 shadow-sm rounded">

                    <!-- Imagen -->
                    <div class="categories-img rounded-top overflow-hidden" style="height: 240px;">
                        <img 
                            src="<%= srcImagen %>"
                            class="img-fluid w-100 h-100"
                            style="object-fit: cover;"
                            alt="Vehículo <%= v.getNombreMarca() %> <%= v.getNombreModelo() %>"
                            onerror="this.onerror=null; this.src='<%= imagenFallback %>';">
                    </div>

                    <!-- Contenido -->
                    <div class="categories-content p-4">

                        <h4 class="mb-3">
                            <%= v.getNombreMarca() %> <%= v.getNombreModelo() %>
                        </h4>

                        <div class="mb-3">
                            <span class="badge bg-primary rounded-pill px-3 py-2">
                                <%= v.getNombreTipo() %>
                            </span>
                        </div>

                        <p class="mb-2">
                            <strong>Patente:</strong>
                            <%= v.getNroPatente() %>
                        </p>

                        <p class="mb-2">
                            <strong>Sucursal:</strong>
                            <%= v.getNombreSucursal() %>
                        </p>

                        <p class="mb-2">
                            <strong>Ubicación:</strong>
                            <%= v.getUbicacion() %>
                        </p>

                        <p class="mb-3">
                            <strong>Confort:</strong>
                            <%= v.getDetalleConfort() %>
                        </p>

                        <hr>

                        <div class="mb-3">

                            <% if (v.getValorDiario() > 0) { %>

                                <h4 class="text-primary mb-1">
                                    $<%= String.format("%,.2f", v.getValorDiario()) %>
                                    <span class="text-muted fs-6">/ día</span>
                                </h4>

                                <small class="text-muted">
                                    Recargo por hora excedida:
                                    <%= v.getPorcentajeRecargoHora() %>%
                                </small>

                            <% } else { %>

                                <h5 class="text-muted mb-1">
                                    Tarifa no asignada
                                </h5>

                                <small class="text-muted">
                                    Consulte precio con la empresa.
                                </small>

                            <% } %>

                        </div>

                        <div class="text-center mt-4">
                            <a 
                                href="<%= reservaUrl %>"
                                class="btn btn-primary rounded-pill py-3 px-5">
                                Reservar
                            </a>
                        </div>

                    </div>

                </div>
            </div>

            <%
                    }

                } else {
            %>

            <div class="col-12">
                <div class="alert alert-info text-center shadow-sm">
                    No se encontraron vehículos para los filtros seleccionados.
                </div>
            </div>

            <%
                }
            %>

        </div>

    </div>
</div>
<!-- Catalogo End -->


<jsp:include page="footer.jsp" />