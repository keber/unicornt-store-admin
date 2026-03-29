package com.unicornt.store.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.unicornt.store.config.DatabaseConnection;
import com.unicornt.store.model.Category;

/** Acceso a datos para la tabla categories. */
public class CategoryDAO {

    /** Lista todas las categorias ordenadas por nombre. */
    public List<Category> findAll() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, name, slug FROM categories ORDER BY name";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setSlug(rs.getString("slug"));
                list.add(c);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al listar categorias", e);
        }

        return list;
    }
}
