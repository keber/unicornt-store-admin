package com.unicornt.store.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.unicornt.store.config.DatabaseConnection;
import com.unicornt.store.model.ProductType;

/** Acceso a datos para la tabla product_types. */
public class ProductTypeDAO {

    /** Lista todos los tipos de producto ordenados por id. */
    public List<ProductType> findAll() {
        List<ProductType> list = new ArrayList<>();
        String sql = "SELECT id, name, slug FROM product_types ORDER BY id";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductType pt = new ProductType();
                pt.setId(rs.getInt("id"));
                pt.setName(rs.getString("name"));
                pt.setSlug(rs.getString("slug"));
                list.add(pt);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al listar tipos de producto", e);
        }

        return list;
    }
}
