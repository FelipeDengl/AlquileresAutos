<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="header.jsp" />

<!-- Header Banner -->
<div class="container-fluid bg-breadcrumb">
    <div class="container text-center py-5" style="max-width: 900px;">
        <h4 class="text-white display-4 mb-4 wow fadeInDown" data-wow-delay="0.1s">Resultado de la Operación</h4>
    </div>
</div>

<div class="container-fluid py-5">
    <div class="container py-5 text-center">
        <div class="row justify-content-center">
            <div class="col-lg-6">
                <% 
                    String mensaje = (String) request.getAttribute("mensaje");
                    boolean esExito = mensaje != null && (mensaje.toLowerCase().contains("éxito") || mensaje.toLowerCase().contains("correctamente") || mensaje.toLowerCase().contains("guardado"));
                    String alertClass = esExito ? "alert-success" : "alert-info";
                    String iconClass = esExito ? "fa-check-circle text-success" : "fa-info-circle text-info";
                %>
                
                <div class="alert <%= alertClass %> shadow-sm py-4" role="alert">
                    <i class="fa <%= iconClass %> fa-3x mb-3"></i>
                    <h3 class="alert-heading mb-3"><%= mensaje != null ? mensaje : "Operación finalizada" %></h3>
                    <hr>
                    <div class="mt-4">
                        <a href="clientes" class="btn btn-primary rounded-pill py-2 px-4 me-2"><i class="fa fa-list me-2"></i>Ver Clientes</a>
                        <a href="altaCliente.jsp" class="btn btn-outline-primary rounded-pill py-2 px-4"><i class="fa fa-user-plus me-2"></i>Nuevo Cliente</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />