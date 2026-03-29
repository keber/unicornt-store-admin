package com.unicornt.store.servlet;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import com.unicornt.store.dao.CategoryDAO;
import com.unicornt.store.dao.ProductDAO;
import com.unicornt.store.dao.ProductTypeDAO;
import com.unicornt.store.model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controlador MVC para la gestion de productos del admin.
 *
 * Rutas:
 *   GET  /admin/products         → listado + busqueda/filtro
 *   GET  /admin/products/new     → formulario de creacion
 *   POST /admin/products         → crear producto
 *   GET  /admin/products/edit    → formulario de edicion (?id=X)
 *   POST /admin/products/update  → guardar edicion
 *   POST /admin/products/delete  → eliminar con confirmacion previa en UI
 */
@WebServlet(urlPatterns = {"/admin/products", "/admin/products/*"})
public class AdminProductServlet extends HttpServlet {

    private ProductDAO     productDAO;
    private CategoryDAO    categoryDAO;
    private ProductTypeDAO productTypeDAO;

    @Override
    public void init() {
        productDAO     = new ProductDAO();
        categoryDAO    = new CategoryDAO();
        productTypeDAO = new ProductTypeDAO();
    }

    // ----------------------------------------------------------------
    // doGet — despacha por pathInfo
    // ----------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo(); // null | /new | /edit

        if (path == null || path.equals("/")) {
            showList(req, resp);
        } else if (path.equals("/new")) {
            showForm(req, resp, null);
        } else if (path.equals("/edit")) {
            showEditForm(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ----------------------------------------------------------------
    // doPost — despacha por pathInfo
    // ----------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo(); // null | /update | /delete

        if (path == null || path.equals("/")) {
            handleCreate(req, resp);
        } else if (path.equals("/update")) {
            handleUpdate(req, resp);
        } else if (path.equals("/delete")) {
            handleDelete(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ----------------------------------------------------------------
    // Handlers GET
    // ----------------------------------------------------------------

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String  nameFilter    = req.getParameter("search");
        Integer categoryFilter = parseId(req.getParameter("categoryId")) > 0
                                    ? parseId(req.getParameter("categoryId"))
                                    : null;

        req.setAttribute("products",       productDAO.findAll(nameFilter, categoryFilter));
        req.setAttribute("categories",     categoryDAO.findAll());
        req.setAttribute("searchParam",    nameFilter != null ? nameFilter : "");
        req.setAttribute("categoryFilter", categoryFilter);

        forward(req, resp, "/WEB-INF/views/admin/product-list.jsp");
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Product product)
            throws ServletException, IOException {

        req.setAttribute("product",      product);
        req.setAttribute("categories",   categoryDAO.findAll());
        req.setAttribute("productTypes", productTypeDAO.findAll());

        forward(req, resp, "/WEB-INF/views/admin/product-form.jsp");
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        if (id <= 0) {
            redirectWithMessage(req, resp, "error", "ID de producto no valido.");
            return;
        }

        Product product = productDAO.findById(id);
        if (product == null) {
            redirectWithMessage(req, resp, "error", "Producto no encontrado (id=" + id + ").");
            return;
        }

        showForm(req, resp, product);
    }

    // ----------------------------------------------------------------
    // Handlers POST
    // ----------------------------------------------------------------

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Product input  = extractProduct(req);
        List<String> errors = validate(input);

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            showForm(req, resp, input);
            return;
        }

        try {
            productDAO.insert(input);
            redirectWithMessage(req, resp, "success", "Producto creado exitosamente.");
        } catch (RuntimeException e) {
            req.setAttribute("errors", List.of("Error al guardar el producto. Intenta nuevamente."));
            showForm(req, resp, input);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        if (id <= 0) {
            redirectWithMessage(req, resp, "error", "ID de producto no valido.");
            return;
        }
        if (productDAO.findById(id) == null) {
            redirectWithMessage(req, resp, "error", "Producto no encontrado (id=" + id + ").");
            return;
        }

        Product input = extractProduct(req);
        input.setId(id);
        List<String> errors = validate(input);

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            showForm(req, resp, input);
            return;
        }

        try {
            productDAO.update(input);
            redirectWithMessage(req, resp, "success", "Producto actualizado exitosamente.");
        } catch (RuntimeException e) {
            req.setAttribute("errors", List.of("Error al actualizar el producto. Intenta nuevamente."));
            showForm(req, resp, input);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        if (id <= 0) {
            redirectWithMessage(req, resp, "error", "ID de producto no valido.");
            return;
        }
        if (productDAO.findById(id) == null) {
            redirectWithMessage(req, resp, "error", "Producto no encontrado (id=" + id + ").");
            return;
        }

        try {
            productDAO.delete(id);
            redirectWithMessage(req, resp, "success", "Producto eliminado.");
        } catch (RuntimeException e) {
            redirectWithMessage(req, resp, "error", "Error al eliminar el producto.");
        }
    }

    // ----------------------------------------------------------------
    // Helpers
    // ----------------------------------------------------------------

    /** Construye un objeto Product a partir de los parametros del request. */
    private Product extractProduct(HttpServletRequest req) {
        Product p = new Product();
        p.setName(trim(req.getParameter("name")));
        p.setDescription(trim(req.getParameter("description")));
        p.setImageBase(trim(req.getParameter("imageBase")));
        p.setActive("1".equals(req.getParameter("isActive")));
        p.setCategoryId(parseId(req.getParameter("categoryId")));
        p.setProductTypeId(parseId(req.getParameter("productTypeId")));

        String priceStr = trim(req.getParameter("price"));
        if (!priceStr.isEmpty()) {
            try {
                p.setPrice(Integer.parseInt(priceStr));
            } catch (NumberFormatException e) {
                p.setPrice(-1); // marca precio invalido para la validacion
            }
        }
        return p;
    }

    /** Valida los campos obligatorios y reglas de negocio. */
    private List<String> validate(Product p) {
        List<String> errors = new ArrayList<>();

        if (p.getName() == null || p.getName().isEmpty()) {
            errors.add("El nombre del producto es obligatorio.");
        } else if (p.getName().length() > 200) {
            errors.add("El nombre no puede superar los 200 caracteres.");
        }

        if (p.getCategoryId() <= 0) {
            errors.add("Debes seleccionar una categoria.");
        }

        if (p.getProductTypeId() <= 0) {
            errors.add("Debes seleccionar un tipo de producto.");
        }

        if (p.getPrice() <= 0) {
            errors.add("El precio debe ser un numero entero mayor a 0.");
        }

        return errors;
    }

    /** Hace forward a una JSP. */
    private void forward(HttpServletRequest req, HttpServletResponse resp, String view)
            throws ServletException, IOException {
        req.getRequestDispatcher(view).forward(req, resp);
    }

    /** Redirige a /admin/products con un parametro de mensaje (PRG). */
    private void redirectWithMessage(HttpServletRequest req, HttpServletResponse resp,
                                     String type, String message) throws IOException {
        String encoded = URLEncoder.encode(message, StandardCharsets.UTF_8);
        resp.sendRedirect(req.getContextPath() + "/admin/products?" + type + "=" + encoded);
    }

    /** Parsea un String a int; devuelve 0 si no es un numero valido. */
    private int parseId(String value) {
        if (value == null || value.trim().isEmpty()) return 0;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String trim(String value) {
        return value != null ? value.trim() : "";
    }
}
