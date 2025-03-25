package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ApplyFineServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int borrowId = Integer.parseInt(request.getParameter("id"));
        double fineAmount = Double.parseDouble(request.getParameter("fineAmount"));
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE borrow SET fine_amount = ?, status = 'Trễ hạn' WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setDouble(1, fineAmount);
            pstmt.setInt(2, borrowId);
            int updated = pstmt.executeUpdate();
            response.getWriter().write(updated > 0 ? "Phạt thành công" : "Lỗi khi phạt");
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("Lỗi SQL");
        }
    }
}