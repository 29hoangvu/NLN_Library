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
import Data.Users;

public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Mã hóa mật khẩu
        String hashedPassword = PasswordHashing.hashPassword(password);

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id, username, roleID, status FROM users WHERE username=? AND password=?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, hashedPassword);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String status = rs.getString("status");
                int roleID = rs.getInt("roleID");

                if (!"ACTIVE".equals(status)) {
                    request.setAttribute("error", "Tài khoản chưa được duyệt hoặc đã hết hạn.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }

                // Tạo đối tượng Users và lưu vào session
                Users user = new Users();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setRoleID(roleID);
                user.setStatus(status);

                HttpSession session = request.getSession();
                session.setAttribute("user", user);

                // Điều hướng theo quyền
                if (roleID == 3) {
                    response.sendRedirect("index.jsp"); // Thành viên
                } else {
                    response.sendRedirect("admin.jsp"); // Admin hoặc Thủ thư
                }

            } else {
                request.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
