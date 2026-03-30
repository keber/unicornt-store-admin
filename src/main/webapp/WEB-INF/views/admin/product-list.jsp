<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<%-- ---- Encabezado de sección ---- --%>
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold mb-0 admin-page-title">
        <i class="fa-solid fa-tshirt me-2"></i>Catálogo de Productos
    </h2>
    <a href="${pageContext.request.contextPath}/admin/products/new" class="btn btn-brand">
        <i class="fa-solid fa-plus me-1"></i> Nuevo Producto
    </a>
</div>

<%-- ---- Mensajes de feedback (PRG) ---- --%>
<c:if test="${not empty param.success}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-check me-1"></i>
        <c:out value="${param.success}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
    </div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-exclamation me-1"></i>
        <c:out value="${param.error}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
    </div>
</c:if>

<%-- ---- Filtros ---- --%>
<div class="admin-filter-card p-3 mb-4">
    <form method="get" action="${pageContext.request.contextPath}/admin/products"
          class="row g-3 align-items-end">
        <div class="col-md-5">
            <label class="form-label fw-semibold small text-muted text-uppercase">
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
                <i class="fa-solid fa-magnifying-glass me-1"></i> Buscar
            </button>
        </div>
        <div class="col-md-1">
            <a href="${pageContext.request.contextPath}/admin/products"
               class="btn btn-outline-secondary w-100" title="Limpiar filtros">
                <i class="fa-solid fa-xmark"></i>
            </a>
        </div>
    </form>
</div>

<%-- ---- Tabla de resultados ---- --%>
<div class="admin-table-wrapper">
    <table class="table table-hover admin-table">
        <thead>
            <tr>
                <th class="ps-3" style="width:60px">ID</th>
                <th>Nombre</th>
                <th style="width:120px">Tipo</th>
                <th style="width:160px">Categoría</th>
                <th class="text-end" style="width:120px">Precio</th>
                <th class="text-center" style="width:90px">Activo</th>
                <th class="text-center pe-3" style="width:100px">Acciones</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty products}">
                    <tr>
                        <td colspan="7" class="text-center admin-empty">
                            <i class="fa-solid fa-box-open"></i>
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
                                <span class="badge-category">
                                    <c:out value="${p.categoryName}"/>
                                </span>
                            </td>
                            <td class="text-end fw-semibold">
                                ${p.formattedPrice}
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${p.active}">
                                        <span class="badge-active">
                                            <i class="fa-solid fa-check me-1"></i>Sí
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-inactive">No</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center pe-3">
                                <a href="${pageContext.request.contextPath}/admin/products/edit?id=${p.id}"
                                   class="btn btn-action btn-outline-secondary me-1"
                                   title="Editar">
                                    <i class="fa-solid fa-pen"></i>
                                </a>
                                <button type="button"
                                        class="btn btn-action btn-outline-danger"
                                        data-bs-toggle="modal"
                                        data-bs-target="#deleteModal"
                                        data-product-id="${p.id}"
                                        data-product-name="<c:out value='${p.name}'/>"
                                        title="Eliminar">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>

    <c:if test="${not empty products}">
        <div class="results-count text-end">
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
