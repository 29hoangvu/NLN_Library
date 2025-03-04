package Servlet;

import Data.UserDAO;
import Data.Users;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AddUserServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users adminUser = (Users) session.getAttribute("user");

        

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String roleID = request.getParameter("roleID");

        try {
            String hashedPassword = PasswordHashing.hashPassword(password);
            Date expiryDate = null; // Mặc định NULL nếu là Admin hoặc Thủ thư

            // Nếu vai trò không phải Admin hoặc Thủ thư, đặt thời hạn 1 năm
            if (!roleID.equals("1") && !roleID.equals("2")) { 
                Calendar calendar = Calendar.getInstance();
                calendar.add(Calendar.YEAR, 1);
                expiryDate = calendar.getTime();
            }

            // Mặc định trạng thái là ACTIVE vì Admin tạo
            Users user = new Users(0, username, hashedPassword, "ACTIVE", expiryDate, Integer.parseInt(roleID));

            boolean success = userDAO.createUser(user);
            if (success) {
                response.sendRedirect("createUser.jsp?message=Người dùng được thêm thành công!");
            } else {
                response.sendRedirect("createUser.jsp?message=Thêm người dùng thất bại!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
