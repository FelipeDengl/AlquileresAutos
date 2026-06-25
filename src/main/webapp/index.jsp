<%@page contentType="text/html" pageEncoding="UTF-8"%>

<jsp:include page="header.jsp" />

<!-- Hero / Welcome Start -->
<div class="container-fluid py-5 mb-5" 
     style="background: linear-gradient(rgba(0, 0, 0, 0.65), rgba(0, 0, 0, 0.65)), 
     url('img/carousel-1.jpg') center center no-repeat; background-size: cover;">

    <div class="container py-5 text-center">

        <h1 class="display-3 text-white mb-4 wow fadeInDown" data-wow-delay="0.1s">
            Alquilá el vehículo ideal para tu viaje
        </h1>

        <p class="text-white pb-3 wow fadeInUp" data-wow-delay="0.2s">
            Consultá vehículos disponibles, registrate como cliente y realizá tu reserva de forma simple.
        </p>

        <a href="catalogoVehiculos" 
           class="btn btn-primary rounded-pill py-3 px-5 wow fadeInUp" 
           data-wow-delay="0.3s">
            Ver Vehículos
        </a>

    </div>
</div>
<!-- Hero / Welcome End -->


<!-- Features Start -->
<div class="container-fluid py-5">
    <div class="container py-5">

        <div class="text-center mx-auto mb-5 wow fadeInUp" 
             data-wow-delay="0.1s" 
             style="max-width: 700px;">

            <h1 class="display-5 text-capitalize mb-3">
                Funciones <span class="text-primary">Principales</span>
            </h1>

            <p class="mb-0">
                El sistema permite consultar vehículos, registrar clientes y generar reservas.
            </p>
        </div>

        <div class="row g-4 justify-content-center">

            <!-- Catálogo de vehículos -->
            <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.1s">
                <div class="feature-item p-4 text-center h-100">

                    <div class="feature-icon mb-4">
                        <i class="fa fa-car fa-3x text-primary"></i>
                    </div>

                    <h4 class="mb-3">
                        Catálogo de Vehículos
                    </h4>

                    <p class="mb-4">
                        Consultá los vehículos disponibles, sus imágenes, tipo, sucursal y precio diario.
                    </p>

                    <a class="btn btn-primary rounded-pill py-2 px-4" href="catalogoVehiculos">
                        Ver Vehículos
                    </a>

                </div>
            </div>

            <!-- Registro de cliente -->
            <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.3s">
                <div class="feature-item p-4 text-center h-100">

                    <div class="feature-icon mb-4">
                        <i class="fa fa-user-plus fa-3x text-primary"></i>
                    </div>

                    <h4 class="mb-3">
                        Registro de Cliente
                    </h4>

                    <p class="mb-4">
                        Para realizar una reserva, primero tenés que registrar tus datos como cliente.
                    </p>

                    <a class="btn btn-primary rounded-pill py-2 px-4" href="altaCliente.jsp">
                        Registrarse
                    </a>

                </div>
            </div>

            <!-- Reserva online -->
            <div class="col-lg-4 col-md-6 wow fadeInUp" data-wow-delay="0.5s">
                <div class="feature-item p-4 text-center h-100">

                    <div class="feature-icon mb-4">
                        <i class="fa fa-calendar-check fa-3x text-primary"></i>
                    </div>

                    <h4 class="mb-3">
                        Reserva Online
                    </h4>

                    <p class="mb-4">
                        Elegí un vehículo, indicá las fechas de uso y confirmá la reserva en el sistema.
                    </p>

                    <a class="btn btn-primary rounded-pill py-2 px-4" href="catalogoVehiculos">
                        Reservar
                    </a>

                </div>
            </div>

        </div>
    </div>
</div>
<!-- Features End -->


<!-- Info Start -->
<div class="container-fluid py-5 bg-light">
    <div class="container py-5">

        <div class="row align-items-center g-5">

            <div class="col-lg-6">
                <h5 class="text-primary text-uppercase">
                    ¿Cómo funciona?
                </h5>

                <h1 class="display-6 mb-4">
                    Reservá tu vehículo en pocos pasos
                </h1>

                <p class="mb-4">
                    El cliente puede consultar el catálogo de vehículos, seleccionar una opción disponible
                    y completar sus datos para registrar la reserva.
                </p>

                <div class="d-flex mb-3">
                    <i class="fa fa-check-circle text-primary me-3 mt-1"></i>
                    <p class="mb-0">
                        Primero consultás los vehículos disponibles.
                    </p>
                </div>

                <div class="d-flex mb-3">
                    <i class="fa fa-check-circle text-primary me-3 mt-1"></i>
                    <p class="mb-0">
                        Luego seleccionás el vehículo que querés reservar.
                    </p>
                </div>

                <div class="d-flex mb-3">
                    <i class="fa fa-check-circle text-primary me-3 mt-1"></i>
                    <p class="mb-0">
                        Finalmente registrás tus datos y confirmás la reserva.
                    </p>
                </div>

                <a href="catalogoVehiculos" class="btn btn-primary rounded-pill py-3 px-5 mt-3">
                    Comenzar Reserva
                </a>
            </div>

            <div class="col-lg-6">
                <img src="img/features-img.png" 
                     class="img-fluid rounded" 
                     alt="Vehículo para alquilar">
            </div>

        </div>

    </div>
</div>
<!-- Info End -->


<jsp:include page="footer.jsp" />