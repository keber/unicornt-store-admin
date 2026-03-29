<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<%-- ---- Encabezado de seccion ---- --%>
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold mb-0">
        <i class="fas fa-tshirt me-2" style="color:var(--brand)"></i>Catálogo de Productos
    </h2>
    <a href="${pageContext.request.contextPath}/admin/products/new" class="btn btn-brand">
        <i class="fas fa-plus me-1"></i> Nuevo Producto
    </a>
</div>

<%-- ---- Mensajes de feedback (PRG) ---- --%>
<c:if test="${not empty param.success}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fas fa-check-circle me-1"></i>
        <c:out value="${param.success}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
    </div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-1"></i>
        <c:out value="${param.error}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
    </div>
</c:if>

<%-- ---- Filtros ---- --%>
<div class="card border-0 shadow-sm mb-4">
    <div class="card-body">
        <form method="get" action="${pageContext.request.contextPath}/admin/products"
              class="row g-3 align-items-end">
            <div class="col-md-5">
                <label class="form-label fw-semibold small text-muted text-uppercase ls-wide">
                    Buscar por nombre
                </label>
                <input type="text" name="search" class="form-control"
                       placeholder="Ej: Breaking Prod…"
                       value="<c:out value='${searchParam}'/>">
            </div>
            <div class="col-md-4">
                <label class="form-label fw-semibold small text-muted text-uppercase">
                    Categoría
                </label>
                <select name="categoryId" class="form-select">
                    <option value="">— Todas las categorías —</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}"
                                ${categoryFilter == cat.id ? 'selected' : ''}>
                            <c:out value="${cat.name}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-brand w-100">
                    <i class="fas fa-search me-1"></i> Buscar
                </button>
            </div>
            <div class="col-md-1">
                <a href="${pageContext.request.contextPath}/admin/products"
                   class="btn btn-outline-secondary w-100" title="Limpiar filtros">
                    <i class="fas fa-times"></i>
                </a>
            </div>
        </form>
    </div>
</div>

<%-- ---- Tabla de resultados ---- --%>
<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead>
                <tr>
                    <th class="ps-3" style="width:60px">ID</th>
                    <th>Nombre</th>
                    <th style="width:120px">Tipo</th>
                    <th style="width:160px">Categoría</th>
                    <th class="text-end" style="width:110px">Precio</th>
                    <th class="text-center" style="width:80px">Activo</th>
                    <th class="text-center pe-3" style="width:110px">Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty products}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-5">
                                <i class="fas fa-box-open fa-2x mb-2 d-block opacity-50"></i>
                                No se encontraron productos con esos criterios.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="p" items="${products}">
                            <tr>
                                <td class="ps-3 text-muted small">#${p.id}</td>
                                <td class="fw-semibold">
                                    <c:out value="${p.name}"/>
                                </td>
                                <td class="small text-muted">
                                    <c:out value="${p.productTypeName}"/>
                                </td>
                                <td>
                                    <span class="badge rounded-pill"
                                          style="background-color:var(--brand-light);color:var(--text-dark)">
                                        <c:out value="${p.categoryName}"/>
                                    </span>
                                </td>
                                <td class="text-end fw-semibold">
                                    ${p.formattedPrice}
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${p.active}">
                                            <span class="badge bg-success">
                                                <i class="fas fa-check me-1"></i>Sí
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">No</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center pe-3">
                                    <a href="${pageContext.request.contextPath}/admin/products/edit?id=${p.id}"
                                       class="btn btn-sm btn-outline-secondary me-1"
                                       title="Editar">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <button type="button"
                                            class="btn btn-sm btn-outline-danger"
                                            data-bs-toggle="modal"
                                            data-bs-target="#deleteModal"
                                            data-product-id="${p.id}"
                                            data-product-name="<c:out value='${p.name}'/>"
                                            title="Eliminar">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <c:if test="${not empty products}">
        <div class="card-footer bg-transparent text-muted small text-end py-2">
            ${fn:length(products)} producto<c:if test="${fn:length(products) != 1}">s</c:if> encontrado<c:if test="${fn:length(products) != 1}">s</c:if>
        </div>
    </c:if>
</div>

<%-- ---- Modal confirmacion eliminar ---- --%>
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title" id="deleteModalLabel">
                    <i class="fas fa-trash me-2"></i>Confirmar eliminación
                </h5>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <p class="mb-1">¿Estás seguro que deseas eliminar el producto?</p>
                <p class="fw-bold" id="deleteProductName"></p>
                <p class="text-muted small mb-0">Esta acción no se puede deshacer.</p>
            </div>
            <div class="modal-footer gap-2">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times me-1"></i>Cancelar
                </button>
                <form id="deleteForm" method="post"
                      action="${pageContext.request.contextPath}/admin/products/delete"
                      class="d-inline">
                    <input type="hidden" name="id" id="deleteProductId"/>
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-trash me-1"></i>Eliminar
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    (() => {
        const modal = document.getElementById('deleteModal');
        modal.addEventListener('show.bs.modal', (event) => {
            const btn = event.relatedTarget;
            document.getElementById('deleteProductId').value = btn.dataset.productId;
            document.getElementById('deleteProductName').textContent = btn.dataset.productName;
        });
    })();
</script>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
