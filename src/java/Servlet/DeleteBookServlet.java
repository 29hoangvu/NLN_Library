package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class DeleteBookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response); // Chuyển hướng GET sang POST
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String isbn = request.getParameter("isbn");
        response.setContentType("text/html; charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        if (isbn == null || isbn.isEmpty()) {
            response.sendRedirect("adminDashboard.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM book WHERE isbn = ?")) {
            stmt.setString(1, isbn);
            int rowsDeleted = stmt.executeUpdate();

            if (rowsDeleted > 0) {
                response.getWriter().write("<script>alert('Xóa thành công!'); window.location='adminDashboard.jsp';</script>");
            } else {
                response.getWriter().write("<script>alert('Không tìm thấy sách để xóa!'); window.location='adminDashboard.jsp';</script>");
            }
        } catch (Exception e) {
            response.getWriter().write("Lỗi: " + e.getMessage());
        }
    }
}
