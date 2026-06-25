<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    Object idUsuarioSesion = session.getAttribute("idUsuario");
    String nombreClienteSesion = (String) session.getAttribute("nombreCliente");
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <title>Alquileres de Autos</title>
    <link rel="icon" type="image/svg+xml" href="img/favicon.svg">
    <meta content="width=device-width, initial-scale=1.0" name="viewport">

    <!-- Google Web Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link 
        href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap" 
        rel="stylesheet">

    <!-- Icon Font Stylesheet -->
    <link 
        rel="stylesheet" 
        href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">

    <link 
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" 
        rel="stylesheet">

    <!-- Libraries Stylesheet -->
    <link href="lib/animate/animate.min.css" rel="stylesheet">
    <link href="lib/owlcarousel/assets/owl.carousel.min.css" rel="stylesheet">

    <!-- Bootstrap Stylesheet -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Template Stylesheet -->
    <link href="css/style.css" rel="stylesheet">
</head>

<body>

    <!-- Topbar Start -->
    <div class="container-fluid topbar px-0 d-none d-lg-block">
        <div class="container px-0">
            <div class="row gx-0 align-items-center" style="height: 70px;">

                <div class="col-lg-8 text-center text-lg-start mb-lg-0">
                    <div class="d-flex flex-wrap">

                        <a href="#" class="text-muted me-4">
                            <i class="fas fa-map-marker-alt text-primary me-2"></i>
                            UGD
                        </a>

                        <a href="#" class="text-muted me-4">
                            <i class="fas fa-phone-alt text-primary me-2"></i>
                            +3756464819
                        </a>

                        <a href="#" class="text-muted me-0">
                            <i class="fas fa-envelope text-primary me-2"></i>
                            grupo6@ugd.edu.ar
                        </a>

                    </div>
                </div>

                <div class="col-lg-4 text-center text-lg-end">
                    <div class="d-flex align-items-center justify-content-end">

                        <% if (idUsuarioSesion != null) { %>

                            <span class="text-muted me-3">
                                <i class="fa fa-user text-primary me-2"></i>
                                <%= nombreClienteSesion != null ? nombreClienteSesion : "Cliente" %>
                            </span>

                        <% } %>

                    </div>
                </div>

            </div>
        </div>
    </div>
    <!-- Topbar End -->


    <!-- Navbar Start -->
    <div class="container-fluid nav-bar sticky-top px-0 px-lg-4 py-2 py-lg-0">
        <div class="container">

            <nav class="navbar navbar-expand-lg navbar-light">

                <a href="index.jsp" class="navbar-brand p-0">
                    <h1 class="display-6 text-primary mb-0">
                        <i class="fas fa-car-alt me-3"></i>
                        Alquileres
                    </h1>
                </a>

                <button 
                    class="navbar-toggler" 
                    type="button" 
                    data-bs-toggle="collapse" 
                    data-bs-target="#navbarCollapse"
                    aria-controls="navbarCollapse"
                    aria-expanded="false"
                    aria-label="Toggle navigation">

                    <span class="fa fa-bars"></span>
                </button>

                <div class="collapse navbar-collapse" id="navbarCollapse">

                    <div class="navbar-nav mx-auto py-0">

                        <a href="index.jsp" class="nav-item nav-link">
                            Inicio
                        </a>

                        <a href="catalogoVehiculos" class="nav-item nav-link">
                            Vehículos
                        </a>

                        <% if (idUsuarioSesion == null) { %>

                            <a href="loginCliente" class="nav-item nav-link">
                                Iniciar sesión
                            </a>

                            <a href="altaCliente.jsp" class="nav-item nav-link">
                                Registrarse
                            </a>

                        <% } else { %>

                            <a href="logout" class="nav-item nav-link">
                                Cerrar sesión
                            </a>

                        <% } %>

                    </div>

                    <a href="catalogoVehiculos" class="btn btn-primary rounded-pill py-2 px-4">
                        Reservar
                    </a>

                </div>

            </nav>

        </div>
    </div>
    <!-- Navbar End -->