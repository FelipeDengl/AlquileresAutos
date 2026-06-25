<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.VehiculoCatalogo"%>
<%@page import="modelo.PeriodoOcupacion"%>
<%@page import="java.util.List"%>

<jsp:include page="header.jsp" />

<%
    VehiculoCatalogo vehiculo =
            (VehiculoCatalogo) request.getAttribute("vehiculo");

    List<PeriodoOcupacion> periodos =
            (List<PeriodoOcupacion>) request.getAttribute("periodosOcupados");

    String fechaInicio =
            (String) request.getAttribute("fechaInicio");

    String fechaFin =
            (String) request.getAttribute("fechaFin");

    if (fechaInicio == null) {
        fechaInicio = "";
    }

    if (fechaFin == null) {
        fechaFin = "";
    }

    String imagen = "img/car-1.png";

    if (vehiculo != null
            && vehiculo.getUrlImagen() != null
            && !vehiculo.getUrlImagen().trim().isEmpty()) {
        imagen = vehiculo.getUrlImagen();
    }
%>

<style>
    .calendario-box {
        max-width: 620px;
        margin: 0 auto 30px auto;
        border-radius: 18px;
        background: #fff;
        box-shadow: 0 2px 10px rgba(0,0,0,.12);
        padding: 28px;
    }

    .calendario-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
    }

    .calendario-header button {
        border: none;
        background: transparent;
        font-size: 28px;
        color: #6c757d;
        cursor: pointer;
    }

    .calendario-grid {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 12px;
        text-align: center;
    }

    .dia-nombre {
        font-weight: 700;
        color: #333;
        margin-bottom: 8px;
    }

    .dia-calendario {
        padding: 12px 0;
        border-radius: 50px;
        cursor: pointer;
        font-weight: 600;
        color: #333;
        background: #f8f9fa;
    }

    .dia-calendario:hover {
        background: #ffe5e8;
    }

    .dia-vacio {
        padding: 12px 0;
    }

    .dia-pasado {
        color: #c9ced6;
        background: transparent;
        cursor: not-allowed;
    }

    .dia-ocupado {
        color: #dc3545;
        background: #fdebed;
        text-decoration: line-through;
        cursor: not-allowed;
    }

    .dia-seleccionado {
        background: #ed001b !important;
        color: white !important;
        box-shadow: 0 4px 10px rgba(237,0,27,.35);
    }

    .dia-rango {
        background: #ffe5e8;
        color: #ed001b;
    }

    .leyenda-calendario span {
        display: inline-block;
        margin-right: 18px;
        font-size: 14px;
    }

    .cuadro-leyenda {
        display: inline-block;
        width: 14px;
        height: 14px;
        border-radius: 50%;
        margin-right: 6px;
        vertical-align: middle;
    }
</style>

