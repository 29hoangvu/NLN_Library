<%@ page import="java.sql.*, java.util.Map, java.util.HashMap" %>
<%@ page import="Servlet.DBConnection, Data.Users" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<html>
<head>
    <title>Chi Tiết Sách</title>
    <link rel="stylesheet" href="./CSS/index.css">
</head>
<body>
    <%
        // Lấy isbn từ request
        String isbn = request.getParameter("isbn");

        if (isbn == null || isbn.trim().isEmpty()) {
            out.println("<p style='color:red'>Lỗi: Không tìm thấy ISBN.</p>");
            return;
        }

        Users user = (Users) session.getAttribute("user");
        boolean canBorrow = true;
        boolean hasBorrowed = false;
        int borrowedCount = 0;
        String borrowStatus = "Chưa đăng ký mượn";
        String returnDate = "Chưa xác định";
        boolean canExtend = false;

        Map<String, Object> book = new HashMap<>();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection(); 

            String sql = "SELECT b.title, a.name AS author, b.publicationYear, b.format, bd.description, " +
                     "r.rack_number, b.subject, b.quantity " +
                     "FROM book b " + 
                     "JOIN author a ON b.authorId = a.id " +
                     "LEFT JOIN book_description bd ON b.isbn = bd.isbn " +
                     "LEFT JOIN bookitem bi ON b.isbn = bi.book_item_id " +
                     "LEFT JOIN rack r ON bi.rack_id = r.rack_id " +
                     "WHERE b.isbn = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, isbn);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                book.put("title", rs.getString("title"));
                book.put("author", rs.getString("author"));
                book.put("description", rs.getString("description"));
                book.put("format", rs.getString("format"));
                book.put("rack", rs.getString("rack_number") != null ? rs.getString("rack_number") : "Chưa sắp xếp");
                book.put("subject", rs.getString("subject"));
                book.put("quantity", rs.getInt("quantity"));
                
                int publishedYear = rs.getInt("publicationYear");
                book.put("publicationYear", (publishedYear > 0) ? publishedYear : "Không xác định");
            } else {
                out.println("<p>Không tìm thấy sách.</p>");
                return;
            }
            
            if (user != null) {
                // Kiểm tra số sách đã mượn
                sql = "SELECT COUNT(*) FROM borrow WHERE user_id = ? AND status = 'Đang mượn'";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, user.getId());
                rs = stmt.executeQuery();
                if (rs.next()) {
                    borrowedCount = rs.getInt(1);
                    if (borrowedCount >= 3) {
                        canBorrow = false;
                    }
                }

                // Kiểm tra trạng thái mượn của sách này
                sql = "SELECT status, due_date, extended FROM borrow WHERE user_id = ? AND book_item_id = ?";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, user.getId());
                stmt.setString(2, isbn);
                rs = stmt.executeQuery();
                if (rs.next()) {
                    hasBorrowed = true;
                    borrowStatus = rs.getString("status");
                    returnDate = rs.getString("due_date");
                    canExtend = rs.getInt("extended") == 0;
                }
            }
        } catch (SQLException e) {
            out.println("<p style='color:red'>Lỗi kết nối CSDL: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }

        String format = (String) book.get("format");
    %>
    <div class="container">
        <div class="header">
            <div class="user-menu">
                <%                  
                    if (user != null) {
                %>
                    <span>Xin chào, <%= user.getUsername() %>!</span>
                    <div class="logout-button">
                         <form action="./LogOutServlet" method="get">
                            <button onclick="logout()">Đăng xuất</button>
                        </form>
                    </div>
                <%
                    } else {
                %>
                    <a href="login.jsp" class="btn">Đăng nhập</a>
                <%
                    }
                %>
            </div>

            <h1>Thư viện sách</h1>
        </div>
        <div class="menu">
            <div class="menu-navbar">
                <ul>
                    <li><a href="#hardcover">Sách Bìa Cứng</a></li>
                    <li><a href="#paperback">Sách Bìa Mềm</a></li>
                    <li><a href="#ebook">Ebook</a></li>
                </ul>
            </div>   
        </div>
        <div class="content">     
        <div class="book-detail">
            <!-- Hình ảnh sách -->
            <div class="book-image">
                <img src="ImageServlet?isbn=<%= isbn %>" alt="Ảnh bìa" />
                
                <% if (!"EBOOK".equalsIgnoreCase(format)) { %>
                    <form action="BorrowBookServlet" method="post">
                        <input type="hidden" id="isbn" name="isbn" value="<%= isbn %>">
                        <a href="BorrowBookServlet?isbn=<%= isbn %>" class="btn borrow-btn">Đăng ký mượn</a>
                    </form>
                <% } else { %>
                    <a href="readBook.jsp?isbn=<%= isbn %>" class="btn read-btn">Đọc online</a>
                    <a href="downloadBook.jsp?isbn=<%= isbn %>" class="btn download-btn">Tải về</a>
                <% } %>
            </div>

            <!-- Thông tin sách -->
            <div class="book-info">
                <h3><%= book.get("title") %></h3>
                <p><strong>Tác giả: </strong> <%= book.get("author") %></p>
                <p><strong>Năm xuất bản: </strong> <%= book.get("publicationYear") %></p>
                <p><strong>Thể Loại: </strong> <%= book.get("subject") %></p>               
                <p><strong>Định dạng: </strong> <%= format %></p>
                <p><strong>Số lượng còn lại: </strong> <%= book.get("quantity") %></p>
                <p><strong>Vị trí kệ: </strong> <%= book.get("rack") %></p>
            </div>
        </div>

        <!-- Mô tả sách -->
        <div class="book-description">
            <h3>Mô tả sách</h3>
            <p><%= book.get("description") != null ? book.get("description") : "Chưa có mô tả" %></p>
        </div>
    </div>  
    <a href="index.jsp" class="back-link">Quay lại danh sách sách</a>
    </div>
        <div class="footer">
            
        </div>
</body>
</html>
