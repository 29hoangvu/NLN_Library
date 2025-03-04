package Servlet;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@MultipartConfig(maxFileSize = 16177215) // Giới hạn ảnh tối đa ~16MB
public class UpdateBookServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        String subject = request.getParameter("subject");
        String publisher = request.getParameter("publisher");
        String language = request.getParameter("language");
        String format = request.getParameter("format");
        String description = request.getParameter("description");

        // Chuyển đổi giá trị số nguyên an toàn
        int publicationYear = parseInteger(request.getParameter("publicationYear"));
        int numberOfPages = parseInteger(request.getParameter("numberOfPages"));
        int quantity = parseInteger(request.getParameter("quantity"));

        Part filePart = request.getPart("coverImage"); // Ảnh bìa
        InputStream fileContent = null;
        if (filePart != null && filePart.getSize() > 0) {
            fileContent = filePart.getInputStream();
            System.out.println("✅ File part retrieved successfully.");
        } else {
            System.out.println("⚠️ No file part found or file size is zero.");
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        PreparedStatement stmtSummary = null;
        PreparedStatement stmtBookId = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Truy vấn lấy book_id từ bảng book
            String getBookIdSQL = "SELECT id FROM book WHERE isbn=?";
            stmtBookId = conn.prepareStatement(getBookIdSQL);
            stmtBookId.setString(1, isbn);
            rs = stmtBookId.executeQuery();

            int bookId = -1;
            if (rs.next()) {
                bookId = rs.getInt("id");
            } else {
                response.sendRedirect("editBook.jsp?isbn=" + isbn + "&error=Không tìm thấy sách");
                return;
            }

            // Cập nhật thông tin sách (luôn cập nhật coverImage nếu có file)
            String updateBookSQL = "UPDATE book SET title=?, subject=?, publisher=?, publicationYear=?, language=?, numberOfPages=?, format=?, quantity=?";
            if (fileContent != null) {
                updateBookSQL += ", coverImage=?";
            }
            updateBookSQL += " WHERE isbn=?";

            stmt = conn.prepareStatement(updateBookSQL);
            stmt.setString(1, title);
            stmt.setString(2, subject);
            stmt.setString(3, publisher);
            stmt.setInt(4, publicationYear);
            stmt.setString(5, language);
            stmt.setInt(6, numberOfPages);
            stmt.setString(7, format);
            stmt.setInt(8, quantity);

            int paramIndex = 9;
            if (fileContent != null) {
                stmt.setBinaryStream(paramIndex++, fileContent, filePart.getSize());
                System.out.println("✅ Cover image set for update.");
            }
            stmt.setString(paramIndex, isbn);

            int rowsUpdated = stmt.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("✅ Cập nhật sách thành công!");
            } else {
                System.out.println("❌ Không tìm thấy sách để cập nhật.");
            }

            // Cập nhật mô tả sách (nếu có)
            if (description != null && !description.trim().isEmpty()) {
                String updateSummarySQL = "INSERT INTO book_description (id, isbn, description) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE description=?";
                stmtSummary = conn.prepareStatement(updateSummarySQL);
                stmtSummary.setInt(1, bookId);
                stmtSummary.setString(2, isbn);
                stmtSummary.setString(3, description);
                stmtSummary.setString(4, description);
                stmtSummary.executeUpdate();
                System.out.println("✅ Description updated successfully.");
            }

            response.sendRedirect("editBook.jsp?isbn=" + isbn + "&update=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("editBook.jsp?isbn=" + isbn + "&error=" + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmtBookId != null) stmtBookId.close();
                if (stmt != null) stmt.close();
                if (stmtSummary != null) stmtSummary.close();
                if (conn != null) conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    // Chuyển đổi số nguyên an toàn
    private int parseInteger(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0; // Trả về giá trị mặc định nếu có lỗi
        }
    }
}