<div class="container-fluid py-5 bg-light">
    <div class="container py-4">

        <a href="catalogoVehiculos" class="text-primary fw-bold d-inline-block mb-4">
            <i class="fa fa-arrow-left me-2"></i>
            Volver a vehículos
        </a>

        <% if (vehiculo != null) { %>

        <div class="row g-5 align-items-start">

            <div class="col-lg-6">
                <div class="card shadow-sm border-0 rounded overflow-hidden">

                    <img
                        src="<%= imagen %>"
                        class="img-fluid w-100"
                        style="height: 430px; object-fit: cover;"
                        alt="Vehículo <%= vehiculo.getNroPatente() %>"
                        onerror="this.src='img/car-1.png';">

                </div>
            </div>

            <div class="col-lg-6">

                <div class="card shadow-sm border-0 rounded mb-4">
                    <div class="card-body p-5">

                        <h6 class="text-primary text-uppercase fw-bold mb-2">
                            <%= vehiculo.getNombreTipo() %>
                        </h6>

                        <h1 class="mb-3">
                            <%= vehiculo.getNombreMarca() %> <%= vehiculo.getNombreModelo() %>
                        </h1>

                        <p class="fs-5 text-muted mb-4">
                            <%= vehiculo.getNombreMarca() %>
                            <%= vehiculo.getNombreModelo() %>
                            -
                            <%= vehiculo.getNombreTipo() %>
                            en
                            <%= vehiculo.getUbicacion() %>
                        </p>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <p class="mb-1 text-muted fw-bold">
                                    Sucursal
                                </p>

                                <p class="fw-bold">
                                    <%= vehiculo.getNombreSucursal() %>
                                </p>
                            </div>

                            <div class="col-md-6">
                                <p class="mb-1 text-muted fw-bold">
                                    Precio diario
                                </p>

                                <p class="fw-bold">
                                    $<%= String.format("%,.2f", vehiculo.getValorDiario()) %>
                                </p>
                            </div>
                        </div>

                        <p class="mb-2 text-muted fw-bold text-uppercase">
                            Confort
                        </p>

                        <div class="bg-light rounded-pill px-4 py-3 fw-bold">
                            <%= vehiculo.getDetalleConfort() %>
                        </div>

                    </div>
                </div>

                <div class="card shadow-sm border-0 rounded">
                    <div class="card-body p-5">

                        <h2 class="mb-4">
                            Solicitar reserva
                        </h2>

                        <div class="calendario-box">

                            <div class="calendario-header">
                                <button type="button" onclick="cambiarMes(-1)">
                                    <i class="fa fa-chevron-left"></i>
                                </button>

                                <h4 id="tituloMes" class="mb-0"></h4>

                                <button type="button" onclick="cambiarMes(1)">
                                    <i class="fa fa-chevron-right"></i>
                                </button>
                            </div>

                            <div class="calendario-grid" id="calendario"></div>

                            <div class="leyenda-calendario mt-4 text-center">
                                <span>
                                    <span class="cuadro-leyenda" style="background:#ed001b;"></span>
                                    Seleccionado
                                </span>

                                <span>
                                    <span class="cuadro-leyenda" style="background:#fdebed;"></span>
                                    Ocupado
                                </span>

                                <span>
                                    <span class="cuadro-leyenda" style="background:#f8f9fa;"></span>
                                    Disponible
                                </span>
                            </div>

                        </div>

                        <form action="registrarReserva" method="post">

                            <input
                                type="hidden"
                                name="nroPatente"
                                value="<%= vehiculo.getNroPatente() %>">

                            <div class="row g-3 mb-4">

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Fecha de inicio
                                    </label>

                                    <input
                                        type="date"
                                        id="fechaInicio"
                                        name="fechaInicio"
                                        class="form-control"
                                        value="<%= fechaInicio %>"
                                        required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label text-dark fw-bold">
                                        Fecha de devolución prevista
                                    </label>

                                    <input
                                        type="date"
                                        id="fechaFin"
                                        name="fechaFin"
                                        class="form-control"
                                        value="<%= fechaFin %>"
                                        required>
                                </div>

                            </div>

                            <div class="bg-light rounded p-4 mb-4">

                                <h5 class="mb-3">
                                    Resumen
                                </h5>

                                <p class="mb-2">
                                    Duración estimada:
                                    <strong id="diasEstimados">-</strong>
                                </p>

                                <p class="mb-0">
                                    Total estimado:
                                    <strong id="totalEstimado">$0,00</strong>
                                </p>

                            </div>

                            <div class="d-grid">
                                <button
                                    type="submit"
                                    class="btn btn-primary rounded py-3 fs-5">
                                    Confirmar reserva
                                </button>
                            </div>

                        </form>

                    </div>
                </div>

            </div>

        </div>

        <% } else { %>

            <div class="alert alert-warning text-center">
                No se pudo cargar el vehículo seleccionado.
            </div>

        <% } %>

    </div>
</div>

