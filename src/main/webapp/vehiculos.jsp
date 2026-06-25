<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Vehiculo"%>
<%@page import="java.util.List"%>

<jsp:include page="header.jsp" />

<div class="container-fluid bg-breadcrumb">
    <div class="container text-center py-5" style="max-width: 900px;">
        <h4 class="text-white display-4 mb-4 wow fadeInDown" data-wow-delay="0.1s">
            Listado de Vehículos
        </h4>
    </div>
</div>

<div class="container-fluid py-5">
    <div class="container py-5">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0">Vehículos Registrados</h2>
            <a href="index.jsp" class="btn btn-outline-primary rounded-pill py-2 px-4">
                Volver al inicio
            </a>
        </div>

        <form action="vehiculos" method="get" class="mb-4">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label text-dark fw-bold">Filtrar por estado</label>
                    <select name="idTipoEstado" class="form-select">
                        <option value="">Todos</option>
                        <option value="1">DISPONIBLE</option>
                        <option value="2">MANTENIMIENTO</option>
                        <option value="3">BAJA</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <button type="submit" class="btn btn-primary rounded-pill py-2 px-4">
                        Filtrar
                    </button>
                </div>
            </div>
        </form>

        <div class="table-responsive shadow-sm rounded">
            <table class="table table-striped table-hover mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>Patente</th>
                        <th>Marca</th>
                        <th>Modelo</th>
                        <th>Tipo</th>
                        <th>Estado</th>
                        <th>Sucursal</th>
                        <th>Confort</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    List<Vehiculo> vehiculos =
                            (List<Vehiculo>) request.getAttribute("vehiculos");

                    if (vehiculos != null && !vehiculos.isEmpty()) {
                        for (Vehiculo v : vehiculos) {
                %>
                    <tr>
                        <td><%= v.getNroPatente() %></td>
                        <td><%= v.getNombreMarca() %></td>
                        <td><%= v.getNombreModelo() %></td>
                        <td><%= v.getNombreTipo() %></td>
                        <td>
                            <span class="badge bg-primary">
                                <%= v.getNombreTipoEstado() %>
                            </span>
                        </td>
                        <td><%= v.getNombreSucursal() %></td>
                        <td><%= v.getDetalleConfort() %></td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="7" class="text-center py-4">
                            No se encontraron vehículos registrados.
                        </td>
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