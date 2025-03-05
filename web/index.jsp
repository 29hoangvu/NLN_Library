<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection, Data.Users" %>
<%@ page session="true" %>
<html>
<head>
    <title>Thư viện Sách</title>
    <link rel="stylesheet" href="./CSS/home.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 style="float: left; margin-right: 20px;">Thư viện sách</h1>
            <form action="index.jsp" method="get" class="search-form">
                <input type="text" name="search" placeholder="Tìm sách theo tên hoặc tác giả..." 
                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                <button type="submit">Tìm kiếm</button>
            </form>
            <div class="user-menu" style="float: right;">
                <%
                    Users user = (Users) session.getAttribute("user");
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
            <%
                Connection conn = null;
                List<Map<String, Object>> books = new ArrayList<>();
                String searchQuery = request.getParameter("search");
                
                try {
                    conn = DBConnection.getConnection();
                    String sql = "SELECT b.isbn, b.title, a.name AS author, b.publicationYear, b.format " +
                                 "FROM book b " +
                                 "LEFT JOIN author a ON b.authorId = a.id";
                    
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        sql += " WHERE b.title LIKE ? OR a.name LIKE ?";
                    }
                    
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        stmt.setString(1, "%" + searchQuery + "%");
                        stmt.setString(2, "%" + searchQuery + "%");
                    }
                    
                    ResultSet rs = stmt.executeQuery();
                    
                    while (rs.next()) {
                        Map<String, Object> book = new HashMap<>();
                        book.put("isbn", rs.getString("isbn"));
                        book.put("title", rs.getString("title"));
                        book.put("author", rs.getString("author"));
                        book.put("publishedYear", rs.getInt("publicationYear"));
                        book.put("format", rs.getString("format"));
                        books.add(book);
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<p style='color:red;'>Lỗi khi lấy dữ liệu sách: " + e.getMessage() + "</p>");
                } finally {
                    if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                }
            %>

            <% String[] formats = {"HARDCOVER", "PAPERBACK", "EBOOK"}; %>
            <% for (String format : formats) { %>
                <h3 ><%= format.equals("HARDCOVER") ? "Sách Bìa Cứng" : format.equals("PAPERBACK") ? "Sách Bìa Mềm" : "Ebook" %></h3>
                <div class="books-container">
                    <% boolean hasBooks = false; %>
                    <% for (Map<String, Object> book : books) { %>
                        <% if (format.equals(book.get("format"))) { %>
                            <% hasBooks = true; %>
                            <div class="book-card">
                                <a href="bookDetails.jsp?isbn=<%= book.get("isbn") %>">
                                    <img src="ImageServlet?isbn=<%= book.get("isbn") %>" alt="Ảnh bìa" />
                                </a>
                                <h3><%= book.get("title") %></h3>
                                <p><strong>Tác giả:</strong> <%= book.get("author") %></p>
                                <p><strong>Năm xuất bản:</strong> <%= book.get("publishedYear") %></p>
                            </div>
                        <% } %>
                    <% } %>
                    <% if (!hasBooks) { %>
                        <p>Không có sách trong danh mục này.</p>
                    <% } %>
                </div>
            <% } %>
        </div>
        
        <div class="footer">
            <p>Bản quyền &copy; 2025 - Thư viện sách</p>
        </div>
    </div>
</body>
</html>