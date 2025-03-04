package Servlet;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class ImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String isbn = request.getParameter("isbn"); // Lấy ISBN từ request

        if (isbn != null) {
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                conn = DBConnection.getConnection(); // Kết nối DB
                String sql = "SELECT coverImage FROM book WHERE isbn = ?";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, isbn);
                rs = stmt.executeQuery();

                if (rs.next()) {
                    Blob imageBlob = rs.getBlob("coverImage");

                    if (imageBlob != null && imageBlob.length() > 0) {
                        response.setContentType("image/jpeg"); // Định dạng ảnh
                        InputStream inputStream = imageBlob.getBinaryStream();
                        OutputStream outputStream = response.getOutputStream();

                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        while ((bytesRead = inputStream.read(buffer)) != -1) {
                            outputStream.write(buffer, 0, bytesRead);
                        }
                        inputStream.close();
                        outputStream.flush();
                    } else {
                        sendDefaultImage(response); // Ảnh mặc định nếu không có ảnh trong DB
                    }
                } else {
                    sendDefaultImage(response);
                }
            } catch (SQLException e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ISBN của sách");
        }
    }

    // Phương thức trả về ảnh mặc định
    private void sendDefaultImage(HttpServletResponse response) throws IOException {
        response.setContentType("image/png"); // Định dạng ảnh mặc định
        InputStream defaultImage = getServletContext().getResourceAsStream("/images/default-book.png"); // Ảnh mặc định trong thư mục web
        if (defaultImage != null) {
            OutputStream outputStream = response.getOutputStream();
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = defaultImage.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
            defaultImage.close();
            outputStream.flush();
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy ảnh mặc định");
        }
    }
}
