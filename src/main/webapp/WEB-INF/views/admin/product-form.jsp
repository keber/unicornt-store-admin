<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<%-- Detecta si es edicion o creacion --%>
<c:set var="isEdit" value="${not empty product and product.id gt 0}"/>
<c:choose>
    <c:when test="${isEdit}">
        <c:set var="formAction" value="${pageContext.request.contextPath}/admin/products/update"/>
        <c:set var="pageTitle"  value="Editar Producto"/>
    </c:when>
    <c:otherwise>
        <c:set var="formAction" value="${pageContext.request.contextPath}/admin/products"/>
        <c:set var="pageTitle"  value="Nuevo Producto"/>
    </c:otherwise>
</c:choose>

<%-- ---- Encabezado ---- --%>
<div class="d-flex align-items-center mb-4 gap-3">
    <a href="${pageContext.request.contextPath}/admin/products"
       class="btn btn-outline-secondary" title="Volver al listado">
        <i class="fas fa-arrow-left"></i>
    </a>
    <h2 class="fw-bold mb-0">
        <c:choose>
            <c:when test="${isEdit}">
                <i class="fas fa-edit me-2" style="color:var(--brand)"></i>${pageTitle}
                <small class="text-muted fw-normal fs-6 ms-2">#${product.id}</small>
            </c:when>
            <c:otherwise>
                <i class="fas fa-plus me-2" style="color:var(--brand)"></i>${pageTitle}
            </c:otherwise>
        </c:choose>
    </h2>
</div>

<%-- ---- Errores de validacion ---- --%>
<c:if test="${not empty errors}">
    <div class="alert alert-danger" role="alert">
        <strong><i class="fas fa-exclamation-triangle me-1"></i>Corrige los siguientes errores:</strong>
        <ul class="mb-0 mt-1">
            <c:forEach var="e" items="${errors}">
                <li><c:out value="${e}"/></li>
            </c:forEach>
        </ul>
    </div>
</c:if>

<%-- ---- Formulario ---- --%>
<div class="card border-0 shadow-sm">
    <div class="card-body">
        <form method="post" action="${formAction}" novalidate>

            <c:if test="${isEdit}">
                <input type="hidden" name="id" value="${product.id}"/>
            </c:if>

            <div class="row g-3">

                <%-- Nombre --%>
                <div class="col-12">
                    <label for="name" class="form-label fw-semibold">
                        Nombre <span class="text-danger">*</span>
                    </label>
                    <input type="text" id="name" name="name" class="form-control"
                           maxlength="200" required
                           placeholder="Ej: Polera 'Breaking Prod'"
                           value="<c:out value='${product.name}'/>">
                </div>

                <%-- Tipo de producto y Categoria --%>
                <div class="col-md-6">
                    <label for="productTypeId" class="form-label fw-semibold">
                        Tipo de Producto <span class="text-danger">*</span>
                    </label>
                    <select id="productTypeId" name="productTypeId" class="form-select" required>
                        <option value="">— Selecciona un tipo —</option>
                        <c:forEach var="type" items="${productTypes}">
                            <option value="${type.id}"
                                    ${product.productTypeId == type.id ? 'selected' : ''}>
                                <c:out value="${type.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-6">
                    <label for="categoryId" class="form-label fw-semibold">
                        Categoría <span class="text-danger">*</span>
                    </label>
                    <select id="categoryId" name="categoryId" class="form-select" required>
                        <option value="">— Selecciona una categoría —</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}"
                                    ${product.categoryId == cat.id ? 'selected' : ''}>
                                <c:out value="${cat.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <%-- Precio --%>
                <div class="col-md-4">
                    <label for="price" class="form-label fw-semibold">
                        Precio (CLP) <span class="text-danger">*</span>
                    </label>
                    <div class="input-group">
                        <span class="input-group-text">$</span>
                        <input type="number" id="price" name="price" class="form-control"
                               min="1" required
                               placeholder="Ej: 13990"
                               value="${product.price gt 0 ? product.price : ''}">
                    </div>
                    <div class="form-text">Entero, en pesos chilenos (sin decimales).</div>
                </div>

                <%-- Ruta de imagen --%>
                <div class="col-md-8">
                    <label for="imageBase" class="form-label fw-semibold">
                        Ruta de imagen base
                    </label>
                    <input type="text" id="imageBase" name="imageBase" class="form-control"
                           placeholder="Ej: assets/img/devops/breaking-prod"
                           value="<c:out value='${product.imageBase}'/>">
                    <div class="form-text">
                        Sin extensi&oacute;n. El frontend agrega
                        <code>.webp</code>, <code>-card.webp</code> y <code>-thumb.webp</code>.
                    </div>
                </div>

                <%-- Descripcion --%>
                <div class="col-12">
                    <label for="description" class="form-label fw-semibold">Descripción</label>
                    <textarea id="description" name="description"
                              class="form-control" rows="3"
                              placeholder="Descripción visible en la página de detalle del producto…"><c:out value="${product.description}"/></textarea>
                </div>

                <%-- Activo --%>
                <div class="col-12">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" role="switch"
                               id="isActive" name="isActive" value="1"
                               ${empty product or product.active ? 'checked' : ''}>
                        <label class="form-check-label fw-semibold" for="isActive">
                            Producto activo
                            <small class="text-muted fw-normal">
                                (visible en el catálogo público)
                            </small>
                        </label>
                    </div>
                </div>

                <%-- Acciones --%>
                <div class="col-12 d-flex gap-2 pt-2 border-top mt-2">
                    <button type="submit" class="btn btn-brand">
                        <i class="fas fa-save me-1"></i>
                        <c:choose>
                            <c:when test="${isEdit}">Actualizar Producto</c:when>
                            <c:otherwise>Crear Producto</c:otherwise>
                        </c:choose>
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/products"
                       class="btn btn-outline-secondary">
                        <i class="fas fa-times me-1"></i>Cancelar
                    </a>
                </div>

            </div><%-- /row --%>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
