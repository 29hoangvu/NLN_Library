package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = PasswordHashing.hashPassword(request.getParameter("password"));

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id, roleID, status FROM users WHERE username=? AND password=?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String status = rs.getString("status");
                int roleID = rs.getInt("roleID");

                if (!status.equals("ACTIVE")) {
                    response.getWriter().println("Tài khoản chưa được duyệt hoặc đã hết hạn.");
                    return;
                }

                // Lưu thông tin vào session
                HttpSession session = request.getSession();
                session.setAttribute("userID", rs.getInt("id"));
                session.setAttribute("roleID", roleID);

                // Điều hướng theo role
                if (roleID == 3) {
                    response.sendRedirect("index.jsp");  // Thành viên
                } else {
                    response.sendRedirect("admin.jsp");  // Admin hoặc Thủ thư
                }

            } else {
                response.getWriter().println("Sai tên đăng nhập hoặc mật khẩu.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi đăng nhập!");
        }
    }
}