<script>
    const valorDiario = <%= vehiculo != null ? vehiculo.getValorDiario() : 0 %>;

    const periodosOcupados = [
        <%
            if (periodos != null) {
                for (int i = 0; i < periodos.size(); i++) {
                    PeriodoOcupacion p = periodos.get(i);
        %>
            {
                inicio: "<%= p.getFechaInicio() %>",
                fin: "<%= p.getFechaFin() %>",
                tipo: "<%= p.getTipo() %>"
            }<%= i < periodos.size() - 1 ? "," : "" %>
        <%
                }
            }
        %>
    ];

    let fechaVisual = new Date();
    let fechaInicioSeleccionada = document.getElementById("fechaInicio").value || "";
    let fechaFinSeleccionada = document.getElementById("fechaFin").value || "";

    if (fechaInicioSeleccionada) {
        const partes = fechaInicioSeleccionada.split("-");
        fechaVisual = new Date(parseInt(partes[0]), parseInt(partes[1]) - 1, 1);
    }

    const nombresMes = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];

    const nombresDia = ["Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa"];

    function formatoFecha(fecha) {
        const y = fecha.getFullYear();
        const m = String(fecha.getMonth() + 1).padStart(2, "0");
        const d = String(fecha.getDate()).padStart(2, "0");
        return y + "-" + m + "-" + d;
    }

    function parseFechaLocal(valor) {
        const p = valor.split("-");
        return new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]));
    }

    function fechaOcupada(fechaTexto) {
        const fecha = parseFechaLocal(fechaTexto);

        for (let i = 0; i < periodosOcupados.length; i++) {
            const inicio = parseFechaLocal(periodosOcupados[i].inicio);
            const fin = parseFechaLocal(periodosOcupados[i].fin);

            if (fecha >= inicio && fecha <= fin) {
                return true;
            }
        }

        return false;
    }

    function rangoTieneOcupados(inicioTexto, finTexto) {
        if (!inicioTexto || !finTexto) {
            return false;
        }

        let actual = parseFechaLocal(inicioTexto);
        const fin = parseFechaLocal(finTexto);

        while (actual <= fin) {
            if (fechaOcupada(formatoFecha(actual))) {
                return true;
            }

            actual.setDate(actual.getDate() + 1);
        }

        return false;
    }

    function estaEnRango(fechaTexto) {
        if (!fechaInicioSeleccionada || !fechaFinSeleccionada) {
            return false;
        }

        const fecha = parseFechaLocal(fechaTexto);
        const inicio = parseFechaLocal(fechaInicioSeleccionada);
        const fin = parseFechaLocal(fechaFinSeleccionada);

        return fecha >= inicio && fecha <= fin;
    }

    function seleccionarDia(fechaTexto) {
        if (fechaOcupada(fechaTexto)) {
            alert("Ese día no está disponible para este vehículo.");
            return;
        }

        if (!fechaInicioSeleccionada || fechaFinSeleccionada) {
            fechaInicioSeleccionada = fechaTexto;
            fechaFinSeleccionada = "";
        } else {
            if (parseFechaLocal(fechaTexto) <= parseFechaLocal(fechaInicioSeleccionada)) {
                alert("La fecha de devolución debe ser posterior a la fecha de inicio.");
                return;
            }

            if (rangoTieneOcupados(fechaInicioSeleccionada, fechaTexto)) {
                alert("El rango seleccionado contiene días ocupados. Elegí otro período.");
                return;
            }

            fechaFinSeleccionada = fechaTexto;
        }

        document.getElementById("fechaInicio").value = fechaInicioSeleccionada;
        document.getElementById("fechaFin").value = fechaFinSeleccionada;

        renderCalendario();
        calcularResumen();
    }

    function renderCalendario() {
        const calendario = document.getElementById("calendario");
        const tituloMes = document.getElementById("tituloMes");

        calendario.innerHTML = "";

        const anio = fechaVisual.getFullYear();
        const mes = fechaVisual.getMonth();

        tituloMes.innerText = nombresMes[mes] + " " + anio;

        for (let i = 0; i < nombresDia.length; i++) {
            const divDia = document.createElement("div");
            divDia.className = "dia-nombre";
            divDia.innerText = nombresDia[i];
            calendario.appendChild(divDia);
        }

        const primerDia = new Date(anio, mes, 1);
        const ultimoDia = new Date(anio, mes + 1, 0);
        const inicioSemana = primerDia.getDay();

        for (let i = 0; i < inicioSemana; i++) {
            const vacio = document.createElement("div");
            vacio.className = "dia-vacio";
            calendario.appendChild(vacio);
        }

        const hoyTexto = formatoFecha(new Date());

        for (let dia = 1; dia <= ultimoDia.getDate(); dia++) {
            const fecha = new Date(anio, mes, dia);
            const fechaTexto = formatoFecha(fecha);

            const div = document.createElement("div");
            div.innerText = dia;
            div.className = "dia-calendario";

            if (fechaTexto < hoyTexto) {
                div.classList.add("dia-pasado");
            } else if (fechaOcupada(fechaTexto)) {
                div.classList.add("dia-ocupado");
            } else if (fechaTexto === fechaInicioSeleccionada || fechaTexto === fechaFinSeleccionada) {
                div.classList.add("dia-seleccionado");
            } else if (estaEnRango(fechaTexto)) {
                div.classList.add("dia-rango");
            }

            if (fechaTexto >= hoyTexto && !fechaOcupada(fechaTexto)) {
                div.onclick = function () {
                    seleccionarDia(fechaTexto);
                };
            }

            calendario.appendChild(div);
        }
    }

    function cambiarMes(cambio) {
        fechaVisual.setMonth(fechaVisual.getMonth() + cambio);
        renderCalendario();
    }

    function calcularResumen() {
        const fechaInicio = document.getElementById("fechaInicio").value;
        const fechaFin = document.getElementById("fechaFin").value;

        const diasTexto = document.getElementById("diasEstimados");
        const totalTexto = document.getElementById("totalEstimado");

        if (!fechaInicio || !fechaFin) {
            diasTexto.innerText = "-";
            totalTexto.innerText = "$0,00";
            return;
        }

        if (rangoTieneOcupados(fechaInicio, fechaFin)) {
            diasTexto.innerText = "rango no disponible";
            totalTexto.innerText = "$0,00";
            return;
        }

        const inicio = parseFechaLocal(fechaInicio);
        const fin = parseFechaLocal(fechaFin);

        const diferencia = fin - inicio;
        const dias = diferencia / (1000 * 60 * 60 * 24);

        if (dias <= 0) {
            diasTexto.innerText = "fecha inválida";
            totalTexto.innerText = "$0,00";
            return;
        }

        const total = dias * valorDiario;

        diasTexto.innerText = dias + (dias === 1 ? " día" : " días");

        totalTexto.innerText = "$" + total.toLocaleString(
            "es-AR",
            {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            }
        );
    }

    document.getElementById("fechaInicio").addEventListener("change", function () {
        fechaInicioSeleccionada = this.value;
        renderCalendario();
        calcularResumen();
    });

    document.getElementById("fechaFin").addEventListener("change", function () {
        fechaFinSeleccionada = this.value;

        if (rangoTieneOcupados(fechaInicioSeleccionada, fechaFinSeleccionada)) {
            alert("El rango seleccionado contiene días ocupados.");
        }

        renderCalendario();
        calcularResumen();
    });

    renderCalendario();
    calcularResumen();
</script>

<jsp:include page="footer.jsp" />