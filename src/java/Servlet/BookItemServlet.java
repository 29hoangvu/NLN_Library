package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class BookItemServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String bookId = request.getParameter("bookId");
        String rackId = request.getParameter("rackId");
        String price = request.getParameter("price");
        String dateOfPurchase = request.getParameter("dateOfPurchase");

        try {
            Connection conn = DBConnection.getConnection();
            String sql = "INSERT INTO BookItem (book_id, price, date_of_purchase, rack_id) VALUES (?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, bookId);
            pstmt.setDouble(2, Double.parseDouble(price));
            pstmt.setString(3, dateOfPurchase);
            pstmt.setInt(4, Integer.parseInt(rackId));

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("addBookItem.jsp?message=Thêm vị trí sách thành công!");
            } else {
                response.sendRedirect("addBookItem.jsp?message=Lỗi khi thêm vị trí sách!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addBookItem.jsp?message=Lỗi hệ thống: " + e.getMessage());
        }
    }
}
