package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = PasswordHashing.hashPassword(request.getParameter("password"));

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO users (username, password, status, expiryDate, roleID) VALUES (?, ?, 'PENDING', ?, 3)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);
            stmt.setDate(3, java.sql.Date.valueOf(LocalDate.now().plusYears(1))); // Mặc định 1 năm
            stmt.executeUpdate();
            response.sendRedirect("login.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi đăng ký!");
        }
    }
}
