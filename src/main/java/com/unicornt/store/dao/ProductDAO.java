package com.unicornt.store.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.unicornt.store.config.DatabaseConnection;
import com.unicornt.store.model.Product;

/**
 * Acceso a datos para la tabla products.
 * Todas las operaciones usan PreparedStatement y try-with-resources.
 */
public class ProductDAO {

    private static final String BASE_SELECT =
        "SELECT p.id, p.name, p.product_type_id, pt.name AS product_type_name, " +
        "       p.category_id, c.name AS category_name, " +
        "       p.price, p.description, p.image_base, p.is_active " +
        "FROM   products p " +
        "INNER JOIN categories    c  ON p.category_id     = c.id " +
        "INNER JOIN product_types pt ON p.product_type_id = pt.id ";

    // ----------------------------------------------------------------
    // Consultas
    // ----------------------------------------------------------------

    /**
     * Lista productos con filtros opcionales.
     *
     * @param nameFilter  substring a buscar en el nombre (null o vacio = sin filtro)
     * @param categoryId  id de categoría a filtrar (null o 0 = sin filtro)
     */
    public List<Product> findAll(String nameFilter, Integer categoryId) {
        List<Product> list     = new ArrayList<>();
        List<Object>  params   = new ArrayList<>();
        StringBuilder sql      = new StringBuilder(BASE_SELECT).append("WHERE 1=1");

        if (nameFilter != null && !nameFilter.trim().isEmpty()) {
            sql.append(" AND p.name LIKE ?");
            params.add("%" + nameFilter.trim() + "%");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        sql.append(" ORDER BY p.id");

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al listar productos", e);
        }

        return list;
    }

    /** Busca un producto por su PK. Devuelve null si no existe. */
    public Product findById(int id) {
        String sql = BASE_SELECT + "WHERE p.id = ?";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar producto id=" + id, e);
        }

        return null;
    }

    // ----------------------------------------------------------------
    // Mutaciones
    // ----------------------------------------------------------------

    /** Inserta un producto nuevo. */
    public void insert(Product p) {
        String sql =
            "INSERT INTO products (name, product_type_id, category_id, price, description, image_base, is_active) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            bindProductParams(ps, p);
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Error al insertar producto", e);
        }
    }

    /** Actualiza un producto existente. */
    public void update(Product p) {
        String sql =
            "UPDATE products " +
            "SET name=?, product_type_id=?, category_id=?, price=?, description=?, image_base=?, is_active=? " +
            "WHERE id=?";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            bindProductParams(ps, p);
            ps.setInt(8, p.getId());
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Error al actualizar producto id=" + p.getId(), e);
        }
    }

    /** Elimina un producto por su PK. */
    public void delete(int id) {
        String sql = "DELETE FROM products WHERE id = ?";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Error al eliminar producto id=" + id, e);
        }
    }

    // ----------------------------------------------------------------
    // Helpers privados
    // ----------------------------------------------------------------

    /** Vincula los 7 parametros comunes a insert y update. */
    private void bindProductParams(PreparedStatement ps, Product p) throws SQLException {
        ps.setString(1, p.getName());
        ps.setInt(2, p.getProductTypeId());
        ps.setInt(3, p.getCategoryId());
        ps.setInt(4, p.getPrice());

        if (p.getDescription() != null && !p.getDescription().isEmpty()) {
            ps.setString(5, p.getDescription());
        } else {
            ps.setNull(5, Types.VARCHAR);
        }

        if (p.getImageBase() != null && !p.getImageBase().isEmpty()) {
            ps.setString(6, p.getImageBase());
        } else {
            ps.setNull(6, Types.VARCHAR);
        }

        ps.setInt(7, p.isActive() ? 1 : 0);
    }

    /** Mapea una fila de ResultSet a un objeto Product. */
    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setProductTypeId(rs.getInt("product_type_id"));
        p.setProductTypeName(rs.getString("product_type_name"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(rs.getString("category_name"));
        p.setPrice(rs.getInt("price"));
        p.setDescription(rs.getString("description"));
        p.setImageBase(rs.getString("image_base"));
        p.setActive(rs.getInt("is_active") == 1);
        return p;
    }
}
