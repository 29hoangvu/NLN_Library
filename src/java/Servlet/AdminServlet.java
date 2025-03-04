package Servlet;
import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // Giới hạn file 5MB
public class AdminServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        String subject = request.getParameter("subject");
        String publisher = request.getParameter("publisher");
        int publicationYear = Integer.parseInt(request.getParameter("publicationYear"));
        String language = request.getParameter("language");
        int numberOfPages = Integer.parseInt(request.getParameter("numberOfPages"));
        String format = request.getParameter("format");
        String authorName = request.getParameter("authorName");
        String isNewAuthor = request.getParameter("isNewAuthor");
        String authorIdParam = request.getParameter("authorId");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        int authorId = 0;

        try (Connection conn = DBConnection.getConnection()) {
            // Xử lý tác giả
            if ("true".equals(isNewAuthor)) {
                // Nếu là tác giả mới
                authorId = getOrInsertAuthor(conn, authorName);
            } else if (authorIdParam != null && !authorIdParam.isEmpty()) {
                // Nếu là tác giả đã có sẵn
                authorId = Integer.parseInt(authorIdParam);
            } else {
                throw new SQLException("Không xác định được tác giả.");
            }

            // Thêm sách vào CSDL
            String sql = "INSERT INTO Book (isbn, title, subject, publisher, publicationYear, language, numberOfPages, format, authorId, quantity, coverImage) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, isbn);
                stmt.setString(2, title);
                stmt.setString(3, subject);
                stmt.setString(4, publisher);
                stmt.setInt(5, publicationYear);
                stmt.setString(6, language);
                stmt.setInt(7, numberOfPages);
                stmt.setString(8, format);
                stmt.setInt(9, authorId);
                stmt.setInt(10, quantity);
                Part filePart = request.getPart("coverImage");
                stmt.setBlob(11, filePart.getInputStream());

                int rows = stmt.executeUpdate();
                sendResponse(response, rows > 0 ? "Thêm sách thành công!" : "Lỗi khi thêm sách.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(response, "Lỗi: " + e.getMessage());
        }
    }

    private int getOrInsertAuthor(Connection conn, String authorName) throws SQLException {
        String checkSQL = "SELECT id FROM Author WHERE name = ?";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSQL)) {
            checkStmt.setString(1, authorName);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        }

        String insertSQL = "INSERT INTO Author (name) VALUES (?)";
        try (PreparedStatement insertStmt = conn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS)) {
            insertStmt.setString(1, authorName);
            insertStmt.executeUpdate();
            ResultSet keys = insertStmt.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        }
        throw new SQLException("Không thể thêm hoặc tìm tác giả.");
    }

    private void sendResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>alert('" + message + "'); window.location.href='admin.jsp';</script>");
    }
}
