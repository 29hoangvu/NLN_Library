package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8"); // Đảm bảo xử lý tiếng Việt
        response.setContentType("text/html; charset=UTF-8");

        String username = request.getParameter("username");
        String password = PasswordHashing.hashPassword(request.getParameter("password"));

        try (Connection conn = DBConnection.getConnection()) {
            // Kiểm tra xem tên đăng nhập đã tồn tại chưa
            String checkUserSQL = "SELECT COUNT(*) FROM users WHERE username = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkUserSQL);
            checkStmt.setString(1, username);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                response.getWriter().println("<script>alert('Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác!'); window.location='register.jsp';</script>");
                return;
            }

            // Thêm tài khoản mới với trạng thái "Chờ duyệt"
            String sql = "INSERT INTO users (username, password, status, expiryDate, roleID) VALUES (?, ?, 'PENDING', ?, 3)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);
            stmt.setDate(3, java.sql.Date.valueOf(LocalDate.now().plusYears(1))); // Mặc định thời hạn 1 năm
            stmt.executeUpdate();

            response.getWriter().println("<script>alert('Đăng ký thành công! Vui lòng đến thư viện để kích hoạt tài khoản.'); window.location='login.jsp';</script>");
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Lỗi đăng ký! Vui lòng thử lại sau.'); window.location='register.jsp';</script>");
        }
    }
}
