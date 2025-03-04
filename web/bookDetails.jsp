<%@ page import="java.sql.*, java.util.Map, java.util.HashMap, java.text.SimpleDateFormat" %>
<%@ page import="Servlet.DBConnection" %> <!-- Sử dụng DBConnection -->
<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<html>
<head>
    <title>Chi Tiết Sách</title>
    <style>
       /* Căn giữa toàn bộ nội dung */
.container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    min-height: 100vh;
    padding: 20px;
}

/* Bố cục hiển thị sách */
.book-container {
    display: flex;
    gap: 40px; /* Tăng khoảng cách giữa ảnh và thông tin */
    width: 70%;
    max-width: 900px;
    background: #fff;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
    align-items: center;
}

/* Phần hình ảnh sách */
.book-image {
    flex: 1;
    text-align: center;
}

.book-image img {
    width: 300px; /* Tăng kích thước ảnh */
    height: auto;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

/* Nút đăng ký mượn */
.borrow-btn {
    display: block;
    margin-top: 15px;
    padding: 12px 20px;
    background: #28a745;
    color: white;
    text-align: center;
    text-decoration: none;
    font-weight: bold;
    border-radius: 6px;
    transition: 0.3s;
    font-size: 18px;
}

.borrow-btn:hover {
    background: #218838;
}

/* Thông tin sách */
.book-info {
    flex: 2;
}

.book-info h3 {
    font-size: 28px;
    margin-bottom: 15px;
}

.book-info p {
    font-size: 18px;
    margin: 8px 0;
}

/* Mô tả sách */
.book-description {
    margin-top: 30px;
    width: 70%;
    max-width: 900px;
    text-align: justify;
    padding: 20px;
    border-top: 3px solid #ddd;
    font-size: 18px;
    background: #fafafa;
    border-radius: 8px;
}

    </style>
</head>
<body>
    <h2>Chi Tiết Sách</h2>

    <%
        // Lấy isbn từ request, kiểm tra null
        String isbn = request.getParameter("isbn");

        if (isbn == null || isbn.trim().isEmpty()) {
            out.println("<p style='color:red'>Lỗi: Không tìm thấy ISBN.</p>");
            return;
        }

        Map<String, Object> book = new HashMap<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection(); // Sử dụng DBConnection

            String sql = "SELECT b.title,  a.name AS author, b.publicationYear, bd.description " +                         
                         "FROM book b " + 
                         "JOIN author a ON b.authorId = a.id " +
                         "LEFT JOIN book_description bd ON b.isbn = bd.isbn " +                      
                         "WHERE b.isbn = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, isbn);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                book.put("title", rs.getString("title"));
                book.put("author", rs.getString("author"));
                book.put("description", rs.getString("description"));

                int publishedYear = rs.getInt("publicationYear");
                book.put("publicationYear", (publishedYear > 0) ? publishedYear : "Không xác định");

            } else {
                out.println("<p>Không tìm thấy sách.</p>");
                return;
            }
        } catch (SQLException e) {
            out.println("<p style='color:red'>Lỗi kết nối CSDL: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    %>
    <div class="container">
        <div class="book-container">
            <!-- Hình ảnh sách -->
            <div class="book-image">
                <img src="ImageServlet?isbn=<%= isbn %>" alt="Ảnh bìa" />
                <a href="borrowBook.jsp?isbn=<%= isbn %>" class="borrow-btn">Đăng ký mượn</a>
            </div>

            <!-- Thông tin sách -->
            <div class="book-info">
                <h3><%= book.get("title") %></h3>
                <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                <p><strong>Năm xuất bản:</strong> <%= book.get("publicationYear") %></p>
            </div>
        </div>

        <!-- Mô tả sách -->
        <div class="book-description">
            <h3>Mô tả sách</h3>
            <p><%= book.get("description") != null ? book.get("description") : "Chưa có mô tả" %></p>
        </div>
    </div>

    <a href="index.jsp" class="back-link">Quay lại danh sách sách</a>
</body>
</html>
