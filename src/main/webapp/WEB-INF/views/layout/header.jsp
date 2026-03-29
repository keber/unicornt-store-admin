<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin &mdash; Unicorn't Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        /* ---- Paleta de marca (de unicornt-store-frontend/assets/css/main.css) ---- */
        :root {
            --brand:       #7c3aed;
            --brand-dark:  #5b21b6;
            --brand-light: #ede9fe;
            --accent:      #ec4899;
            --accent-dark: #be185d;
            --text-dark:   #1e1b4b;
            --footer-bg:   #1e1b4b;
        }

        body {
            background-color: #f8f7ff;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        main { flex: 1; }

        /* Navbar */
        .navbar-admin { background-color: var(--footer-bg); }
        .navbar-admin .navbar-brand:hover { color: var(--brand-light) !important; }
        .navbar-admin .nav-link:hover     { color: var(--brand-light) !important; }

        /* Botones de marca */
        .btn-brand {
            background-color: var(--brand);
            border-color:     var(--brand);
            color: #fff;
        }
        .btn-brand:hover,
        .btn-brand:focus {
            background-color: var(--brand-dark);
            border-color:     var(--brand-dark);
            color: #fff;
        }

        /* Tablas */
        .table thead th { background-color: var(--brand-light); color: var(--text-dark); }

        /* Links */
        a           { color: var(--brand); }
        a:hover     { color: var(--brand-dark); }

        /* Footer */
        footer { background-color: var(--footer-bg); }
    </style>
</head>
<body>

<nav class="navbar navbar-dark navbar-admin navbar-expand-lg mb-4 shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold fs-5" href="${pageContext.request.contextPath}/admin/products">
            🦄 Unicorn't Store
            <span class="badge bg-warning text-dark ms-2 fw-normal" style="font-size:.65rem">ADMIN</span>
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse" data-bs-target="#navAdmin"
                aria-controls="navAdmin" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navAdmin">
            <ul class="navbar-nav ms-auto gap-1">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/products">
                        <i class="fas fa-tshirt me-1"></i>Productos
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<main class="container pb-5">
