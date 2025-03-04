package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Calendar;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class RenewUserServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer roleID = (Integer) session.getAttribute("roleID");

        if (roleID == null || roleID != 1) {
            response.getWriter().println("Bạn không có quyền gia hạn tài khoản!");
            return;
        }

        String userID = request.getParameter("userID");

        try (Connection conn = DBConnection.getConnection()) {
            String selectSQL = "SELECT expiryDate FROM users WHERE id=?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSQL);
            selectStmt.setString(1, userID);
            ResultSet rs = selectStmt.executeQuery();

            if (!rs.next()) {
                response.getWriter().println("Không tìm thấy tài khoản!");
                return;
            }

            Calendar calendar = Calendar.getInstance();
            if (rs.getDate("expiryDate") != null) {
                calendar.setTime(rs.getDate("expiryDate"));
            }
            calendar.add(Calendar.YEAR, 1);
            java.sql.Date newExpiryDate = new java.sql.Date(calendar.getTimeInMillis());

            String updateSQL = "UPDATE users SET expiryDate=?, status='ACTIVE' WHERE id=?";
            PreparedStatement updateStmt = conn.prepareStatement(updateSQL);
            updateStmt.setDate(1, newExpiryDate);
            updateStmt.setString(2, userID);
            int rowsUpdated = updateStmt.executeUpdate();

            if (rowsUpdated > 0) {
                response.sendRedirect("userManagement.jsp?message=Gia hạn tài khoản thành công!");
            } else {
                response.getWriter().println("Gia hạn thất bại!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi hệ thống!");
        }
    }
}